#!/bin/bash
# load-extensions.sh — unified loader для suffix extensions (R4.4 fix, WP-273 Этап 2).
#
# Раньше каждый skill/loader читал точное имя файла (`extensions/day-close.after.md`,
# `extensions/protocol-close.checks.md`). Документация (extensions/README.md) обещает
# wildcard suffix loading (`day-close.after.health.md`, `day-close.after.linear.md`),
# но кода под это нет. Этот helper закрывает контракт: возвращает sorted list файлов
# по паттерну `<protocol>.<hook>*.md`.
#
# Usage:
#   bash load-extensions.sh <protocol> <hook>
#   bash load-extensions.sh day-close after
#   bash load-extensions.sh protocol-close checks
#
# Output: абсолютные пути к extension-файлам, по одному на строку, sorted.
# Exit: 0 — есть extensions; 1 — нет (skill пропускает шаг).
#
# Реализует contract из extensions/README.md:
#   "Suffix extensions (e.g. day-close.after.health.md, day-close.after.linear.md)
#    загружаются в алфавитном порядке."

set -eu

PROTOCOL="${1:-}"
HOOK="${2:-}"

if [ -z "$PROTOCOL" ] || [ -z "$HOOK" ]; then
    echo "Usage: load-extensions.sh <protocol> <hook>" >&2
    echo "Example: load-extensions.sh day-close after" >&2
    exit 2
fi

# Resolve workspace — пробуем несколько переменных, проверяя существование директории.
# Фикс bug-2026-05-14: ранее IWE_WORKSPACE мог указывать на несуществующую tmp-директорию
# (остаток smoke-test), и fallback не срабатывал из-за лишнего dirname.
resolve_workspace() {
    local candidates=("${IWE_WORKSPACE:-}" "${WORKSPACE_DIR:-}" "${IWE_ROOT:-}" "${IWE:-}")
    for c in "${candidates[@]}"; do
        [ -n "$c" ] && [ -d "$c/extensions" ] && { echo "$c"; return 0; }
    done

    # Fallback: определяем директорию скрипта через BASH_SOURCE[0] (надёжнее $0).
    local script_source="${BASH_SOURCE[0]:-$0}"
    local script_dir
    script_dir="$(cd "$(dirname "$script_source")" && pwd)"
    # script_dir = .../IWE/.claude/scripts  →  workspace = .../IWE
    local ws
    ws="$(dirname "$(dirname "$script_dir")")"
    [ -d "$ws/extensions" ] && { echo "$ws"; return 0; }

    return 1
}

WORKSPACE="$(resolve_workspace)"

EXT_DIR="$WORKSPACE/extensions"
[ -d "$EXT_DIR" ] || { exit 1; }

# Glob pattern: <protocol>.<hook>.md OR <protocol>.<hook>.<suffix>.md
# Examples for protocol=day-close hook=after:
#   day-close.after.md
#   day-close.after.health.md
#   day-close.after.linear.md
FOUND=$(find -L "$EXT_DIR" -maxdepth 1 \( -type f -name "${PROTOCOL}.${HOOK}.md" -o -name "${PROTOCOL}.${HOOK}.*.md" \) 2>/dev/null | while IFS= read -r f; do [ -e "$f" ] && echo "$f"; done | sort)

if [ -z "$FOUND" ]; then
    exit 1
fi

echo "$FOUND"
exit 0
