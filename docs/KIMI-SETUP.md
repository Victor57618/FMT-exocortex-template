---
title: Подключение Kimi к IWE
scope: FMT-exocortex-template
status: active
updated: 2026-06-17
---

# Подключение Kimi к IWE

> Для кого: пилот, который форкнул шаблон `FMT-exocortex-template` и хочет работать с IWE через Kimi Code.
> Время: ~15 минут.
> Source-of-truth: `AGENTS.md`, `.claude/skills/kimi-peer-writer/SKILL.md`, `.claude/skills/peer-conversation/SKILL.md`.

## Что получится

- Kimi Code при открытии репо будет читать `AGENTS.md` и применять правила IWE.
- Kimi увидит IWE-скиллы (`/kimi-peer-writer`, `/peer-conversation` и другие).
- Сможете запускать peer-сессии, где Kimi — писатель или напарник.

## Предварительные требования

- VS Code.
- Установленное расширение **Kimi Code** (Moonshot AI).
- Форкнутый и склонированный шаблон `FMT-exocortex-template`.
- Установленный **Claude Code CLI** (`claude`) — он нужен для peer-сессий, когда Kimi вызывает Claude.

Проверьте, что `claude` доступен:

```bash
which claude
```

Если команда ничего не вернула — установите Claude Code CLI до начала peer-сессий.

## Как Kimi узнаёт правила IWE

Файл `AGENTS.md` в корне репо читается Kimi Code автоматически при открытии репозитория в VS Code. В нём собраны:

- WP Gate — ритуал открытия каждой задачи.
- Правила git-стейджинга.
- Стиль ответов пилоту.
- Правила коммитов с участием Kimi.
- Координация через MCP Gateway.

Кастомизации именно для Kimi выносятся в `extensions/` или `AGENTS-agent-blocks.md`.

## Настройка скиллов IWE

По умолчанию Kimi Code ищет скиллы в стандартных путях (`~/.kimi/skills/`, `<git-root>/.kimi/skills/`). IWE-скиллы лежат в `.claude/skills/` вашего репо, поэтому их нужно подключить вручную.

Откройте файл `~/.kimi/config.toml` и добавьте путь к `.claude/skills` вашего репо в массив `extra_skill_dirs`:

```toml
merge_all_available_skills = true
extra_skill_dirs = [
  "/путь/к/FMT-exocortex-template/.claude/skills",
  # другие пути, если они уже были
]
```

Важно:

- `~/.kimi/config.toml` — персональный файл на вашей машине, он **не коммитится** в репо.
- Если `extra_skill_dirs` уже содержит пути (например, к `.kimi/skills` вашего governance-репо) — **добавьте** новый путь в массив, не заменяйте существующие.
- В массиве должен быть путь к `.claude/skills` **вашего репо**, а не к `.kimi/skills`. Это разные директории.
- Если путь содержит пробелы или спецсимволы, заключите его в кавычки.
- После сохранения перезапустите окно Kimi Code или обновите список скиллов.

## Проверка подключения (smoke-тест)

Выполните три проверки:

1. **Claude CLI доступен**:

   ```bash
   which claude
   ```

2. **Файлы IWE-скиллов на месте**:

   ```bash
   ls /путь/к/FMT-exocortex-template/.claude/skills/kimi-peer-writer/SKILL.md
   ls /путь/к/FMT-exocortex-template/.claude/skills/peer-conversation/SKILL.md
   ```

3. **Скилл откликается в Kimi Code**:

   В чате Kimi введите:

   ```
   /kimi-peer-writer --list
   ```

   Если скилл подключён, вы увидите журнал peer-сессий из `sessions/00-index.md`.

Если `/kimi-peer-writer --list` не сработал, проверьте, что в `extra_skill_dirs` указан именно путь к `.claude/skills`, и что `merge_all_available_skills = true`.

## Режимы работы

### Kimi = писатель, Claude = напарник

Скилл: `/kimi-peer-writer` (`.claude/skills/kimi-peer-writer/SKILL.md`).

Триггеры:

- «начни peer-сессию»
- «вместе с Клодом»
- «с Клодом»
- «привлеки Клода»
- slash `/peer-writer`

Kimi инициирует сессию, пишет начальную позицию, вызывает Claude через `scripts/claude-peer-adapter.sh`, ведёт turn-loop до консенсуса и по решению пилота реализует результат.

### Kimi = напарник, Claude = писатель

Скилл: `/peer-conversation` (`.claude/skills/peer-conversation/SKILL.md`).

Триггеры:

- «начни peer-сессию»
- «peer-сессия»
- slash `/peer-conversation`

Claude инициирует сессию и вызывает Kimi через `scripts/kimi-peer-adapter.sh`.

## Handoff с Claude

Когда задача передаётся между Kimi и Claude, используйте один из механизмов из `docs/inter-agent-handoff.md`:

- **Git-commits + `Co-Authored-By`** — для задач >30 мин:

  ```bash
  git commit -m "feat: ..." \
    --trailer "Co-Authored-By: Kimi <noreply@moonshot.ai>" \
    --trailer "Co-Authored-By: Claude <noreply@anthropic.com>"
  ```

- **`.handoff.md` файл-мост** — для быстрой итерации 5–15 мин.
- **Branch-based relay** — для сложных задач с несколькими агентами.

## Если что-то не работает

1. Проверьте путь в `extra_skill_dirs` — он должен вести к `.claude/skills` вашего репо.
2. Убедитесь, что `merge_all_available_skills = true`.
3. Перезапустите окно Kimi Code.
4. Проверьте, что `claude` CLI установлен (`which claude`).
5. Посмотрите журнал peer-сессий: `sessions/00-index.md`.

## Связанные документы

- `AGENTS.md` — правила для всех агентов.
- `docs/inter-agent-handoff.md` — передача контекста между агентами.
- `.claude/skills/kimi-peer-writer/SKILL.md` — Kimi как писатель.
- `.claude/skills/peer-conversation/SKILL.md` — Kimi как напарник.
- `docs/skills-catalog.md` и `docs/scripts-catalog.md` — каталоги скиллов и скриптов.
