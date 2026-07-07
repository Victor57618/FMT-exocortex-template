---
name: "Routing Vocabulary (L0 fast-path)"
description: "L0 словарь маршрутизации: фраза → канонический путь. Читать ПЕРЕД Write нового файла. Miss → DP.KR.001 §5"
type: reference
horizon: warm
domains: [routing, knowledge-management, exocortex]
status: active
valid_from: 2026-05-12
owner: user
schema_version: 1
related: DP.SC.036, DP.KR.001
---

# Routing Vocabulary — L0 Fast-Path

> **Принцип:** сначала этот файл. Miss или сомнение → `memory/repo-type-rules.md` (slow-path, universal).
> Source of truth — `memory/repo-type-rules.md`. Этот файл — fast-path проекция. При расхождении — repo-type-rules.md побеждает.
> **Настройка:** замените `{{STRATEGY_REPO}}`, `{{ECOSYSTEM_REPO}}`, `{{INSTRUMENT_REPO}}` именами ваших репо.
> **Обновление:** при каждом инциденте неверного размещения добавить строку + дату.

---

## Управление проектами ({{STRATEGY_REPO}})

| Фраза / Тип | Путь | Naming | Примечание |
|-------------|------|--------|------------|
| **WP-context** (контекст РП) | `{{STRATEGY_REPO}}/inbox/WP-NNN-<slug>.md` | `WP-NNN-<существительное-артефакт>.md` | Активный → inbox/. Закрытый → archive/wp-contexts/ |
| **WeekPlan** | `{{STRATEGY_REPO}}/current/WeekPlan W{N} YYYY-MM-DD.md` | `WeekPlan W20 2026-05-11.md` | Один активный |
| **WeekReport** | `{{STRATEGY_REPO}}/current/WeekReport W{N} YYYY-MM-DD.md` | `WeekReport W20 2026-05-11.md` | Создаётся при закрытии WeekPlan |
| **DayPlan** | `{{STRATEGY_REPO}}/current/DayPlan YYYY-MM-DD.md` | `DayPlan 2026-05-12.md` | Один на день |
| **MonthClose / итоги месяца** | `{{STRATEGY_REPO}}/archive/month-reports/MonthClose YYYY-MM.md` | `MonthClose 2026-05.md` | |
| **Strategy Session / протокол стратегирования** | `{{STRATEGY_REPO}}/sessions/YYYY-MM-DD.md` | `2026-05-12.md` | |
| **Стратегия** (долгосрочный документ) | `{{STRATEGY_REPO}}/docs/Strategy.md` | Один файл, обновляется | |
| **Неудовлетворённости / НЭП** | `{{STRATEGY_REPO}}/docs/Dissatisfactions.md` | Один файл | |
| **Reminder** (напоминание на дату) | `{{STRATEGY_REPO}}/inbox/reminder-YYYY-MM-DD-<тема>.md` | `reminder-2026-05-12-wp121-backfill-check.md` | |

---

## Встречи и обсуждения ({{ECOSYSTEM_REPO}})

| Фраза / Тип | Путь | Naming | Примечание |
|-------------|------|--------|------------|
| **Повестка встречи** (с командой / внешним) | `{{ECOSYSTEM_REPO}}/0.OPS/0.9.Inbox/YYYY-MM-DD-<тема>-agenda.md` | `2026-05-12-wp150-architect-agenda.md` | ⚠️ НЕ {{STRATEGY_REPO}}/inbox/ — это для WP-context! |
| **Предложение** (proposal, архитектурный вариант) | `{{ECOSYSTEM_REPO}}/0.OPS/0.9.Inbox/YYYY-MM-DD-<тема>-proposal.md` | | |
| **Протокол встречи** (meeting minutes) | `{{ECOSYSTEM_REPO}}/0.OPS/0.7.Plans-and-Meetings/YYYY-MM-DD-<тема>.md` | | |
| **Материал к обсуждению** (вопросы, схемы, варианты) | `{{ECOSYSTEM_REPO}}/0.OPS/0.9.Inbox/<slug>.md` | тематический | Lifecycle: обсудили → решения в ADR/Pack → архив |

---

## Черновики и публикации

| Фраза / Тип | Путь | Naming | Примечание |
|-------------|------|--------|------------|
| **Черновик поста / зерно для поста** | `{{STRATEGY_REPO}}/drafts/D-NNN-<slug>.md` | `D-027-december-to-april.md` | ⚠️ НЕ inbox/ |

---

## Bugs, инциденты, аудит

