# Day Close — Детали (lazy-load)

> Загружать при необходимости деталей по конкретному шагу.
> Основной протокол: `day-close/SKILL.md`

---

## Шаг 1: Сбор данных

```bash
for repo in $(ls {{HOME_DIR}}/IWE/); do
  if [ -d {{HOME_DIR}}/IWE/$repo/.git ]; then
    commits=$(git -C {{HOME_DIR}}/IWE/$repo log --since="today 00:00" --oneline --no-merges 2>/dev/null \
      | grep -vE "^(docs|chore|ci|style|perf|test)(\\(|:| )" \
      | grep -vE "memory/|\.claude/rules/|template-sync|backup|reindex" \
      || true)
    [ -n "$commits" ] && echo "=== $repo ===" && echo "$commits"
  fi
done
```

Сопоставить коммиты с таблицей «На сегодня» из DayPlan → определить статусы.

---

## Шаг 2f: WeekReport — правила записи итогов

- Файл: `${IWE_GOVERNANCE_REPO:-DS-strategy}/current/WeekReport W{N} YYYY-MM-DD.md`
- Добавить новый раздел `<details><summary><b>Итоги {День} {Дата}</b></summary>` **перед** предыдущими `Итоги` (обратная хронология: сегодня → старше)
- Содержимое: коммиты по репо, РП-статусы за день, carry-over блокеры
- **strategy_day (Пн без DayPlan):** итоги в WeekReport как обычный день — только факты (РП-результаты, коммиты, мультипликатор). Плановые строки в WeekReport НЕ копировать.
- **Правило ОПТ-5:** WeekPlan = намерения только; WeekReport = факты только.

---

## Шаг 4б: Memory Drift Scan — алгоритм

```bash
grep -nE "→ ждёт|ждёт|dep:|блокер|blocked:|остановлен|ждёт согласования" \
  {{HOME_DIR}}/.claude/projects/*/memory/MEMORY.md 2>/dev/null
```

Для каждого найденного паттерна:
1. Определить номер РП (WP-NNN) из контекста строки
2. Найти WP-context: `ls ${IWE_GOVERNANCE_REPO:-DS-strategy}/inbox/WP-{N}-*.md` (если заархивирован → `archive/wp-contexts/`)
3. Прочитать секцию «Что узнали» / «Осталось» / финальный статус
4. Если есть признак закрытия (`DONE`, `РЕШЕНО`, `✅`, `починил`, `закрыт`, `снят`) → обновить MEMORY.md, анонс: *«Memory drift: [факт] устарел → обновлён»*
5. Если WP-context не найден → *«Memory drift: WP-N — context не найден, проверить вручную»*

Анонс при 0 изменениях: *«Drift-scan: проверено N паттернов, устаревших фактов не найдено»*

---

## Шаг 4в: Index Health Check — алгоритм

> Ловит раздутие индекс-файлов (MEMORY.md, WP-REGISTRY.md, MAPSTRATEGIC.md, *-registry.md, *-index.md, *-catalog.md).
> Правило: [feedback_memory_index_discipline.md](../../../memory/feedback_memory_index_discipline.md)

```bash
python3 {{HOME_DIR}}/IWE/${IWE_GOVERNANCE_REPO:-DS-strategy}/scripts/check-index-health.py
```

Для каждого FAIL/WARN в отчёте:
1. Открыть файл, посмотреть конкретные строки/ячейки из отчёта
2. Диагностика: это дамп контекста (болезнь) или методологическая таблица (жанр)?
   - Дамп → перенести контекст в source-of-truth (inbox/WP-NNN-*.md, WeekPlan, отдельный `*-changelog.md`); в индексе — hook + ссылка
   - Жанр (таблица-матрица, каталог доменных сущностей) → пометить в начале файла: `<!-- index-health: skip-cells -->` или `<!-- index-health: skip -->` с обоснованием
3. Если FAIL в Pack-файле — не чистить автоматически, только пометить skip с обоснованием

Анонс при 0 WARN/FAIL: *«Index-health: N файлов OK, M skip»*.

---

## Шаг 6: Мультипликатор IWE — алгоритм

