# IWE — Intelligent Working Environment

> Персональная среда для интеллектуальной работы и развития с ИИ-агентами.

Ты проходишь курсы. Бот помогает каждый день. Но знания остаются в голове, планы — в заметках, а контекст теряется между сессиями.

**IWE** — это интеллектуальная рабочая среда, где Claude помогает планировать неделю, фиксировать знания и строить собственную базу. Как IDE объединяет редактор, компилятор и дебаггер в одну среду для программиста — так IWE объединяет знания, планирование и ИИ-агентов в одну среду для мышления.

> **Ключевой принцип: экзоскелет, не протез.** IWE усиливает ваше мышление, а не заменяет его. После взаимодействия с IWE вы стали компетентнее, а не только получили результат.

---

## Почему IWE, а не просто…

| Сравнение | Что меняет IWE |
|-----------|----------------|
| **Просто ИИ-агент** | Агент заменяет исполнителя. IWE усиливает мыслителя. Stateless → Stateful |
| **Просто экзокортекс** | Экзокортекс = память + инструкции (часть IWE). IWE = 4 архитектурных вида |
| **Second brain (Notion)** | Пассивное хранилище → Активная среда с агентами. Нет методологии → Встроенная методология |
| **Claude Code без IWE** | Без экзокортекса контекст сбрасывается каждую сессию. Без Pack знания не накапливаются |
| **Книги/курсы** | Знания в голове деградируют. IWE формализует их в Pack и применяет через протоколы |

---

## Анатомия IWE: четыре архитектурных вида

IWE описывается через четыре ортогональных вида (ISO/IEC/IEEE 42010), а не плоский список «компонентов»:

```
┌─────────────────────────────────────────────────────┐
│           Intelligent Working Environment            │
│                                                      │
│  Системы (что работает)        Claude Code, бот,     │
│                                MCP, Git, WakaTime    │
│                                                      │
│  Описания (чем руководствуется) Экзокортекс          │
│                                (CLAUDE.md + memory/),│
│                                Pack, промпты агентов  │
│                                                      │
│  Роли (кто что делает)         Стратег, Экстрактор,  │
│                                Синхронизатор, Человек │
│                                                      │
│  Артефакты (что производится)  DS-strategy/, Pack-,   │
│                                DS-проекты, ЦД        │
└─────────────────────────────────────────────────────┘
```

| Вид | Что | Тест |
|-----|-----|------|
| **Системы** | Claude Code CLI, бот, MCP-серверы, Git | Можно запустить / остановить? |
| **Описания** | Экзокортекс, Pack-сущности, методология, промпты | Можно прочитать / обновить? |
| **Роли** | Стратег, Экстрактор, Синхронизатор, Пользователь | Какие обязательства и продукты? |
| **Артефакты** | DS-strategy, Pack-репо, проекты, цифровой двойник | Можно показать заказчику? |

> Подробнее: [LEARNING-PATH.md § 1.2](docs/LEARNING-PATH.md)

---

## Как это выглядит на практике

- Утром — получаешь план дня в Telegram (Стратег составил его ночью)
- Открываешь VS Code → `claude` → Claude знает, что в плане, и предлагает начать с приоритетного
- Работаешь — Claude фиксирует знания по ходу (Capture-to-Pack)
- Закрываешь сессию — результат зафиксирован, план обновлён
- В понедельник — Стратег готовит черновик недельного плана, вы обсуждаете его на сессии стратегирования

---

## Экзокортекс: 3-слойная память

Экзокортекс — вид «Описания» внутри IWE. Это то, что делает Claude **стейтфулным**: он помнит контекст между сессиями.

```
Слой 1: MEMORY.md (≤100 строк, авто-загрузка)
├─ Блокирующие правила
├─ Задачи недели (РП)
└─ Навигация

Слой 2: CLAUDE.md (≤300 строк, авто-загрузка)
├─ Архитектура репозиториев
├─ Стадии сессии (Open → Work → Close)
└─ АрхГейт, Capture-to-Pack

Слой 3: memory/*.md (≤10 файлов, по запросу)
├─ Различения, SOTA, чеклисты
├─ Протоколы (open/work/close)
└─ Навигация, FPF-справочник
```

**Standard vs Personal:** Протоколы и промпты (standard) обновляются из upstream. Ваши планы, память и стратегия (personal) — только у вас.

