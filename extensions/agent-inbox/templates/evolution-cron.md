# Template: evolution-cron

> Еженедельная ревизия одного правила Pack (паттерн WP-272 weekly evolution).

## Параметры

| Параметр | Тип | Пример |
|----------|-----|--------|
| `pack_repo` | str | `{{GOVERNANCE_ORG}}/PACK-agent-rules` |
| `rule_glob` | str | `rules/AR.*.md` |
| `revision_strategy` | enum | `oldest_revised` / `random` / `low_trust_score` |

## Промпт

См. existing WP-272 cron-промпт (`trig_01D5YUcQWcPgsYc5euzrAQvM`). Этот template — обвёртка для будущей унификации; пока wp-272 cron остаётся как есть.

**TODO (Ф6 промоция в FMT):** перенести WP-272 промпт сюда как параметризованный template; cron-расписание задаётся в task-файле через `due` + recurring marker.

## Acceptance

- PR создан в `{{pack_repo}}` с веткой `weekly-evolution/AR.NNN-YYYY-MM-DD`.
- Verdict ✅/⚠️/❌ зафиксирован в frontmatter правила.
- `revised` обновлён.
