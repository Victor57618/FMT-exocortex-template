---
title: Agent Coordination Manifest
description: Правила координации агентов для предотвращения scheduling race и dirty repos
version: 1
created: 2026-05-27
source: peer-session 2026-05-27-02-bot-error-analysis
---

# Agent Coordination Manifest

## 1. Проблема

Несколько автономных агентов (overnight-auditor, synchronizer, setup-agent, code-scanner, pull-repos) пишут в одни рабочие копии git-репо в ночном окне (00:00–02:00 UTC). Это приводит к:
- Scheduling race → dirty repos → pull-repos warnings
- Template-sync rc=1 (cannot pull with rebase)
- DB pool contention → latency spike (>45 с на /feed)
- Дублированию code-scan (отсутствие debounce)

## 2. Принцип: один lock-арбитр

**Local MCP Gateway** — единственная точка координации для всех агентов.
- MCP-агенты используют `acquire_file_lock` / `release_file_lock` через инструменты.
- Shell-скрипты используют JSON-RPC over Unix socket (`~/.iwe/gateway.sock`) через `nc -U`.
- Lock-ключ: символический `repo:<canonical-name>` реализуется через файловый якорь `<repo-path>/.git/index`.

### 2.1 Shell helper

```bash
GATEWAY_SOCKET="${IWE_GATEWAY_SOCKET:-$HOME/.iwe/gateway.sock}"
REPO_LOCK_FILE="$HOME/IWE/<REPO>/.git/index"

_gateway_lock_acquire() {
    local file="${1:-$REPO_LOCK_FILE}"
    local ttl="${2:-300}"
    local resp
    resp=$(printf '%s' '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"acquire_file_lock","arguments":{"file":"'$file'","ttl_seconds":'$ttl'"}}}' | nc -U "$GATEWAY_SOCKET" 2>/dev/null)
    echo "$resp" | grep -q '"ok": true'
}

_gateway_lock_release() {
    local file="${1:-$REPO_LOCK_FILE}"
    printf '%s' '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"release_file_lock","arguments":{"file":"'$file'"}}}' | nc -U "$GATEWAY_SOCKET" 2>/dev/null >/dev/null
}

# Обязательный trap
trap '_gateway_lock_release "$REPO_LOCK_FILE" 2>/dev/null || true' EXIT ERR
```

### 2.2 TTL правила

| Агент | TTL | Примечание |
|---|---|---|
| code-scan | 300 с | Короткая операция |
| template-sync | 300 с | С возможностью retry |
| pull-repos | 300 с | Поочерёдно на каждое репо |
| overnight-auditor | 1800 с | Длинный аудит, возможно разбить на репо |
| synchronizer inbox-check | 300 с | + janitor коммитит пачкой |

**Требование:** если lock с TTL > 600 с держится дольше `expected_duration + 60 с` — алерт пилоту.

## 3. Разделение артефактов

Где агенты пишут — определяет git-статус и race-риск.

| Тип артефакта | Локация | Git | Commit policy |
|---|---|---|---|
| KE-вход (extraction-reports, captures) | `inbox/auto/` | tracked | Batch commit при human review (apply-captures) |
| Read-only (audit reports, dashboards) | `output/` + `.gitignore` | ignored | Не коммитится |
| Intermediate (stash, build, temp) | `/tmp/` или `.tmp/` | ignored | Удаляется после операции |
| Логи агентов | `logs/` + `.gitignore` | ignored | Ротация по размеру |

**janitor** — полноправный участник lock-протокола: берёт lock перед batch commit.

## 4. Cron spread (ночное окно)

| UTC | Агент | Репо/ресурс |
|---|---|---|
| 00:00 | pull-repos + code-scan | Все репо |
| 00:30 | template-sync | FMT-exocortex-template |
| 01:00 | overnight-auditor | Локальные репо (security scan) |
| 02:00 | synchronizer inbox-check | DS-agent-workspace inbox |
| 02:30 | apply-captures janitor | {{GOVERNANCE_REPO}} inbox/auto/ |

Минимальный gap: 30 минут между операциями на одном репо.

## 5. Circuit breaker (бот)

Для heavy команд (`/feed`, `/train`, `/setup_mode_sequential`):

```python
_HEAVY_SOFT_TIMEOUT = 3.0   # ответ пользователю "Обновляю данные..."
_HEAVY_HARD_TIMEOUT = 30.0  # abort + log error
```

Реализация: `handlers/commands.py::_safe_route_heavy()`
- `asyncio.wait_for(route_coro, 3.0)` → TimeoutError → answer("Обновляю...")
- background task → `asyncio.wait_for(task, 27.0)` → TimeoutError → log `heavy_timeout:<command>`
- Telegram retry подавляется: пользователь получил ответ, повторный запрос не нужен.

## 6. Деградированный режим

Если Gateway недоступен (socket отсутствует, daemon не запущен):
- Shell-скрипты: `flock -n` на репо-якорь (`<repo>/.git/index`) как fallback.
- MCP-агенты: `Bash(flock ...)` через инструмент.
- Логировать: `WARN: gateway unreachable, using flock fallback`.

## 7. Проверка при добавлении нового агента

Чеклист перед вводом агента в ночное окно:
1. [ ] Агент берёт Gateway lock перед записью в репо.
2. [ ] Агент пишет только в разрешённые директории (§3).
3. [ ] Агент имеет trap/release при аварийном завершении.
4. [ ] Cron-время согласовано с таблицей §4 (нет overlap на том же репо).
5. [ ] Длительность операции < TTL lock'а.

## 8. Связанные документы

- `memory/protocol-work.md` — общие правила работы агентов
- `docs/SCRIPT-PROMOTION.md` — как скрипты попадают в репо
- `docs/adr/` — архитектурные решения по координации