> **Первая установка?** [SETUP-GUIDE.md](docs/SETUP-GUIDE.md) — пошаговое руководство от чистого компьютера (30-60 мин).
> **Политика данных:** [DATA-POLICY.md](docs/DATA-POLICY.md) — какие данные собираются, где хранятся, как удалить.
> **Путь изучения:** [LEARNING-PATH.md](docs/LEARNING-PATH.md) — принципы, протоколы, агенты, Pack, SOTA.
> **Быстрая справка / FAQ:** [IWE-HELP.md](docs/IWE-HELP.md) — то же, что знает бот @aist_me_bot.
> **Почему принципы, а не навыки?** [principles-vs-skills.md](docs/principles-vs-skills.md) — аргументация и генеративная иерархия.

---

## Быстрый старт

### Требования

Два режима установки: **core** (минимальный, офлайн) и **full** (полный, с автоматизацией).

| Инструмент | Core | Full | Проверить | Установить |
|-----------|:----:|:----:|-----------|-----------|
| **ОС** | ✓ | ✓ | macOS, Linux, Windows (WSL) | — |
| **Git** | ✓ | ✓ | `git --version` | macOS: `xcode-select --install` / Linux: `sudo apt install git` |
| **AI CLI** | ✓ | ✓ | Любой: Claude Code, Codex, Aider и др. | См. таблицу совместимости ниже |
| **VS Code** | ✓ | ✓ | `code --version` | [code.visualstudio.com](https://code.visualstudio.com) |
| GitHub CLI | — | ✓ | `gh --version` | macOS: `brew install gh` / Linux: [cli.github.com](https://cli.github.com/) |
| GitHub аккаунт | — | ✓ | `gh auth status` | `gh auth login` |
| Node.js | — | ✓ | `node --version` | Только если AI CLI = Claude Code |
| WakaTime | — | — | `wakatime-cli --version` | Опционально. `/setup-wakatime` в Claude Code |

### Совместимость с AI CLI

Ядро IWE (CLAUDE.md, memory/, промпты) — это markdown-файлы. Они работают с **любым** AI CLI, который умеет читать файлы в рабочей директории.

| AI CLI | Интерактивная работа | Автоматизация (Стратег) | MCP-серверы | Примечание |
|--------|:-------------------:|:----------------------:|:-----------:|------------|
| **Claude Code** (рекомендуемый) | Полная | Полная | Да | Hooks, skills, settings. `npm install -g @anthropic-ai/claude-code` |
| **Codex** (OpenAI) | Работает | Через `AI_CLI=codex` | Нет | `npm install -g @openai/codex` |
| **Aider** | Работает | Через `AI_CLI=aider` | Нет | `pip install aider-chat`. Флаг: `AI_CLI_PROMPT_FLAG=--message` |
| **Continue.dev** | Работает | Нет | Частично | VS Code extension. Нет CLI для автоматизации |
| **Cursor** | Работает | Нет | Нет | Встроенный AI. Читает CLAUDE.md как project rules |

> **Как переключить AI CLI для автоматизации Стратега:**
> ```bash
> # По умолчанию — Claude Code (ничего менять не нужно)
> bash roles/strategist/scripts/strategist.sh morning
>
> # Codex
> AI_CLI=codex AI_CLI_PROMPT_FLAG=-p AI_CLI_EXTRA_FLAGS="" bash roles/strategist/scripts/strategist.sh morning
>
> # Aider
> AI_CLI=aider AI_CLI_PROMPT_FLAG=--message AI_CLI_EXTRA_FLAGS="" bash roles/strategist/scripts/strategist.sh morning
> ```

> **WakaTime** трекает время работы: по проектам, категориям (AI Coding, Coding, Writing Docs), редакторам. Бесплатный план: статистика за 2 недели. Данные используются Стратегом в Week Review и Morning Check. **Настройка:** `/setup-wakatime` в Claude Code. Подробнее: [wakatime.com](https://wakatime.com).

> **Автоматизация Стратега:** на macOS — launchd (устанавливается автоматически при полной установке). На Linux — настройте cron вручную (`crontab -e`). Без автоматизации всё работает — Стратег запускается вручную: `bash roles/strategist/scripts/strategist.sh morning`

### Шаг 0: Создать рабочую папку

Создайте на своём компьютере **одну папку** для всех репозиториев — текущих и будущих. Все репозитории IWE (шаблон, стратегия, Pack, проекты) должны находиться в одной общей папке. По умолчанию это `~/IWE`:

```bash
mkdir -p ~/IWE
```

> **Важно:** Эта папка — ваше рабочее пространство. В неё будут клонироваться все репозитории: `FMT-exocortex-template/`, `DS-strategy/`, `PACK-{область}/`, `DS-{проекты}/` и др. CLAUDE.md тоже будет лежать в корне этой папки. Название может быть любым, но все репо должны быть в одном месте — Claude Code ориентируется на эту структуру.

### Шаг 1: Клонировать и запустить установку

**Вариант A: Полная установка (~5 мин)** — git + GitHub + Claude Code + автоматизация Стратега:

```bash
cd ~/IWE
gh repo fork TserenTserenov/FMT-exocortex-template --clone --remote
cd FMT-exocortex-template
bash setup.sh
```

**Вариант B: Минимальная установка (~2 мин)** — только git, без сети, любой AI CLI:

```bash
cd ~/IWE
git clone https://github.com/TserenTserenov/FMT-exocortex-template.git
cd FMT-exocortex-template
bash setup.sh --core
```

Скрипт спросит:
- GitHub username (можно пропустить в core-режиме)
- Рабочую директорию (по умолчанию — родительская папка шаблона)
- Путь к Claude CLI и часовой пояс (только в полном режиме)

<details>
<summary>Что делает setup.sh</summary>

1. Проверяет prerequisites (git, gh, claude)
2. Показывает политику данных и запрашивает согласие ([DATA-POLICY.md](docs/DATA-POLICY.md))
3. Заменяет 7 плейсхолдеров (`{{GITHUB_USER}}`, `{{WORKSPACE_DIR}}` и др.)
4. Копирует `CLAUDE.md` → корень рабочей директории
5. Копирует `memory/*.md` → `~/.claude/projects/.../memory/`
6. Устанавливает launchd-агентов для Стратега
7. Создаёт `DS-strategy/` — приватный репозиторий для стратегирования

Посмотреть без выполнения: `bash setup.sh --dry-run`
</details>

### Шаг 2: Проверить установку

```bash
# Проверить файлы
ls ~/IWE/CLAUDE.md
ls ~/.claude/projects/*/memory/

# Проверить launchd
launchctl list | grep strategist

# Проверить DS-strategy
ls ~/IWE/DS-strategy/
```

### Шаг 3: Первая сессия (~30 мин)

```bash
cd ~/IWE
claude
```

Скажи Claude: **«Проведём первую стратегическую сессию»**

Claude прочитает CLAUDE.md и memory/ и проведёт тебя через:
1. **Определение целей** — Кем ты хочешь быть через год? Чему научиться?
2. **Неудовлетворённости** — Что мешает? Где разрыв между текущим и желаемым?
3. **Первый WeekPlan** — Конкретные задачи на неделю с бюджетами времени
4. **Обновление MEMORY.md** — Твои РП появятся в таблице

После этого Claude в каждой сессии будет видеть твой план и работать по нему.

<details>
<summary>Ручная настройка (если setup.sh не подходит)</summary>

1. Замените `{{GITHUB_USER}}` на ваш GitHub username во всех файлах
2. Замените `{{WORKSPACE_DIR}}` на путь к рабочей директории (напр. `~/IWE`)
3. Замените `{{HOME_DIR}}` на домашнюю директорию (значение `$HOME`)
4. Замените `{{CLAUDE_PROJECT_SLUG}}` на путь через дефисы (напр. для `~/IWE` → `-Users-yourname-IWE`)
5. Замените `{{TIMEZONE_HOUR}}` на час запуска стратега в UTC (напр. `4` для 7:00 MSK)
6. Замените `{{TIMEZONE_DESC}}` на описание времени (напр. `7:00 MSK`)
7. Замените `{{CLAUDE_PATH}}` на путь к Claude CLI (напр. `/opt/homebrew/bin/claude`)
8. Установите launchd-агентов: `cd roles/strategist && bash install.sh`
9. Скопируйте `memory/` в `~/.claude/projects/.../memory/`
10. Скопируйте `CLAUDE.md` в корень рабочей директории

</details>

---

## Обновления

Протоколы, промпты и справочники обновляются в upstream. Твои личные данные (планы, MEMORY.md, стратегия) **не затрагиваются**.

```bash
cd ~/IWE/FMT-exocortex-template
bash update.sh
```

| Команда | Что делает |
|---------|-----------|
| `bash update.sh` | Скачивает обновления из upstream, применяет к стандартным файлам |
| `bash update.sh --check` | Показать доступные обновления без применения |
| `bash update.sh --dry-run` | Показать что изменится, не применять |

**Что обновляется (standard):** CLAUDE.md, memory/*.md (кроме MEMORY.md), промпты Стратега.
**Что НЕ трогается (personal):** MEMORY.md (твои РП), DS-strategy/ (твои планы).

---

## От шаблона к рабочему пространству

### Что происходит при setup.sh

```
FMT-exocortex-template/                    ~/IWE/ (твоё рабочее пространство)
│                                           │
├── CLAUDE.md            ──── копия ────→   ├── CLAUDE.md
├── memory/*.md          ──── копия ────→   ├── ~/.claude/projects/.../memory/
│   └── MEMORY.md (скелет)                  │   └── MEMORY.md (★ твой, пустой)
│                                           │
├── roles/strategist/   ── install.sh ──→  ├── ~/Library/LaunchAgents/ (расписание)
│                                           │
├── seed/strategy/       ── создаёт репо ─→ ├── DS-strategy/ (★ отдельный приватный репо)
│                                           │
└── (остаётся как fork)                     ├── FMT-exocortex-template/ (НЕ трогать)
                                            ├── PACK-{область}/ (когда создашь)
                                            └── DS-{проекты}/ (когда создашь)
```

> **Ключевое:** `seed/strategy/` — заготовка. При setup она становится **отдельным приватным репозиторием** `DS-strategy/` на GitHub. После setup связь с seed/ разрывается — DS-strategy живёт своей жизнью.

### Как работают обновления

```
Платформа (upstream)                     Ты (downstream)

FMT-exocortex-template ──── update.sh ──→ Твой fork (git merge)
(автор обновляет)              │
                               ├──→ CLAUDE.md       → ~/IWE/CLAUDE.md
                               ├──→ memory/*.md     → ~/.claude/projects/.../
                               │    (MEMORY.md НЕ трогается!)
                               └──→ roles/prompts/ → остаются в fork

DS-strategy/     ← НЕ затрагивается (отдельный репо)
PACK-{область}/  ← НЕ затрагивается (твой репо)
MEMORY.md        ← НЕ затрагивается (твои данные)
```

---

## Контуры и тиры

### Четыре контура (L1–L4)

IWE существует на нескольких организационных уровнях:

```
L1: Экосистема       ← Платформа + сообщество + все IWE
  └─ L2: Платформа   ← Инфраструктура (бот, MCP, Knowledge Index)
    └─ L3: Шаблон    ← FMT-exocortex-template (общий чертёж, update.sh)
      └─ L4: Личный IWE ← Ваш экземпляр (git clone + setup.sh → персонализация)
```

### Пять тиров (T1–T5)

Платформа растёт вместе с тобой. Каждый тир разблокирует новую функциональность.

| | T1: Старт | T2: Изучение | T3: Персонализация | T4: Созидание (IWE) | T5: Администрирование |
|---|---|---|---|---|---|
| **Вход** | /start в боте (5 мин) | Подписка на программу | Заполнить Digital Twin (20 мин) | setup.sh (10 мин) | Владелец платформы |
| **ИИ-роль** | Ассистент | Эксперт | Наставник | Со-мыслитель | Архитектор |
| **Бот** | Марафон, Лента | + Руководства, Программы | + Персональные ответы | Всё из T3 + Claude Code | Всё из T4 |
| **Рабочее пространство** | Только бот | Бот + контент | + Digital Twin | + Git + Claude Code + Стратег + WakaTime | + исходный код + деплой |
| **Знания** | Поиск по базе | + полный доступ к гайдам | + персонализация | + свои Pack и DS | + управление standard/ |

---

## Создание первого Pack

Когда ты определишь область знаний, которую хочешь формализовать — создай свой первый Pack.

### Когда создавать

- Ты регулярно работаешь в одной области (управление проектами, ML, продуктовый дизайн...)
- Тебе важно не терять знания между сессиями
- Ты хочешь, чтобы Claude знал термины и паттерны твоей области

### Как создать

```bash
# 1. Клонируй SPF (структура Pack, read-only reference)
gh repo clone TserenTserenov/SPF ~/IWE/SPF

# 2. Создай Pack из шаблона
cp -r ~/IWE/SPF/pack-template ~/IWE/PACK-my-domain
cd ~/IWE/PACK-my-domain
git init && git add -A && git commit -m "Initial Pack: my-domain"
gh repo create PACK-my-domain --private --source=. --push
```

Затем откройте Claude Code в этом репо — он прочитает шаблон и поможет заполнить:
- `00-pack-manifest.md` — метаданные области
- `01-domain-contract/` — границы, различения, онтология
- `02-domain-entities/` — роли, объекты, методы

---

## Репозитории пользователя

### Создаются автоматически (setup.sh)

| Репо | Тип | Что это |
|------|-----|---------|
| **FMT-exocortex-template/** | Format | Форк шаблона IWE (источник обновлений, CLAUDE.md, memory/, Стратег) |
| **DS-strategy/** | DS/governance | Стратегический хаб: WeekPlan, DayPlan, inbox, стратегия |

### Создаёшь сам (когда готов)

| Репо | Тип | Когда создавать |
|------|-----|----------------|
| **PACK-{твоя-область}/** | Pack | Определил область знаний для формализации |
| **DS-{твой-проект}/** | DS/instrument | Начал строить систему на основе Pack |

### Read-only reference (клонируешь при необходимости)

| Репо | Когда нужен |
|------|-------------|
| [SPF](https://github.com/TserenTserenov/SPF) | Создаёшь первый Pack |
| [FPF](https://github.com/TserenTserenov/FPF) | Углублённое изучение принципов |
| [ZP](https://github.com/TserenTserenov/ZP) | Нулевые принципы (6 ограничений) |
| [PACK-digital-platform](https://github.com/TserenTserenov/PACK-digital-platform) | Живой пример Pack (40+ сущностей) |

> **Принцип:** Начни с минимума (2 репо: FMT-exocortex-template + DS-strategy). Добавляй по мере роста.

---

## Структура

```
FMT-exocortex-template/
│
├── CLAUDE.md                        # Правила для Claude Code (протоколы, архитектура)
├── README.md                        # Этот файл
├── REPO-TYPE.md                     # Тип репозитория (Format)
├── ONTOLOGY.md                      # Онтология IWE
├── update.sh                        # Обновление из upstream
│
├── memory/                          # Оперативная память (≤10 файлов, ≤100 строк каждый)
│   ├── MEMORY.md                    # ★ PERSONAL: задачи недели, навигация (авто-загрузка)
│   ├── protocol-open.md             # Протокол открытия сессии
│   ├── protocol-work.md             # Протокол работы
│   ├── protocol-close.md            # Протокол закрытия сессии
│   ├── navigation.md                # Навигация по репозиториям
│   ├── hard-distinctions.md         # Жёсткие различения
│   ├── fpf-reference.md             # Первые принципы (FPF)
│   ├── checklists.md                # Чеклисты
│   ├── sota-reference.md            # SOTA-практики
│   └── repo-type-rules.md           # Правила по типам репозиториев
│
├── docs/                            # Справочная документация
│   ├── SETUP-GUIDE.md               # Пошаговое руководство установки
│   ├── LEARNING-PATH.md             # Путь изучения IWE
│   ├── IWE-HELP.md                  # Справочник IWE для бота (FAQ, глоссарий)
│   ├── DATA-POLICY.md               # Политика данных IWE
│   ├── principles-vs-skills.md      # Почему принципы, а не навыки
│   └── adr/                         # Architecture Decision Records
│
├── roles/                           # Роли (точка расширения)
│   ├── strategist/                  # Роль: Стратег (R1)
│   │   ├── install.sh
│   │   ├── prompts/                 # 9 сценариев
│   │   └── scripts/                 # Скрипты запуска + launchd plist
│   ├── extractor/                   # Роль: Экстрактор знаний (R2)
│   └── synchronizer/                # Роль: Синхронизатор (R8)
│
├── seed/                            # Шаблоны → отдельные репо после setup
│   └── strategy/                    # → DS-strategy/ (стратегический хаб)
│
└── .claude/                         # Конфигурация Claude Code
    ├── settings.local.json          # MCP-серверы + разрешения
    ├── hooks/wakatime-heartbeat.sh  # WakaTime heartbeat
    └── skills/setup-wakatime.md     # /setup-wakatime
```

### Зоны

| Зона | Что | update.sh | Пользователь |
|------|-----|-----------|-------------|
| **PLATFORM** | `memory/*.md` (кроме MEMORY.md), `roles/`, `docs/`, `.claude/` | Обновляет | Не трогает |
| **PERSONAL** | `memory/MEMORY.md` | Не трогает | Редактирует каждую сессию |
| **SEED** | `seed/strategy/` | N/A | После setup → отдельный репо DS-strategy/ |
| **ROOT** | `CLAUDE.md`, `README.md`, `ONTOLOGY.md` | CLAUDE.md обновляет | Читает |

---

## Принципы

1. **Экзоскелет, не протез** — IWE усиливает мышление, а не заменяет. Три механизма: предъявление (а не генерация), вопросы (а не ответы), убывающие подмостки
2. **Standard vs Personal** — протоколы (standard) обновляются из upstream. Ваши планы и память (personal) — только у вас
3. **3-слойная память** — MEMORY.md (≤100 строк, авто) → CLAUDE.md (≤300 строк, авто) → memory/*.md (по запросу)
4. **Capture-to-Pack** — знания фиксируются по ходу работы, не теряются
5. **WP Gate** — нетривиальная работа начинается с проверки плана. Нет в плане = не делаем
6. **Open → Work → Close** — каждая сессия: открытие → работа → закрытие
7. **Безопасность по дизайну** — секреты вне git, per-user изоляция, приватные репо. Подробнее: [LEARNING-PATH.md § 8.5](docs/LEARNING-PATH.md)
8. **Прозрачность данных** — пользователь знает какие данные собираются, где хранятся, как удалить. Политика: [DATA-POLICY.md](docs/DATA-POLICY.md)

> Подробное описание — в [LEARNING-PATH.md](docs/LEARNING-PATH.md).

---

## FAQ

**Q: Нужна ли подписка Anthropic?**
A: Для полной установки (Claude Code) — да, рекомендуется **Claude Pro** ($20/мес). Для минимальной установки (`setup.sh --core`) — нет, работает с любым AI CLI. Ядро IWE — это markdown-файлы, совместимые с любой LLM.

**Q: Работает ли на Linux/Windows?**
A: Да. Ядро (CLAUDE.md + memory/ + Claude Code) работает на любой ОС. Автоматизация Стратега: macOS — launchd (автоматически), Linux — cron (вручную), Windows — через WSL + cron.

**Q: Что если я не хочу Стратега?**
A: Можно не устанавливать launchd-агентов. CLAUDE.md и memory/ будут работать и без них — просто не будет автоматических планов.

**Q: Как связан бот (@aist_me_bot) и IWE?**
A: Бот работает на тирах T1-T3 (без git). IWE (этот шаблон) — для T4+. Они используют одну базу знаний (через те же MCP-серверы), но IWE даёт больше: Claude Code, Стратег, свои Pack.

**Q: Что такое MCP и как проверить подключение?**
A: MCP (Model Context Protocol) — протокол, через который Claude Code получает доступ к базе знаний платформы. Подключение настроено автоматически в `.claude/settings.local.json`. Проверить: откройте Claude Code в папке IWE и попросите `knowledge-mcp search("принципы")`.

**Q: Что такое Pack?**
A: Pack — это формализованная область знаний (паспорт предметной области). Например, PACK-product-management. Pack — единственный source-of-truth для доменного знания.

**Q: Безопасны ли мои данные?**
A: Три зоны защиты: (1) **Локальная** — CLAUDE.md и memory/ на вашем компьютере; (2) **GitHub** — DS-strategy и Pack — приватные репозитории; (3) **Платформа** — per-user OAuth, изоляция данных. Anthropic API [не использует данные для обучения](https://www.anthropic.com/policies/privacy-policy). Подробная политика: [DATA-POLICY.md](docs/DATA-POLICY.md).

---

## Лицензия

MIT
