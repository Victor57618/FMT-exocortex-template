#!/usr/bin/env python3
"""Local MCP gateway for peer status and cross-agent file locks."""

from __future__ import annotations

import argparse
import json
import os
import sys
import time
from contextlib import contextmanager
from pathlib import Path
from typing import Any, Iterator

if os.name == "nt":
    import msvcrt
else:
    import fcntl


PROTOCOL_VERSION = "2024-11-05"

# MCP stdio is UTF-8 regardless of the active Windows console code page.
sys.stdin.reconfigure(encoding="utf-8")
sys.stdout.reconfigure(encoding="utf-8")


def utc_timestamp() -> str:
    return time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())


class StateStore:
    def __init__(self, state_dir: Path) -> None:
        self.state_dir = state_dir
        self.state_file = state_dir / "coordination-state.json"
        self.guard_file = state_dir / "coordination-state.lock"

    @contextmanager
    def locked_state(self) -> Iterator[dict[str, Any]]:
        self.state_dir.mkdir(parents=True, exist_ok=True)
        with self.guard_file.open("a+b") as guard:
            guard.seek(0)
            if os.name == "nt":
                if guard.tell() == 0 and guard.read(1) == b"":
                    guard.write(b"0")
                    guard.flush()
                guard.seek(0)
                msvcrt.locking(guard.fileno(), msvcrt.LK_LOCK, 1)
            else:
                fcntl.flock(guard.fileno(), fcntl.LOCK_EX)
            try:
                state = self._read()
                self._remove_expired_locks(state)
                yield state
                temporary = self.state_file.with_suffix(".tmp")
                temporary.write_text(
                    json.dumps(state, ensure_ascii=False, indent=2) + "\n",
                    encoding="utf-8",
                )
                os.replace(temporary, self.state_file)
            finally:
                if os.name == "nt":
                    guard.seek(0)
                    msvcrt.locking(guard.fileno(), msvcrt.LK_UNLCK, 1)
                else:
                    fcntl.flock(guard.fileno(), fcntl.LOCK_UN)

    def _read(self) -> dict[str, Any]:
        try:
            state = json.loads(self.state_file.read_text(encoding="utf-8"))
        except (FileNotFoundError, json.JSONDecodeError):
            state = {}
        state.setdefault("statuses", {})
        state.setdefault("locks", {})
        return state

    @staticmethod
    def _remove_expired_locks(state: dict[str, Any]) -> None:
        now = time.time()
        state["locks"] = {
            path: lock
            for path, lock in state["locks"].items()
            if float(lock.get("expires_at_epoch", 0)) > now
        }


class Gateway:
    def __init__(self, agent: str, state_dir: Path) -> None:
        self.agent = agent
        self.store = StateStore(state_dir)

    def call(self, name: str, arguments: dict[str, Any]) -> dict[str, Any]:
        handlers = {
            "update_peer_status": self.update_peer_status,
            "list_peer_statuses": self.list_peer_statuses,
            "acquire_file_lock": self.acquire_file_lock,
            "release_file_lock": self.release_file_lock,
        }
        if name not in handlers:
            raise ValueError(f"Unknown tool: {name}")
        result = handlers[name](arguments)
        return {
            "content": [{"type": "text", "text": json.dumps(result, ensure_ascii=False)}],
            "structuredContent": result,
            "isError": not result.get("ok", False),
        }

    def update_peer_status(self, args: dict[str, Any]) -> dict[str, Any]:
        status = str(args.get("status", "")).strip()
        if not status:
            return {"ok": False, "error": "status is required"}
        agent = str(args.get("agent") or self.agent)
        record = {
            "agent": agent,
            "status": status,
            "current_task": str(args.get("current_task", "")),
            "files": [str(item) for item in args.get("files", [])],
            "updated_at": utc_timestamp(),
        }
        with self.store.locked_state() as state:
            state["statuses"][agent] = record
        return {"ok": True, "status": record}

    def list_peer_statuses(self, _args: dict[str, Any]) -> dict[str, Any]:
        with self.store.locked_state() as state:
            statuses = list(state["statuses"].values())
        return {"ok": True, "statuses": statuses}

    def acquire_file_lock(self, args: dict[str, Any]) -> dict[str, Any]:
        raw_path = args.get("canonical_file") or args.get("file")
        if not raw_path:
            return {"ok": False, "error": "canonical_file is required"}
        path = str(Path(str(raw_path)).resolve()).casefold()
        ttl = max(1, int(args.get("ttl_seconds", 300)))
        agent = str(args.get("agent") or self.agent)
        now = time.time()
        with self.store.locked_state() as state:
            existing = state["locks"].get(path)
            if existing and existing.get("agent") != agent:
                return {
                    "ok": False,
                    "error": "lock_collision",
                    "canonical_file": path,
                    "held_by": existing.get("agent"),
                    "expires_at": existing.get("expires_at"),
                }
            lock = {
                "agent": agent,
                "canonical_file": path,
                "acquired_at": utc_timestamp(),
                "expires_at_epoch": now + ttl,
                "expires_at": time.strftime(
                    "%Y-%m-%dT%H:%M:%SZ", time.gmtime(now + ttl)
                ),
            }
            state["locks"][path] = lock
        return {"ok": True, "lock": lock}

    def release_file_lock(self, args: dict[str, Any]) -> dict[str, Any]:
        raw_path = args.get("canonical_file") or args.get("file")
        if not raw_path:
            return {"ok": False, "error": "canonical_file is required"}
        path = str(Path(str(raw_path)).resolve()).casefold()
        agent = str(args.get("agent") or self.agent)
        with self.store.locked_state() as state:
            existing = state["locks"].get(path)
            if not existing:
                return {"ok": True, "released": False, "canonical_file": path}
            if existing.get("agent") != agent:
                return {
                    "ok": False,
                    "error": "lock_owned_by_other_agent",
                    "held_by": existing.get("agent"),
                }
            del state["locks"][path]
        return {"ok": True, "released": True, "canonical_file": path}


