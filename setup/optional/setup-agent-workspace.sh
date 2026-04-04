#!/bin/bash
# Настройка Agent Workspace — отдельный репозиторий для данных агентов
#
# Зачем: Когда у тебя >2 автономных агента (Scout, Стратег, Экстрактор),
# их выходные данные засоряют DS-strategy. Agent Workspace отделяет
# машинный output (отчёты, находки, черновики) от человеческих решений
# (планы, утверждённые captures).
#
# Когда НЕ нужен:
# - У тебя пока нет автономных агентов (только Claude Code)
# - Все отчёты помещаются в DS-strategy/archive/
# - Ты только начинаешь работу с IWE
#
# Когда нужен:
# - Scheduler генерирует ежедневные отчёты
# - Scout/Extractor создают десятки файлов в месяц
# - Git history DS-strategy перегружена автокоммитами
#
# Что создаёт:
# 1. Приватный GitHub-репо DS-agent-workspace
# 2. Структуру папок для каждого типа агента
# 3. CLAUDE.md с инструкциями
#
# Использование:
#   bash setup/optional/setup-agent-workspace.sh

set -euo pipefail

echo "=== Настройка Agent Workspace ==="
echo ""
echo "Agent Workspace — отдельный репозиторий для данных автономных агентов."
echo "Это нужно когда агенты генерируют много файлов (отчёты, находки, черновики)."
echo ""
echo "Что будет создано:"
echo "  - Приватный GitHub-репо DS-agent-workspace"
echo "  - Структура: scheduler/, scout/, strategist/, extractor/, verifier/"
echo "  - Скрипты scheduler будут писать отчёты туда вместо DS-strategy/current/"
echo ""

# Проверки
if ! command -v gh &>/dev/null; then
    echo "❌ gh CLI не установлен. Установите: brew install gh"
    exit 1
fi

if ! gh auth status &>/dev/null; then
    echo "❌ gh CLI не авторизован. Выполните: gh auth login"
    exit 1
fi

WORKSPACE="${WORKSPACE_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
WORKSPACE_DIR="$WORKSPACE"

if [ -d "$WORKSPACE/DS-agent-workspace" ]; then
    echo "✅ DS-agent-workspace уже существует: $WORKSPACE/DS-agent-workspace"
    echo "Пропускаю создание."
    exit 0
fi

echo "Продолжить? (y/n)"
read -r CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "Отменено."
    exit 0
fi

echo ""
echo "→ Создаю репозиторий..."

# Определяем GitHub username
GH_USER=$(gh api user -q '.login')

cd "$WORKSPACE"

# Создаём репо
gh repo create "DS-agent-workspace" --private --clone --description "Agent workspace: output data from autonomous IWE agents"
cd DS-agent-workspace

# Создаём структуру
mkdir -p scheduler/reports/archive
mkdir -p scheduler/feedback-triage
mkdir -p scout/results
mkdir -p scout/trajectory
mkdir -p strategist
mkdir -p extractor/extraction-reports
mkdir -p verifier

# .gitkeep для пустых директорий
for dir in scheduler/reports/archive scheduler/feedback-triage scout/results scout/trajectory strategist extractor/extraction-reports verifier; do
    touch "$dir/.gitkeep"
done

# .gitignore
cat > .gitignore << 'GITIGNORE'
# Логи и временные файлы
logs/
*.log
.DS_Store
tmp/
*.tmp
GITIGNORE

# REPO-TYPE.md
cat > REPO-TYPE.md << 'REPOTYPE'
---
type: DS
subtype: governance
personal: true
source-of-truth: false
---

# DS-agent-workspace

Шина данных автономных агентов IWE. Хранит выходные артефакты (отчёты, находки, черновики).

**Различение:** Код агентов → DS-autonomous-agents. Данные → здесь. Решения → DS-strategy.

## Upstream

- DS-autonomous-agents (код, промпты, agent-cards)

## Downstream

- DS-strategy (утверждённые планы, captures)
- PACK-* (формализованные знания через Экстрактора)
REPOTYPE

# CLAUDE.md
cat > CLAUDE.md << 'CLAUDEMD'
# DS-agent-workspace — инструкции для Claude

> **Общие инструкции:** см. `CLAUDE.md` в корне workspace.
>
> Этот файл содержит только специфику данного репозитория.

---

## 1. Тип репозитория

**DS/governance** — шина данных автономных агентов IWE.

**Source-of-truth:** нет. Это производные данные, не первоисточник.

---

## 2. Назначение

Хранит **выходные артефакты** всех автономных агентов платформы:
- Черновики (DayPlan-draft, WeekPlan-draft)
- Отчёты (verify-report, extraction-report, scheduler-report)
- Находки (morning-ideas, capture-candidates, new-wp-proposals)
- QA бота (feedback-triage)

**Различение:** Код агентов → DS-autonomous-agents (instrument). Данные агентов → здесь (governance). Утверждённые решения → DS-strategy (governance).

---

## 3. Структура

```
DS-agent-workspace/
├── scheduler/                     ← Планировщик (cron/launchd)
│   ├── reports/
│   │   ├── SchedulerReport YYYY-MM-DD.md
│   │   └── archive/
│   └── feedback-triage/
│       └── YYYY-MM-DD.md
├── scout/                         ← Разведчик
│   ├── results/YYYY/MM/DD/
│   └── trajectory/
├── strategist/                    ← Стратег
├── extractor/                     ← Экстрактор
│   └── extraction-reports/
├── verifier/                      ← Верификатор
└── {new-agent}/                   ← будущие агенты
```

---

## 4. Конвенции

### Размещение
Каждый агент пишет ТОЛЬКО в свою папку. Cross-agent записи запрещены.

### Retention
- Результаты хранятся 30 дней
- Архивация при Week Close
- meta.yaml сохраняется для статистики

---

## 5. Связи

| Репозиторий | Роль |
|-------------|------|
| DS-autonomous-agents | Код агентов — производители |
| DS-strategy | Утверждённые решения — потребитель |
| PACK-* | Формализованные знания — конечный потребитель |
CLAUDEMD

# Первый коммит
git add -A
git commit -m "init: agent workspace structure (WP-176)"
git push -u origin main

echo ""
echo "✅ DS-agent-workspace создан: $WORKSPACE/DS-agent-workspace"
echo ""
echo "Скрипты scheduler автоматически начнут писать отчёты сюда"
echo "(проверка: daily-report.sh ищет DS-agent-workspace/.git)"
echo ""
echo "Готово!"
