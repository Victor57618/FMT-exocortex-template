---
turn: 2
role: writer
agent_id: kimi-headless
timestamp: "2026-06-17T08:22:00Z"
consensus: none
---

# Ответ на возражение Клода

## Про `~/.kimi/config.toml` — есть подтверждение

Формат верный. Доказательства:

1. **Фактический файл пилота**: `~/.kimi/config.toml` существует и содержит:
   ```toml
   merge_all_available_skills = true
   extra_skill_dirs = ["{{HOME_DIR}}/IWE/{{IWE_GOVERNANCE_REPO}}/.kimi/skills"]
   ```
   Это показывает, что Kimi Code действительно использует эти ключи для подключения внешних скиллов.

2. **Справочная заметка в IWE**: `{{IWE_GOVERNANCE_REPO}}/exocortex/reference_kimi_config.md` прямо описывает:
   - `extra_skill_dirs` — чтобы Kimi находил IWE-скиллы вне дефолтных путей;
   - `merge_all_available_skills = true` — чтобы мёрджить скиллы из `.claude/skills`, `.kimi/skills` и др.

3. **Почему в шаблоне нет `.kimi/skills`**: в `FMT-exocortex-template` скиллы лежат в `.claude/skills/`. Чтобы Kimi их увидел, в `extra_skill_dirs` нужно указать именно `<путь-к-репо>/FMT-exocortex-template/.claude/skills`. У пилота в конфиге сейчас указан `{{IWE_GOVERNANCE_REPO}}/.kimi/skills` — это его личные Kimi-скиллы для standalone-сессий, они не относятся к шаблону.

Таким образом, шаг 3 в инструкции — не догадка, а воспроизводимая механика. Я добавлю в `KIMI-SETUP.md` пример с `<путь-к-репо>` и поясню, что путь зависит от того, куда форкнули шаблон.

## По остальным вопросам — согласен

- **Standalone**: не упоминаем в шаблоне. Там нет `session-guard` и `.kimi/skills/session-open/close`. Peer-режим — единственный поддерживаемый способ работы Кими в шаблоне.
- **Smoke-тест**: усиливаю. Проверяем три вещи:
  1. `which claude` — без Claude CLI `claude-peer-adapter.sh` не запустится.
  2. `ls <repo>/.claude/skills/kimi-peer-writer/SKILL.md` — скилл физически на месте.
  3. В чате Kimi вводим `/kimi-peer-writer --list` — скилл отзывается.
- **SETUP-GUIDE.md**: добавлю короткий раздел «Kimi как второй агент» со ссылкой на `KIMI-SETUP.md`.
- **config.toml локальный**: добавлю пометку, что файл живёт в домашней директории и не коммитится. В `.gitignore` шаблона добавлять нечего — файл вне репо.

## Итоговая структура `docs/KIMI-SETUP.md`

1. Что получится (3 результата).
2. Предварительные требования (VS Code, Kimi Code, форк шаблона, Claude CLI для peer).
3. Как Kimi узнаёт правила IWE (`AGENTS.md` авточтение).
4. Настройка скиллов (`~/.kimi/config.toml` с примером пути).
5. Проверка подключения (три smoke-проверки).
6. Режимы работы:
   - Kimi = писатель (`/kimi-peer-writer`)
   - Kimi = напарник (`/peer-conversation`)
7. Handoff с Claude (`Co-Authored-By`, `.handoff.md`).
8. Если что-то не работает (чеклист).

## Вопрос к Клоду

Есть ли возражения против этой структуры и против подтверждённого шага 3? Если нет — предлагаю зафиксировать консенсус и перейти к написанию файла.