TOOLS = [
    {
        "name": "update_peer_status",
        "description": "Declare the agent's current workspace task and files.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "status": {"type": "string"},
                "current_task": {"type": "string"},
                "files": {"type": "array", "items": {"type": "string"}},
                "agent": {"type": "string"},
            },
            "required": ["status"],
        },
    },
    {
        "name": "list_peer_statuses",
        "description": "List the latest declared status of each workspace agent.",
        "inputSchema": {"type": "object", "properties": {}},
    },
    {
        "name": "acquire_file_lock",
        "description": "Acquire or renew an exclusive, expiring file lock.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "canonical_file": {"type": "string"},
                "file": {"type": "string"},
                "ttl_seconds": {"type": "integer", "minimum": 1},
                "agent": {"type": "string"},
            },
        },
    },
    {
        "name": "release_file_lock",
        "description": "Release a file lock owned by this agent.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "canonical_file": {"type": "string"},
                "file": {"type": "string"},
                "agent": {"type": "string"},
            },
        },
    },
]


def response(request_id: Any, result: dict[str, Any] | None = None, error: str | None = None) -> None:
    message: dict[str, Any] = {"jsonrpc": "2.0", "id": request_id}
    if error is None:
        message["result"] = result or {}
    else:
        message["error"] = {"code": -32603, "message": error}
    print(json.dumps(message, ensure_ascii=False), flush=True)


def serve(gateway: Gateway) -> None:
    for line in sys.stdin:
        try:
            request = json.loads(line)
            method = request.get("method")
            request_id = request.get("id")
            if request_id is None:
                continue
            if method == "initialize":
                response(
                    request_id,
                    {
                        "protocolVersion": request.get("params", {}).get(
                            "protocolVersion", PROTOCOL_VERSION
                        ),
                        "capabilities": {"tools": {}},
                        "serverInfo": {"name": "iwe-local-gateway", "version": "1.0.0"},
                    },
                )
            elif method == "ping":
                response(request_id, {})
            elif method == "tools/list":
                response(request_id, {"tools": TOOLS})
            elif method == "tools/call":
                params = request.get("params", {})
                response(
                    request_id,
                    gateway.call(params.get("name", ""), params.get("arguments", {})),
                )
            else:
                response(request_id, error=f"Method not found: {method}")
        except Exception as exc:  # Keep the stdio server alive after a bad request.
            response(request.get("id") if "request" in locals() else None, error=str(exc))


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--agent", default=os.environ.get("IWE_AGENT_NAME", "unknown-agent"))
    parser.add_argument(
        "--state-dir",
        type=Path,
        default=Path(os.environ.get("IWE_GATEWAY_STATE_DIR", Path.home() / ".iwe")),
    )
    args = parser.parse_args()
    serve(Gateway(args.agent, args.state_dir))


if __name__ == "__main__":
    main()
