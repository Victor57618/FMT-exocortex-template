# Навигация по репозиториям (Слой 3)

> Claude читает этот файл при поиске конкретного файла/репо. Для поиска знаний → `mcp__claude_ai_knowledge-mcp__search`.

## Ключевые файлы

| Тема | Файл |
|------|------|
| Различения (жёсткие пары) | `memory/hard-distinctions.md` |
| FPF (навигация, принципы) | `memory/fpf-reference.md` |
| Правила по типам репо | `memory/repo-type-rules.md` |
| Чеклисты | `memory/checklists.md` |
| SOTA-практики (18 шт.) | `memory/sota-reference.md` |
| Протокол Open (WP Gate, Ритуал) | `memory/protocol-open.md` |
| Протокол Close (чеклист, шаблон) | `memory/protocol-close.md` |
| Нулевые принципы + иерархия | `ZP/README.md` |
| Кодирование сущностей | `SPF/spec/SPF.SPEC.001-entity-coding.md` |
| Масштабируемость Pack | `SPF/spec/SPF.SPEC.003-pack-scalability.md` |

## Репозитории

| Репо | Путь |
|------|------|
| LMS Aisystant (READ-ONLY) | `DS-IT-systems/aisystant/` |
| SystemsSchool_bot (READ-ONLY) | `DS-IT-systems/SystemsSchool_bot/` |
| Монорепо ИИ-систем (7 шт.) | `DS-IT-systems/DS-ai-systems/` |
| — Стратег (Grade 3) | `DS-IT-systems/DS-strategist/` |
| — Шаблонизатор (Grade 0) | `FMT-exocortex-template/setup.sh` (user), `DS-IT-systems/DS-ai-systems/setup/` (author sync) |
| — Наладчик (Grade 2) | `DS-IT-systems/DS-ai-systems/fixer/` |
| — Статистик (Grade 1) | `DS-IT-systems/DS-ai-systems/pulse/` |
| — Оценщик (Grade 2) | `DS-IT-systems/DS-ai-systems/evaluator/` |
| Личная онтология | `DS-strategy/ontology.md` |
| Программа обучения | `DS-principles-curriculum/` |

## Pack-репо

| Pack | Путь |
|------|------|
| PACK-education | Методика обучения |
| PACK-personal | Личностное развитие |
| PACK-verification | Верификация и приёмка (трансдоменный) |
| PACK-autonomous-agents | Автономные агенты (BC, различения, методы) |

## Ключевые документы (Pack DP)

| Документ | Код |
|----------|-----|
| Тиры обслуживания | DP.ARCH.002 |
| Каталог ролей (Role-Centric) | DP.ROLE.001 § 3.2 |
| Role-Centric Architecture | DP.D.033 |
| Реестр исполнителей | DP.ROLE.001 § 3.1 |
| Runbook ошибок бота | DP.RUNBOOK.001 |

## MCP

| MCP | Путь |
|-----|------|
| knowledge-mcp (исходники) | `DS-MCP/knowledge-mcp/src/index.ts` |
| knowledge-mcp (ingest) | `DS-MCP/knowledge-mcp/scripts/ingest.ts` |
| guides-mcp (исходники) | `DS-MCP/guides-mcp/src/index.ts` |
| fsm-mcp (исходники) | `DS-MCP/fsm-mcp/src/index.ts` |
| Activity Hub | `DS-IT-systems/activity-hub/` |
| Автономные агенты (код) | `DS-autonomous-agents/` |
| Данные агентов (workspace) | `DS-agent-workspace/` |

## Стратегия

| Файл | Путь |
|------|------|
| Стратегия | `DS-strategy/docs/Strategy.md` |
| Реестр всех РП (WP-1…WP-85+) | `DS-strategy/docs/WP-REGISTRY.md` |
| WeekPlan | `DS-strategy/current/` |

## GitHub-организации (НЕ путать!)

| Org | Какие репо | Примеры |
|-----|-----------|---------|
| `ailev` | FPF | `ailev/FPF` |

> **Правило:** При генерации GitHub-ссылки → проверь org по этой таблице. НЕ подставляй `aisystant` по умолчанию.

## WP Context Files

> Все context files: `DS-strategy/inbox/WP-{N}-{slug}.md`
> Архив: `DS-strategy/archive/wp-contexts/`
