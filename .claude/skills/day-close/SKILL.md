---
name: day-close
description: "Протокол закрытия дня (Day Close). Алиас для /run-protocol close day — симметрия с /day-open."
argument-hint: ""
version: 1.0.0
layer: L1
status: active
triggers:
  slash: [/day-close]
  phrases: []
routing:
  executor: haiku
  deterministic: false
---

# Day Close (протокол закрытия дня)

> **Роль:** R1 Стратег. **Бюджет:** ~10 мин.
> **Принцип:** SKILL.md = L1 платформенный файл. Пользователь не редактирует напрямую — только через `extensions/`.

## БЛОКИРУЮЩЕЕ: пошаговое исполнение

Day Close = протокол. Исполнять ТОЛЬКО пошагово через TodoWrite.
**Шаг 0 — ПЕРВОЕ действие:** создать список задач прямо сейчас (до любых других действий).
Каждый шаг алгоритма → отдельная задача (pending → in_progress → completed).
Переход к следующему — ТОЛЬКО после отметки текущего. Шаг невозможен → blocked (не пропускать молча).

## Алгоритм

### 0. Extensions (before)
`bash .claude/scripts/load-extensions.sh day-close before` → exit 0: `Read` каждый файл из вывода (alphabetic) → выполнить как первые шаги. Поддерживает `extensions/day-close.before.md` И `extensions/day-close.before.<suffix>.md`.

### 1. Сбор данных
Запустить bash-скрипт сбора коммитов за день по всем git-репо в `{{HOME_DIR}}/IWE/`. Сопоставить с таблицей «На сегодня» из DayPlan → определить статусы.
<!-- Детали: day-close-details.md § Шаг 1 -->

### 2. Governance batch
**2a.** WeekPlan (`current/Plan W{N}...`): обновить статусы РП — grep по номеру РП, обновить ВСЕ упоминания.
**2b.** DayPlan `current/DayPlan YYYY-MM-DD.md`: статусы ВСЕХ строк (РП + ad-hoc). Done → зачеркнуть.
**2c.** `docs/WP-REGISTRY.md`: статусы + даты.
**2d.** `inbox/open-sessions.log`: удалить строки закрытых сессий.
**2e.** Новые репо/сервисы за день? → REPOSITORY-REGISTRY, navigation.md, MAP.002.
**2f.** WeekReport — если есть `WeekReport W{N}.md`: добавить `<details><summary><b>Итоги {День} {Дата}</b></summary>` **перед** предыдущими итогами (обратная хронология).
<!-- Детали 2f: day-close-details.md § Шаг 2f -->

**EXTENSION POINT (checks):** `bash .claude/scripts/load-extensions.sh day-close checks` → exit 0: `Read` каждый файл → выполнить.

### 3. Архивация
- DayPlan сегодня → `git mv current/DayPlan $(date +%Y-%m-%d).md archive/day-plans/`. DayPlan'ы прошлых дней в `current/` (мусор) — заархивировать тоже.
- Done WP context files → `mv inbox/WP-{N}-*.md → archive/wp-contexts/`
- Done РП → удалить строку из MEMORY.md. MEMORY.md хранит ТОЛЬКО активные РП.

### 4б. Memory Drift Scan
Grep MEMORY.md на паттерны «ждёт/блокер/blocked/остановлен». Для каждого: найти WP-context, проверить статус, обновить устаревшее. Анонс при 0 изменениях: *«Drift-scan: N паттернов, устаревших нет»*.
<!-- Детали: day-close-details.md § Шаг 4б -->

### 4в. Index Health Check
`python3 {{HOME_DIR}}/IWE/${IWE_GOVERNANCE_REPO:-DS-strategy}/scripts/check-index-health.py` — для каждого FAIL/WARN: диагностика (дамп vs жанр) → перенести или пометить skip.
<!-- Детали: day-close-details.md § Шаг 4в -->

### 4. Lesson Hygiene
Просмотреть «Уроки» в MEMORY.md. Не применялся >1 нед и есть в `lessons_*.md` → удалить. Новый урок → строка в MEMORY.md + `lessons_*.md`. Цель: ≤8 уроков.

### 5. Автоматические шаги
`"$IWE_SCRIPTS/day-close.sh"` — Linear sync, downstream sync (update.sh), backup (memory/ + CLAUDE.md).

### 6. Мультипликатор IWE
> Условный шаг: если `params.yaml → multiplier_enabled: false` → пропустить.

