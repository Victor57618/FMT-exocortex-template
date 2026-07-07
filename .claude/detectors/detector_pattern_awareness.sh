#!/bin/bash
# detector_pattern_awareness.sh
# see DP.SC.025 (capture-bus service clause), DP.ROLE.001#R47 (Детектор)
# event_type: agent_incident
# cost_class: free (rule-based, grep на содержимое файла)
# runtime: shell
# triggers: PostToolUse
#
# WP-217 Ф8.5. Детектирует паттерн P1 (DP.FM.011): запись нового правила
# в feedback_*.md без ссылки на паттерн каталога DP.FM.010.
#
# Логика:
#   1. Срабатывает на Write/Edit/MultiEdit в файл matching feedback_*.md.
#   2. Читает содержимое файла после записи.
#   3. Проверяет последний добавленный блок на наличие:
#      - поля "pattern: P{N}" (явная ссылка)
#      - или цитаты "DP.FM." (ссылка на каталог)
#   4. Если ссылки нет — emit agent_incident с pattern=P1_not_capturing.
#   5. НИКОГДА не блокирует (exit 0). Принцип warn-before-block.
#
# Heuristic: смотрим на "свежие" строки файла (последние 30 строк после write),
# т.к. правила добавляются в конец файла. Это v1 — без diff, без git blame.
# v2: использовать tool_input.old_string/new_string из Edit-события.

set -uo pipefail
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"

INPUT=$(cat)
if [ -z "$INPUT" ]; then
  exit 0
fi

HOOK_EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# Только PostToolUse
[ "$HOOK_EVENT" != "PostToolUse" ] && exit 0

# Только Write / Edit / MultiEdit
case "$TOOL_NAME" in
  Write|Edit|MultiEdit) ;;
  *) exit 0 ;;
esac

# Только feedback_*.md файлы
if [ -z "$FILE_PATH" ]; then
  exit 0
fi

BASENAME=$(basename "$FILE_PATH")
if [[ "$BASENAME" != feedback_*.md ]]; then
  exit 0
fi

# Файл должен существовать и быть читаемым
if [ ! -f "$FILE_PATH" ] || [ ! -r "$FILE_PATH" ]; then
  exit 0
fi

# ── Определяем target_repo ───────────────────────────────────────────────────
# Load unified environment: WORKSPACE_DIR, IWE_ROOT, IWE_SCRIPTS, etc.
DETECTOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$(cd "$DETECTOR_DIR/.." && pwd)"
# shellcheck source=../lib/iwe-env-bootstrap.sh
source "$CLAUDE_DIR/lib/iwe-env-bootstrap.sh" || exit 1
TARGET_REPO_HINT=""

if [[ "$FILE_PATH" == /* ]]; then
  DIR=$(dirname "$FILE_PATH")
  if [ -d "$DIR" ]; then
    DIR_REAL=$(cd "$DIR" 2>/dev/null && pwd -P)
    BASENAME_FILE=$(basename "$FILE_PATH")
    FILE_PATH="$DIR_REAL/$BASENAME_FILE"
    GIT_ROOT=$(cd "$DIR_REAL" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null || true)
    if [ -n "$GIT_ROOT" ]; then
      TARGET_REPO_HINT="$GIT_ROOT"
    fi
  fi
fi

if [ -z "$TARGET_REPO_HINT" ] && [ -n "$CWD" ]; then
  if [[ "$CWD" == "$IWE_ROOT"/* ]]; then
    REL="${CWD#$IWE_ROOT/}"
    FIRST_SEG="${REL%%/*}"
    if [ -n "$FIRST_SEG" ] && [ -d "$IWE_ROOT/$FIRST_SEG" ]; then
      TARGET_REPO_HINT="$IWE_ROOT/$FIRST_SEG"
    fi
  fi
fi

# OwnerIntegrity: не угадываем репо
if [ -z "$TARGET_REPO_HINT" ]; then
  exit 0
fi

# ── Проверка на ссылку паттерна ──────────────────────────────────────────────
# Смотрим последние 30 строк файла (heuristic: правило добавлено в конец).
# Ищем признаки явной ссылки на паттерн:
#   - "pattern: P" (frontmatter-style или inline)
#   - "DP.FM." (ссылка на каталог)
#   - "P1" / "P2" / ... "P10" как отдельное слово (слабый маркер)

TAIL_CONTENT=$(tail -30 "$FILE_PATH" 2>/dev/null || true)

if [ -z "$TAIL_CONTENT" ]; then
  exit 0
fi

# Сильные признаки наличия ссылки → НЕ emit
if echo "$TAIL_CONTENT" | grep -qiE '(pattern:\s*P[0-9]|DP\.FM\.[0-9])'; then
  exit 0
fi

# Слабые признаки (самодостаточные слова P1..P10) → НЕ emit
# Паттерн: P{N} как отдельное слово (не P1a, не P10x).
# BSD grep не поддерживает \b, используем ERE с пробелами/началом/концом строки.
if echo "$TAIL_CONTENT" | grep -qE '(^|[[:space:]])P([1-9]|10)([[:space:],\.)]|$)'; then
  exit 0
fi

# ── Emit P1_not_capturing ────────────────────────────────────────────────────
# Последние 200 символов содержимого как контекст
# tr -d control chars: предотвращает jq parse error из-за \r, \0, etc.
SNIPPET=$(tail -10 "$FILE_PATH" 2>/dev/null | tr -d '\000-\037' | head -c 200 || true)

jq -n \
  --arg pattern "P1_not_capturing" \
  --arg severity "minor" \
  --arg description "Write в ${BASENAME} без ссылки на паттерн (pattern: P{N} / DP.FM.). Проверь DP.FM.010 перед записью нового правила (DP.FM.011 §Correction)." \
  --arg file_path "$FILE_PATH" \
  --arg tool_name "$TOOL_NAME" \
  --arg snippet "$SNIPPET" \
  --arg hint "$TARGET_REPO_HINT" \
  '{
    event_type: "agent_incident",
    payload: {
      pattern: $pattern,
      severity: $severity,
      description: $description,
      tool_context: {
        tool_name: $tool_name,
        file_path: $file_path,
        snippet: $snippet
      }
    },
    repo_ctx: {
      target_repo_hint: $hint
    }
  }'

exit 0
