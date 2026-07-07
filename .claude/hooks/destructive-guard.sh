#!/usr/bin/env bash
# PreToolUse:Bash guard — blocks irreversible git operations regardless of flag order.
# Complements the global rm -rf blocker (which forces `trash`). Exit 2 = block.
set -euo pipefail

CMD=$(jq -r '.tool_input.command // empty' 2>/dev/null || true)
[ -z "$CMD" ] && exit 0

block() {
  echo "BLOCKED: $1" >&2
  exit 2
}

is_git_subcmd() {
  # git, optionally with -C <dir>, then the subcommand
  echo "$CMD" | grep -qE "(^|[;&|[:space:]])git([[:space:]]+-C[[:space:]]+[^[:space:]]+)?[[:space:]]+$1"
}

# git push --force / -f (allow the safe --force-with-lease)
if is_git_subcmd push; then
  if echo "$CMD" | grep -qE -- '(--force([[:space:]]|=|$)|(^|[[:space:]])-[a-zA-Z]*f([[:space:]]|$))' \
     && ! echo "$CMD" | grep -qE -- '--force-with-lease'; then
    block "git push --force запрещён. Используй --force-with-lease или согласуй с владельцем (CLAUDE.md §2)."
  fi
fi

# git reset --hard
if is_git_subcmd reset && echo "$CMD" | grep -qE -- '--hard'; then
  block "git reset --hard запрещён (теряет незакоммиченное). Используй git stash."
fi

# git clean with delete flags (-f/-d/-x)
if is_git_subcmd clean && echo "$CMD" | grep -qE -- '(^|[[:space:]])-[a-zA-Z]*[dfx]'; then
  block "git clean -fdx запрещён (удаляет неотслеживаемые файлы). Согласуй с владельцем."
fi

exit 0
