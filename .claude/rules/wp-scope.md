# WP Scope Rules — Umbrella РП

When reading a wp-context file with `umbrella: true` and `agent_scope: open-only`:

1. Read **ONLY** sections/phases marked as `pending`, `in_progress`, or `blocked`.
2. Do **NOT** read archived/done/closed/defer phases unless the user explicitly asks.

Rationale: umbrella files have long tails of done phases that consume tokens and introduce irrelevant context. The specific WP numbers are declared in the file's frontmatter (`agent_note`).
