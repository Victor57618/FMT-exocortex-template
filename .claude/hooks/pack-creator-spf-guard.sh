#!/usr/bin/env bash
# routing: hook  see DP.SC.048, DP.ROLE.062
# Pre-tool-use guard: блокирует Write/Edit на путях SPF/, FPF/ когда активна
# сессия скилла /pack-creator. Fail-safe от усталости (DP.ROLE.062 §FM.02).
#
# Срабатывает только если переменная окружения PACK_CREATOR_ACTIVE=1.
# Иначе — pass-through (другие скиллы не блокируются).
#
# Exit codes:
#   0 — действие разрешено
#   2 — действие заблокировано (PreToolUse contract — Claude получит ошибку)

set -uo pipefail

# Если не в режиме pack-creator — pass-through
if [ "${PACK_CREATOR_ACTIVE:-0}" != "1" ]; then
    exit 0
fi

# Читаем PreToolUse JSON из stdin (Claude Code formal contract)
# Парсим целиком (вход может быть в одну или несколько строк).
TOOL_NAME=""
FILE_PATH=""
PAYLOAD=$(cat)

case "$PAYLOAD" in
    *'"tool_name"'*)
        TOOL_NAME=$(printf '%s' "$PAYLOAD" | sed -E 's/.*"tool_name":[[:space:]]*"([^"]+)".*/\1/' | head -n1)
        ;;
esac
case "$PAYLOAD" in
    *'"file_path"'*)
        FILE_PATH=$(printf '%s' "$PAYLOAD" | sed -E 's/.*"file_path":[[:space:]]*"([^"]+)".*/\1/' | head -n1)
        ;;
esac

# Защищаем только Write/Edit/MultiEdit/NotebookEdit
case "$TOOL_NAME" in
    Write|Edit|MultiEdit|NotebookEdit) ;;
    *) exit 0 ;;
esac

# Проверяем path на блокируемые директории
IWE_HOME="${HOME}/IWE"
case "$FILE_PATH" in
    "$IWE_HOME"/SPF/*|"$IWE_HOME"/FPF/*)
        cat >&2 <<EOF
🚫 BLOCKED by pack-creator-spf-guard (DP.ROLE.062 §FM.02)

Write в upstream-локацию запрещён в режиме /pack-creator:
  $FILE_PATH

Это нарушит upgrade SPF при update.sh. Используй extension-механизм:
  → PACK-X/pack/X/<соответствующий-раздел>/

Подробнее: SPF/process/00-process-overview.md#extension-mechanism

Если изменение системного характера (касается всех Pack) — это отдельный
РП на правку SPF, а не работа /pack-creator. См. SPF/CLAUDE.md §8.1.
EOF
        exit 2
        ;;
esac

exit 0