| Фраза / Тип | Путь | Naming | Примечание |
|-------------|------|--------|------------|
| **Bug report** (ошибка IWE/платформы) | `<governance-repo>/inbox/bugs/bug-YYYY-MM-DD-<тема>.md` | `bug-2026-05-12-routing-gate-miss.md` | governance-репо = {{STRATEGY_REPO}} или {{ECOSYSTEM_REPO}} |
| **Инцидент** (разбор сбоя) | `{{ECOSYSTEM_REPO}}/C.IT-Platform/C2.IT-Platform/C2.3.Operations/Incidents/` | папка `YYYY-MM-DD-<slug>/` | |
| **Security posture** (dashboard) | `{{ECOSYSTEM_REPO}}/C.IT-Platform/C2.IT-Platform/C2.2.Architecture/security-posture.md` | Один файл | |

---

## Память агента (memory/)

| Фраза / Тип | Путь | Naming | Примечание |
|-------------|------|--------|------------|
| **Feedback** (правило поведения, урок от пользователя) | `memory/feedback_<тема>.md` | `feedback_routing_gate_always.md` | Тест: пользователь скорректировал поведение? |
| **Lesson** (крупный урок, кросс-системный) | `memory/lessons_<тема>.md` | `lessons_lift_and_shift_ddl.md` | Тест: полезно в будущих разговорах? |
| **Project** (контекст инициативы) | `memory/project_<тема>.md` | `project_first_cohort.md` | |
| **Reference** (токены, API, DB, URLs) | `memory/reference_<тема>.md` | `reference_neon_connections.md` | |
| **Протокол** (алгоритм для IWE) | `memory/protocol-<название>.md` | `memory/protocol-open.md` | SoT в Pack 03-methods/. memory/ = реализация |
| **Routing vocab** (этот файл) | `memory/routing-vocab.md` | | Обновлять при каждом инциденте размещения |

---

## Правила и различения агента

| Фраза / Тип | Путь | Naming | Примечание |
|-------------|------|--------|------------|
| **Различение** 1-3 строки, always-loaded | `.claude/rules/distinctions.md` | добавить строку | Тест: агент систематически путает A и B |
| **Различение** развёрнутое (тест + примеры) | `memory/hard-distinctions.md` | добавить раздел | Тест: 1-3 строк недостаточно |
| **Правило агента** глобальное | `CLAUDE.md` §8 (staging) → §9 (авторское) | | Влияет на все репо |
| **Правило агента** локальное (одно репо) | `<repo>/CLAUDE.md` | | |
| **Форматирование** | `.claude/rules/formatting.md` | добавить строку | |
| **Скилл** | `.claude/skills/<name>/SKILL.md` | | |

---

## Pack (доменное знание)

| Фраза / Тип | Путь | Naming | Примечание |
|-------------|------|--------|------------|
| **Service Clause** L4-Personal | `<PACK>/pack/<domain>/08-service-clauses/DP.SC.NNN-<slug>.md` | `DP.SC.036-knowledge-routing-gate.md` | DP.SC.001-099 = L4 |
| **Service Clause** L2-Platform | то же, `DP.SC.101-199` | | |
| **Роль** | `<PACK>/pack/<domain>/02-domain-entities/DP.ROLE.NNN-<slug>/` | | |
| **Метод** (инвариант) | `<PACK>/pack/<domain>/03-methods/` | | |
| **Failure mode** | `<PACK>/pack/<domain>/05-failure-modes/` | | |

---

## Реализация (DS-instrument)

| Фраза / Тип | Путь | Naming | Примечание |
|-------------|------|--------|------------|
| **SQL миграция** сервиса | `{{INSTRUMENT_REPO}}/<service>/migrations/NNN-*.sql` | `0012-add-consent-column.sql` | |
| **Ad-hoc SQL** (one-off бэкфилл) | `{{INSTRUMENT_REPO}}/<service>/scripts/` | `backfill-YYYY-MM-DD-*.sql` | Удалить после выполнения |
| **ADR** (архитектурное решение) | `{{ECOSYSTEM_REPO}}/.../decisions/ADR-NNN-<slug>.md` | | |

---

## Контрольные вопросы при miss (перед вопросом пользователю)

1. Это доменная истина или технический выбор? → Pack vs DS
2. Это WP-context (план РП) или материал к обсуждению? → {{STRATEGY_REPO}}/inbox vs 0.9.Inbox
3. Это правило (всегда) или урок (контекст)? → CLAUDE.md vs memory/
4. Это для агента или для пользователя/команды? → .claude/ vs DS

---

*Создано: 2026-05-12 (WP-216 Ф4/Ф5, промоция в FMT-exocortex-template). Обновлять при инцидентах маршрутизации.*
*Заменить плейсхолдеры: {{STRATEGY_REPO}} → имя вашего governance-репо, {{ECOSYSTEM_REPO}} → имя ecosystem-репо, {{INSTRUMENT_REPO}} → папка/репо с инструментами.*