1. **WakaTime** — физическое время за день:
   - CLI: `~/.wakatime/wakatime-cli --today`
   - Fallback Neon: `SELECT payload->>'human_readable', payload->>'total_seconds' FROM learning.public.domain_event WHERE event_type='coding_time' AND account_id='{DT_USER_ID}' AND external_id='wakatime:{DT_USER_ID}:{YYYY-MM-DD}'`
   - Если Neon тоже пуст → пометить «pending Neon», пересчитать при следующей сессии

2. **Бюджет закрыт — считать ПО ФАКТУ (БЛОКИРУЮЩЕЕ):**
   - **Шаг 2.0 (prerequisite):** открыть `<governance-repo>/sessions/00-index.md`, отфильтровать строки за сегодня (`grep "$(date +%Y-%m-%d)"`), составить полный список peer-сессий с числом ходов. Без этого расчёт занижен ×2.
   - done → полный бюджет (или пропорционально фазам для зонтичных)
   - partial → % выполнения × бюджет; если сверхплановая работа в плановом РП — засчитывать ФАКТ
   - not started → 0h
   - **ad-hoc peer-сессии (без РП-метки в DayPlan):**
     - 2-4 хода → 0.25-0.5h
     - 5-7 ходов → 0.75-1h
     - 8+ ходов → 1-1.5h
   - Мелкие правки без peer-сессии (бюджет «—» / merged) → 0.25h

3. **Мультипликатор дня** = Бюджет закрыт / WakaTime. Формат: `N.Nx`

4. **Sanity check (БЛОКИРУЮЩЕЕ):** мультипликатор <1.5x при ≥10 peer-сессий → пересчитать. Показать пилоту 3 метода (буква SKILL / по факту / компромисс) и спросить какой записывать.
   Урок: `lessons_multiplier_peer_sessions_uncounted.md`

---

## Шаг 7: Черновик итогов — структура

**а) Обзор:** таблица «что сделано» (РП × статус)

**б) Что нового узнал:** captures в Pack, различения, инсайты

**в) Похвала:** что получилось, что было непросто но сделано

**г) Не забыто?**
- Незакоммиченные изменения: `${IWE_SCRIPTS}/check-dirty-repos.sh`
- Часы саморазвития (WP-310 Ф13c): записан ли `/slot` за сегодня? Спросить «Сколько часов?», предложить кнопки 0/0.5/1/2/3/4. Подсказать команду `/slot N` в бот.
- Незаписанные мысли? (спросить пользователя)
- Обещания кому-то? (спросить пользователя)

**д) Видео за день:** если `video.enabled: true` → проверить новые видео

**е) Draft-list:** Pack обогащён → предложить черновик?

**ж) Задел на завтра:**
- С чего начать утром
- Незавершённые РП: конкретный next action по каждому

---

## Шаг 9: Запись итогов — postconditions

**Шаблон итогов дня:** `memory/templates-dayplan.md § Шаблон итогов дня`

**Валидация «Завтра начать с» (ADR-207):** поле не пустое + каждый pending РП упомянут + конкретный next action (не «продолжить работу»).

**Postcondition 9a:**
```bash
TODAY=$(date +%Y-%m-%d)
grep -l "Итоги дня" ~/IWE/${IWE_GOVERNANCE_REPO:-DS-strategy}/archive/day-plans/DayPlan\ ${TODAY}.md 2>/dev/null \
  | xargs grep -l "${TODAY}" 2>/dev/null \
  | grep -q . && echo "9a OK" || echo "9a FAIL: итоги не найдены в DayPlan ${TODAY}"
```

**Postcondition 9b:**
```bash
TODAY=$(date +%Y-%m-%d)
DAY_NUM=$(date +%-d)
( grep -rl "Итоги.*${DAY_NUM}" ~/IWE/${IWE_GOVERNANCE_REPO:-DS-strategy}/current/WeekReport\ W*.md 2>/dev/null \
  || grep -rl "Итоги.*${DAY_NUM}" ~/IWE/${IWE_GOVERNANCE_REPO:-DS-strategy}/current/WeekPlan\ W*.md 2>/dev/null ) \
  | grep -q . && echo "9b OK" || echo "9b FAIL: итоги не найдены ни в WeekReport, ни в WeekPlan"
```

Результат `*a/*b FAIL` → шаг НЕ помечать completed, вернуться к записи.
