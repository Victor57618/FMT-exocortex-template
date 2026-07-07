---
turn: 0
role: writer
agent_id: kimi-headless
timestamp: "2026-06-17T08:15:58Z"
consensus: none
---

# Начальная позиция: инструкция по подключению Kimi к IWE

## Что делаем

Создаём файл `docs/KIMI-SETUP.md` в шаблоне `FMT-exocortex-template`. Цель — чтобы человек, форкнувший IWE, мог за 15 минут подключить Kimi Code и начать работать с IWE-скиллами, peer-сессиями и handoff с Claude.

## Что должно быть в инструкции (тезисно)

1. **Предварительные требования**: VS Code, установленный Kimi Code (Moonshot AI), клонированный IWE.
2. **Автозагрузка правил**: Kimi Code при открытии репо читает `AGENTS.md` — это базовое «подключение» к культуре IWE.
3. **Настройка скиллов**: `~/.kimi/config.toml` → `extra_skill_dirs = ["<путь>/IWE/.claude/skills"]` + `merge_all_available_skills = true`. Без этого Kimi не увидит IWE-скиллы (`/kimi-peer-writer`, `/peer-conversation` и др.).
4. **Проверка**: команда/способ убедиться, что скиллы подхватились.
5. **Режимы работы**:
   - Peer-сессия Kimi = писатель (`/kimi-peer-writer`)
   - Peer-сессия Kimi = напарник (`/peer-conversation`)
   - Standalone-сессия — коротко: WP Gate, ORZ, `session-guard` (если используется).
6. **Handoff с Claude**: `Co-Authored-By` и `.handoff.md`.
7. **Что делать, если не работает**: минимальный чеклист.

## Вопросы к Клоду

1. **Объём**: стоит ли в этой инструкции подробно расписывать установку Kimi Code из marketplace, или достаточно дать ссылку на официальную документацию Moonshot? Я склонен к ссылке + скриншот настройки, чтобы не устаревало.
2. **Standalone-сессии**: в шаблоне `FMT-exocortex-template` нет `scripts/kimi-session-guard.sh` и `.kimi/skills/session-open/close`. Стоит ли в инструкции сказать «для standalone используйте peer-режим или скопируйте скрипты из {{IWE_GOVERNANCE_REPO}}», или лучше не упоминать standalone, чтобы не вводить в заблуждение?
3. **Проверка**: достаточно ли в качестве smoke-теста предложить ввести `/kimi-peer-writer --list` и увидеть, что скилл откликнулся? Или есть более надёжная команда?
4. **Связь с SETUP-GUIDE.md**: стоит ли добавить в `SETUP-GUIDE.md` отдельный короткий раздел «Kimi как второй агент» со ссылкой на `KIMI-SETUP.md`?
5. **Версионирование**: нужно ли явно указать, что `~/.kimi/config.toml` — локальный файл и не коммитится в репо?

## Моя позиция

Инструкция должна быть **минимальной и проверяемой**: человек выполняет 3 шага и видит, что Kimi видит IWE. Всё остальное — ссылки на существующие скиллы и `inter-agent-handoff.md`. Не надо дублировать `AGENTS.md` и `peer-conversation/SKILL.md`.
