---
id: DP.SC.NNN
name: Анализ ограничения системы (TOC)
name_ru: Анализ ограничения системы (TOC)
name_en: Constraint Analysis (TOC)
type: sc
status: draft
layer: L4-Personal
summary: "Потребитель (пилот / Стратег / Артефактор / Навигатор) получает на выходе пятифазного ВДВ-каскада три артефакта: System Card (классификация системы-конвейера), Constraint Brief (описание ограничения с trichotomy + class), Stage Dependency Map (план работы как dependency graph без дат и часов). SC-first: первой проверяется работоспособность функциональных обещаний, не структура pending-РП."
consumer: Пилот (IWE Creator), Стратег, Артефактор, Навигатор, Диагност (частный случай для учебного конвейера)
created: YYYY-MM-DD
updated: YYYY-MM-DD
related:
  realizes: []
  uses:
    - DP.ROLE.NNN                  # Аналитик ограничений — носитель в твоём Pack
    - DP.WP.NNN                    # Stage Dependency Map — формат выхода в твоём Pack
    - .claude/skills/bottleneck-pick
---

<!--
ШАБЛОН (FMT-exocortex-template/pack-templates/).

Это перенос service clause из авторского Pack (WP-313 Ф11, 20 мая 2026).
При адаптации в свой Pack:
1. Заменить `DP.SC.NNN` на следующий свободный номер L4-Personal (001-099)
2. Заменить `DP.ROLE.NNN` на номер своей роли Аналитика ограничений
3. Заменить `DP.WP.NNN` на номер своего Stage Dependency Map формата
4. Подставить `created` / `updated` на сегодняшнюю дату
5. Удалить этот HTML-комментарий перед коммитом
-->

# [DP.SC.NNN] Анализ ограничения системы (TOC)

## Правило (инвариант)

> Что ВСЕГДА должно выполняться. Нарушение = провал SC.

- **Идентификация системы-конвейера обязательна.** Без классификации (учебный / работ / когортный конвейер) signal-scan не запускается.
- **SC-first порядок.** Ф2 «Scan promises» выполняется ДО Ф3 «Identify constraint». Документо-центричный анализ (что pending в РП) без предварительной проверки функциональных обещаний потребителя — анти-паттерн.
- **Trichotomy + class — обязательны.** Trichotomy (Tendon): Work Flow / Work Process / Work Execution. Class: Policy / Resource / Cognitive.
- **NBR после любого EC injection.** 3 negative branches + trim каждой.
- **Stage Dependency Map — без дат и часов.** Только структурная зависимость.
- **External-зависимости — явные.** Если этап зависит от работ в другом РП / репо / внешнего поставщика — явное external-ребро.
- **Calibration record — обязателен.** Каждое применение → YAML в `{{GOVERNANCE_REPO}}/inbox/bottleneck-pick-runs/<date>-<target>.yaml`.
- **PII не пишутся в Calibration record.** Имена пилотов когорты, raw-тексты переписки, email — не сохраняются.

---

## Обещание

**Кому:**
- **Пилот (IWE Creator)** — главный потребитель: «открыл WP-NNN → получил обоснованный выбор bottleneck → план этапов → сделал»
- **Стратег** — при отборе НЭП на стратегической сессии
- **Артефактор** — последовательно: Аналитик идентифицирует этапы, Артефактор декомпозирует каждый на физические артефакты
- **Навигатор** — при ответе пилоту «с чего начать»
- **Диагност** — частный случай специализации для учебного конвейера

**Зачем:**
- Обоснованный выбор без когнитивных искажений (sunk cost, sexy work bias, recency)
- Защита от подмены продукта каналом доставки
- Границы каждого этапа = вход для декомпозиции на физические артефакты

**Что получит:** Три артефакта на выходе пятифазного ВДВ-каскада:

```
{
  "system_card": {
    "type": "учебный_конвейер | конвейер_работ | когортный_конвейер",
    "target": "<target-ref>",
    "promises": ["<service_clause_id>: status", ...],
    "current_state": {...}
  },
  "constraint_brief": {
    "description": "...",
    "trichotomy": "work_flow | work_process | work_execution",
    "class": "policy | resource | cognitive",
    "tool_selected": "five_steps | ec | five_steps_ec_nbr"
  },
  "stage_dependency_map": {
    "stages": [...],
    "edges": [...]
  }
}
```

**Триггер:** Явный вызов `/bottleneck-pick --target <ref>` пилотом или другой ролью.

**Время отклика:** ≤15 мин для опытного применения; до 30 мин на первых применениях.

**Режим отказа:**
- target не найден / пустой / done-РП → СТОП с понятной причиной
- Данные устарели (>7 дней) → ⚠️ к signal-scan, не останавливаться
- EC не сходится → fallback к Five Steps

---

## Сценарии использования

### Сценарий 1: Зонтичный РП (ведущий)

Пилот открывает зонтичный РП с N направлениями → `/bottleneck-pick --target WP-NNN --horizon wave-1` → Аналитик возвращает выбор bottleneck-направления + Stage Dependency Map с этапами (параллельность внутри узла, жёсткие зависимости между узлами).

### Сценарий 2: Эпик с фазами

Пилот ведёт эпик с N фазами → `/bottleneck-pick --target WP-NNN --horizon wave-1` → выбор следующей фазы с обоснованием по signal-scan; NBR-предохранители для рискованных injections.

### Сценарий 3: Стратегическая сессия (Стратег)

Еженедельная стратегическая сессия → `/bottleneck-pick --target {{GOVERNANCE_REPO}} --scope direct+related` → диагностика «какое из направлений работы сейчас bottleneck» как input для НЭП-обсуждения с пилотом.

### Сценарий 4: Учебный конвейер пилота (Диагност-специализация)

Диагност получает запрос «какая моя ступень и что фиксить первым» → `/bottleneck-pick --target rcs-profile:<account_id> --horizon next-stage` → специализированный signal-scan по RCS-слотам (stage_raw, Δ baseline, gap до следующей ступени, dependency между слотами) → выбор слота + skip-вход для следующей ступени.

---

## Связанные документы

- `DP.ROLE.NNN` Аналитик ограничений — носитель методики (в твоём Pack)
- `DP.WP.NNN` Stage Dependency Map — формат выхода (в твоём Pack)
- `.claude/skills/bottleneck-pick/SKILL.md` — инструмент-носитель алгоритма
