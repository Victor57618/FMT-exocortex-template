#!/usr/bin/env bash
# SessionStart — verify `trash` is installed (safe-delete policy: never rm -rf).
# Non-blocking: prints a warning to context if missing, so the user can install it.
set -euo pipefail

if ! command -v trash >/dev/null 2>&1; then
  echo "⚠️ 'trash' не установлен — политика безопасного удаления (вместо rm -rf) не работает. Установка: sudo pacman -S trash-cli" >&2
fi

exit 0
