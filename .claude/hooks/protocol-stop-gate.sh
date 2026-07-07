#!/bin/bash
# protocol-stop-gate.sh
# see DP.SC.025 (capture-bus), WP-229 Ф4
# Event: Stop
# Проверяет: если в сессии был вызов Skill (day-open|day-close|run-protocol|wp-new),
# то должен быть TodoWrite с ≥3 items. Иначе — block.
# Принцип warn-before-block: action=warn (промоция в block после 2 нед обкатки).
#
# Защита от infinite loop: переменная STOP_HOOK_ACTIVE.
# Read-only кроме gate_log.jsonl.

set -uo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"

# --- WP-265 Ф5.2: cleanup dry-run sentinel on session end ---
if [ -n "${CLAUDE_SESSION_ID:-}" ]; then
    rm -f "/tmp/iwe-dry-run-${CLAUDE_SESSION_ID}.flag" 2>/dev/null || true
fi

# --- Infinite loop guard ---
if [ "${STOP_HOOK_ACTIVE:-}" = "1" ]; then
  echo '{}'
  exit 0
fi
export STOP_HOOK_ACTIVE=1

INPUT=$(cat)
if [ -z "$INPUT" ]; then
  echo '{}'
  exit 0
fi

TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // empty')

# Нет транскрипта — пропустить
if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
  echo '{}'
  exit 0
fi

# Load unified environment: WORKSPACE_DIR, IWE_ROOT, IWE_SCRIPTS, etc.
HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$(cd "$HOOK_DIR/.." && pwd)"
# shellcheck source=../lib/iwe-env-bootstrap.sh
source "$CLAUDE_DIR/lib/iwe-env-bootstrap.sh" || exit 1
GATE_LOG="$IWE_ROOT/.claude/logs/gate_log.jsonl"
mkdir -p "$(dirname "$GATE_LOG")" 2>/dev/null || true

# --- Шаг 1: был ли вызов протокольного скилла? ---
PROTOCOL_SKILL=$(jq -r '
  select(.type == "tool_use" and .name == "Skill")
  | .input.skill // empty
' "$TRANSCRIPT_PATH" 2>/dev/null \
  | grep -E '^(day-open|day-close|run-protocol|wp-new)$' \
  | head -1)

if [ -z "$PROTOCOL_SKILL" ]; then
  # Протокольный скилл не запускался — gate не нужен
  echo '{}'
  exit 0
fi

# --- Шаг 2: был ли TodoWrite с ≥3 items? ---
TODO_MAX=$(jq -r '
  select(.type == "tool_use" and .name == "TodoWrite")
  | .input.todos
  | if type == "array" then length else 0 end
' "$TRANSCRIPT_PATH" 2>/dev/null \
  | sort -n | tail -1)

TODO_MAX="${TODO_MAX:-0}"
THRESHOLD=3

# --- Шаг 3: логировать событие ---
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
FIRED=0
if [ "$TODO_MAX" -lt "$THRESHOLD" ]; then
  FIRED=1
fi

LOG_ENTRY=$(jq -nc \
  --arg ts "$TIMESTAMP" \
  --arg sid "$SESSION_ID" \
  --arg skill "$PROTOCOL_SKILL" \
  --arg todo_max "$TODO_MAX" \
  --arg threshold "$THRESHOLD" \
  --arg fired "$FIRED" \
  '{ts: $ts, gate: "protocol-stop-gate", session_id: $sid, skill: $skill,
    todo_max: ($todo_max|tonumber), threshold: ($threshold|tonumber),
    fired: ($fired == "1"), action: "warn"}' 2>/dev/null || true)

if [ -n "$LOG_ENTRY" ]; then
  echo "$LOG_ENTRY" >> "$GATE_LOG" 2>/dev/null || true
fi

# --- Шаг 4: action=warn (не block — обкатка 2 нед, WP-229 принцип warn-before-block) ---
if [ "$FIRED" = "1" ]; then
  cat <<EOF
{"decision": "block", "reason": "⚠️ PROTOCOL-STOP-GATE [warn]: Скилл '$PROTOCOL_SKILL' был вызван, но TodoWrite с ≥$THRESHOLD задачами не найден (найдено: $TODO_MAX). Протокол требует таск-лист ДО начала исполнения. Действие: создай TodoWrite с шагами скилла и пройди протокол заново. (gate_log: $GATE_LOG)"}
EOF
else
  echo '{}'
fi

exit 0