WakaTime CLI (`~/.wakatime/wakatime-cli --today`) или Neon-fallback → Бюджет ПО ФАКТУ / WakaTime = мультипликатор `N.Nx`. Prerequisite: прочитать `sessions/00-index.md` (grep сегодня) → список peer-сессий с числом ходов. Sanity check: <1.5x при ≥10 peer-сессий → пересчитать.
<!-- Детали: day-close-details.md § Шаг 6 -->

### 7. Черновик итогов (показать пользователю)
Обзор (РП × статус) + Что нового узнал + Похвала + Не забыто (dirty repos, /slot часы, мысли, обещания) + Видео + Draft-list + Задел на завтра.
<!-- Детали: day-close-details.md § Шаг 7 -->

### 8. Согласование
Пользователь читает черновик → корректирует → одобряет.

### 9. Запись итогов
**9a.** Дописать «Итоги дня» в DayPlan (шаблон: `memory/templates-dayplan.md`). Валидация: «Завтра начать с» непустое + каждый pending РП с конкретным next action. Postcondition: bash-grep подтверждает наличие итогов → `9a OK/FAIL`.
**9b.** Дописать сводку в WeekReport (`<details>`, обратная хронология). Fallback на WeekPlan если нет WeekReport. Postcondition: bash-grep → `9b OK/FAIL`.
`*a/*b FAIL` → НЕ помечать completed, вернуться к записи.
<!-- Детали postconditions: day-close-details.md § Шаг 9 -->

### 10. Закоммитить ${IWE_GOVERNANCE_REPO:-DS-strategy}

### 10b. Rule Classifier
`python3 $HOME/IWE/.claude/scripts/rule-classifier.py` (после коммита, идемпотентно, kill если >60 сек).

### 11. Верификация (Haiku R23)
Sub-agent Haiku R23 (context isolation): передать чеклист + черновик итогов + список обновлённых файлов. По ❌ — исправить до показа пользователю.

**EXTENSION POINT (checks):** `bash .claude/scripts/load-extensions.sh day-close checks` → exit 0: `Read` каждый файл → выполнить.

---

## Чеклист Day Close

- [ ] Все изменения закоммичены и запушены (по всем репо)
- [ ] MEMORY.md: done-РП удалены, активные актуальны, drift-scan выполнен (шаг 4б)
- [ ] Index Health Check (шаг 4в): все FAIL/WARN разобраны или помечены skip
- [ ] WP-REGISTRY.md обновлён
- [ ] WeekPlan обновлён (grep по номерам РП — ВСЕ упоминания)
- [ ] DayPlan обновлён (статусы ВСЕХ строк: РП + ad-hoc)
- [ ] open-sessions.log: строки закрытых сессий удалены
- [ ] Captures за день применены (все Quick Close → KE пройден)
- [ ] Синхронизация downstream: `update.sh` выполнен
- [ ] Linear sync: статусы соответствуют git. Кол-во active РП в REGISTRY = active issues в Linear
- [ ] Repo CLAUDE.md: feat-коммиты → новые правила?
- [ ] DayPlan сегодня → `archive/day-plans/` (старые DayPlan'ы в `current/` тоже)
- [ ] WP context: done → `mv inbox/ → archive/wp-contexts/`
- [ ] Lesson Hygiene: уроки MEMORY.md ≤8
- [ ] Draft-list: Pack обогащён → черновик предложен?
- [ ] Видео: обработанные помечены (если video.enabled)
- [ ] Governance: REPOSITORY-REGISTRY, navigation.md, MAP.002
- [ ] Backup: `day-close.sh` выполнен
- [ ] **Rule-engine FP-stats** (WP-272 Ф2.5): `python3 ~/IWE/.claude/scripts/fp-stats.py --date $(date +%Y-%m-%d)` → `⚠️ REVISE` → записать в «Завтра начать с»
- [ ] Верификация compliance: /verify запускался сегодня?
- [ ] WakaTime + Мультипликатор: часы / бюджет ПО ФАКТУ (sessions/00-index.md перечислен; ad-hoc оценены по ходам; сверхплановое — по факту); sanity check ≥10 peer-сессий
- [ ] Итоги дня записаны в DayPlan **(postcondition 9a: grep подтверждён)**
- [ ] Handoff-валидация: «Завтра начать с» содержит ВСЕ pending РП с конкретным next action
- [ ] Сводка итогов записана в WeekReport (`<details>`, обратная хронология) **(postcondition 9b: grep подтверждён)**
- [ ] Новое репо → MAPSTRATEGIC.md + Strategy.md

Все ✅ → «День закрыт.» Иначе — указать что осталось.

<!-- USER-SPACE -->
<!-- /USER-SPACE -->
