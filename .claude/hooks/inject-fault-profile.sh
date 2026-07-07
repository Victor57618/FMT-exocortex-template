#!/bin/bash
# inject-fault-profile.sh
# Event: UserPromptSubmit
# Назначение: инжектировать профиль повторяющихся ошибок агента в системный промпт
#             ПЕРЕД первой работой в сессии. Замена секции «Профиль ошибок» в DayPlan
#             (которая показывалась пилоту — что неправильно: профиль для агента).
#
# Архитектура: вызывает scripts/agent_fault_remind.py --protocol open → парсит вывод
#             → возвращает additionalContext с топ-3 критическими напоминаниями.
#
# see: peer-сессия 2026-05-30-07-gap-list-day-open подэтап 3
# see: WP-356 «Pipeline Day Open: auto-run checks»
# see: WP-316 (Agent Fault Profile, источник данных)
#
# Поведение:
# - Активируется один раз в сессии (state-файл `.claude/state/fault-profile-injected-<session_id>`)
# - Если БД профиля отсутствует — silent skip
# - Если нет напоминаний с n≥3 — silent skip
# - Иначе — additionalContext с 2-3 напоминаниями

set -uo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"

INPUT=$(cat 2>/dev/null || echo '{}')
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$HOME/IWE}"
STATE_DIR="$PROJECT_DIR/.claude/state"
STATE_FILE="$STATE_DIR/fault-profile-injected-$SESSION_ID"

# Только один инжект в сессию
if [ -f "$STATE_FILE" ]; then
  echo '{}'
  exit 0
fi

REMIND_SCRIPT="$PROJECT_DIR/${IWE_GOVERNANCE_REPO:-DS-strategy}/scripts/agent_fault_remind.py"
if [ ! -f "$REMIND_SCRIPT" ]; then
  echo '{}'
  exit 0
fi

# Запустить скрипт (с timeout если есть, иначе без — на macOS нет timeout по умолчанию)
if command -v timeout >/dev/null 2>&1; then
  REMIND_OUT=$(timeout 5 python3 "$REMIND_SCRIPT" --protocol open 2>/dev/null || echo "")
elif command -v gtimeout >/dev/null 2>&1; then
  REMIND_OUT=$(gtimeout 5 python3 "$REMIND_SCRIPT" --protocol open 2>/dev/null || echo "")
else
  # Fallback без timeout — скрипт быстрый (sqlite-read)
  REMIND_OUT=$(python3 "$REMIND_SCRIPT" --protocol open 2>/dev/null || echo "")
fi
if [ -z "$REMIND_OUT" ]; then
  echo '{}'
  exit 0
fi

# Парсинг строк формата: "🔴 [CRITICAL | n=8] WP context читается bottom-up..."
# Берём топ-3 с n >= 3 (статистически значимо)
RELEVANT=$(echo "$REMIND_OUT" | grep -E "^🔴 \[(CRITICAL|MAJOR) \| n=[0-9]+\]" | head -3)
if [ -z "$RELEVANT" ]; then
  echo '{}'
  exit 0
fi

# Сформировать additionalContext
CONTEXT="## 🧠 Профиль повторяющихся ошибок агента (n≥3 за историю сессий)

Применить ДО первой Read/Write/Bash в сессии. Источник: \`agent_fault_remind.py --protocol open\` (база \`inbox/WP-316/f2-poc/iwe_memory.db\`).

$RELEVANT

Источник правил: WP-316 (Session Memory). Не показывать пользователю — это внутренний инструмент агента.
"

# Записать state-файл
mkdir -p "$STATE_DIR"
touch "$STATE_FILE"

# Cleanup старых state-файлов (>24h)
find "$STATE_DIR" -name "fault-profile-injected-*" -mmin +1440 -delete 2>/dev/null || true

# Вернуть JSON с additionalContext (Claude Code UserPromptSubmit hook protocol)
jq -n --arg ctx "$CONTEXT" '{
  "hookSpecificOutput": {
    "hookEventName": "UserPromptSubmit",
    "additionalContext": $ctx
  }
}'
