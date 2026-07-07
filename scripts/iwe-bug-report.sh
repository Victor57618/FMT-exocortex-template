#!/bin/bash
# iwe-bug-report.sh — обёртка для скилла /iwe-bug-report
# Использование: ./iwe-bug-report.sh "описание проблемы"

set -e

PROBLEM="$*"

if [ -z "$PROBLEM" ]; then
  echo "Использование: $0 \"описание проблемы\""
  exit 1
fi

# Путь к FMT-шаблону
FMT_PATH="${IWE_FMT_PATH:-$HOME/IWE/FMT-exocortex-template}"
if [ ! -d "$FMT_PATH" ]; then
  echo "Ошибка: FMT не найден. Установи IWE_FMT_PATH или проверь ~/IWE/FMT-exocortex-template"
  exit 1
fi

# Проверка gh CLI
if ! command -v gh &> /dev/null; then
  echo "Ошибка: gh CLI не установлен. Установи: brew install gh && gh auth login"
  exit 1
fi

if ! gh auth status &> /dev/null; then
  echo "Ошибка: gh не авторизован. Выполни: gh auth login"
  exit 1
fi

# Получить версию IWE
IWE_VERSION=$(cd "$FMT_PATH" && git log -1 --format="%h %ad" --date=short 2>/dev/null || echo "неизвестно")

# Категории (простое определение по ключевым словам)
CATEGORY="enhancement"  # дефолт
if echo "$PROBLEM" | grep -iq "ошибка\|крашится\|упало\|не работает"; then
  CATEGORY="bug"
elif echo "$PROBLEM" | grep -iq "документация\|описание\|readme"; then
  CATEGORY="docs"
fi

# Заголовок (первые 80 символов с учётом префикса категории)
PREFIX="[$CATEGORY] "
MAX_LEN=$((80 - ${#PREFIX}))
TITLE="${PREFIX}${PROBLEM:0:$MAX_LEN}"

# Дата
DATE=$(date +%Y-%m-%d)

# Создать issue
echo "📝 Создаю issue в FMT-exocortex-template..."

BODY=$(cat <<BODY
## Что произошло

$PROBLEM

## Контекст

- Дата: $DATE
- IWE commit: $IWE_VERSION
BODY
)

if OUTPUT=$(gh issue create \
  --repo TserenTserenov/FMT-exocortex-template \
  --title "$TITLE" \
  --label "$CATEGORY" \
  --body "$BODY" 2>&1); then
  echo "✅ Issue создан:"
  echo "$OUTPUT"
else
  echo "❌ Ошибка при создании issue:"
  echo "$OUTPUT"
  exit 1
fi
