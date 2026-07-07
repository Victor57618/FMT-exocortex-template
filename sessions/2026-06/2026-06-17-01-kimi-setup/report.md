---
schema_version: 1
session_id: "2026-06-17-01-kimi-setup"
generated_at: "2026-06-17T08:34:35Z"
writer: "kimi-headless"
peer: "claude-code"
duration_min: 19
escalations_count: 0
result_class: agreed
confidence: high
---

# Итоговый отчёт: инструкция по подключению Kimi к IWE

## 1. Исходная постановка

Создать в шаблоне `FMT-exocortex-template` файл `docs/KIMI-SETUP.md` — инструкцию, как подключить Kimi Code к IWE и начать работать в peer-сессиях.

## 2. Позиции по темам

**Тема 1: механизм подключения скиллов.**
- **Kimi:** для подключения IWE-скиллов нужно в `~/.kimi/config.toml` указать `merge_all_available_skills = true` и `extra_skill_dirs` с путём к `.claude/skills` репо.
- **Claude:** сначала возразил, что это неверифицированное утверждение, потому что в шаблоне нет `.kimi/skills`.
- **Разрешение:** Kimi привёл фактический `~/.kimi/config.toml` пилота и справочную заметку `{{IWE_GOVERNANCE_REPO}}/exocortex/reference_kimi_config.md`. Claude принял доказательства.

**Тема 2: что включать в инструкцию.**
- **Claude:** не упоминать standalone-сессии, потому что в шаблоне нет `session-guard` и `.kimi/skills/session-open/close`.
- **Kimi:** согласился.

**Тема 3: smoke-тест.**
- **Claude:** кроме вызова скилла, проверить наличие Claude CLI и файлов скиллов.
- **Kimi:** согласился и добавил три проверки в инструкцию.

## 3. Отвергнутые альтернативы

- Подробная инструкция по установке Kimi Code из marketplace — отклонена в пользу ссылки на официальную документацию, чтобы избежать устаревания.
- Упоминание standalone-сессий с отсылкой к `{{IWE_GOVERNANCE_REPO}}` — отклонено, чтобы не документировать отсутствующее в шаблоне.

## 4. Зафиксированное решение [synthesized]

Создать `docs/KIMI-SETUP.md` из 8 разделов: результат, требования, автозагрузка правил, настройка скиллов, smoke-тест, режимы работы, handoff, troubleshooting. Добавить ссылку в `docs/SETUP-GUIDE.md`. В разделе про `extra_skill_dirs` явно предупредить, что путь должен вести к `.claude/skills` репо, а не к `.kimi/skills`.

## 5. Открытые вопросы и эскалации

Нет.

## 6. Реализация и проверка

**Изменённые файлы:**
- `docs/KIMI-SETUP.md` — новая инструкция.
- `docs/SETUP-GUIDE.md` — добавлена ссылка на новую инструкцию.

**Smoke verification:**
- Проверено, что `~/.kimi/config.toml` содержит нужные ключи.
- Проверено, что `--list` поддерживается в `kimi-peer-writer/SKILL.md`.
- Проверено, что `claude` CLI установлен.

**Deploy:** не выполнен — ждёт согласования пилота на коммит.

## 7. Метаданные и навигация

- **Журнал:** `00-writer.md`, `01-peer.md`, `02-writer.md`, `03-peer.md`.
- **Связанные артефакты:** `AGENTS.md`, `docs/inter-agent-handoff.md`, `.claude/skills/kimi-peer-writer/SKILL.md`, `.claude/skills/peer-conversation/SKILL.md`.
