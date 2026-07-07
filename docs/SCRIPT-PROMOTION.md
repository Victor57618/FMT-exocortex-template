# Промоция скрипта: L3 (author) → L1 (universal)

> Процесс переноса скрипта из авторской зоны (`WORKSPACE/scripts/`) в FMT-шаблон
> (`FMT-exocortex-template/scripts/`), откуда `update.sh` доставит его всем пилотам.
> Источник: WP-5 #12, DP.KR.001 §5.6.

## Когда промотировать

Промоция уместна, если скрипт:
- работает в авторском IWE ≥2 недели без серьёзных правок
- имеет универсальную ценность (не привязан к личным данным автора)
- параметризуем через `WORKSPACE_DIR` + `params.yaml` (или env-переменные)

Не промотируется:
- скрипт, ссылающийся на личные репозитории (например, governance-репо автора)
- одноразовый скрипт без планов повторного запуска
- скрипт с авторскими константами, которые нельзя вынести в параметр

## 7-шаговый процесс

### Шаг 1. Проверить коллизии

```bash
~/IWE/FMT-exocortex-template/scripts/check-script-collisions.sh
```

Если скрипт с таким же именем уже в FMT — разобрать коллизию: merge (оставить
одну версию) или rename (если нужны обе функции). Без этого шага промоция
сломает поведение у пилотов, у которых скрипт уже есть.

### Шаг 2. Параметризовать авторские константы

| Авторская константа | Универсальный паттерн |
|---------------------|-----------------------|
| `$HOME/IWE` | `${WORKSPACE_DIR:-$HOME/IWE}` |
| `$HOME/IWE/PACK-personal` | `params.yaml` → пользовательский ключ |
| Личные пути (governance, knowledge-index) | `params.yaml` параметр + graceful skip если пусто |
| WakaTime CLI путь | `${WAKATIME_CLI:-$HOME/.wakatime/wakatime-cli}` |
| FMT путь | `${FMT_PATH:-${WORKSPACE_DIR}/FMT-exocortex-template}` |

Правило: скрипт читает параметры из `${WORKSPACE_DIR}/params.yaml`. Если
обязательный параметр отсутствует — выводит сообщение и `exit 0` (не fail).

### Шаг 3. Добавить параметр в FMT/params.yaml

Если скрипт требует нового параметра — добавить в `FMT-exocortex-template/params.yaml`
с дефолтом (обычно пустая строка) + комментарием, объясняющим назначение.

### Шаг 4. Скопировать в FMT

```bash
cp WORKSPACE/scripts/my-script.sh FMT-exocortex-template/scripts/my-script.sh
chmod +x FMT-exocortex-template/scripts/my-script.sh
```

### Шаг 5. Зарегистрировать в update-manifest.json

Добавить запись в `FMT-exocortex-template/update-manifest.json`:

```json
{
  "path": "scripts/my-script.sh"
}
```

Список упорядочен лексикографически по `path` — вставлять в правильную позицию.

### Шаг 6. Обновить версию манифеста и CHANGELOG

В `update-manifest.json` поднять `version` (semver: новый скрипт = minor bump).
В `CHANGELOG.md` добавить запись с этой версией.

Pre-commit hook `.githooks/pre-commit` проверяет согласованность версий
manifest ↔ CHANGELOG — без bump-а коммит будет заблокирован.

### Шаг 7. Smoke-test и коммит

```bash
# Smoke-test 1: скрипт работает без params.yaml (graceful skip)
bash FMT-exocortex-template/scripts/my-script.sh

# Smoke-test 2: с params.yaml — выполняет ожидаемое действие
WORKSPACE_DIR=/tmp/test-iwe bash FMT-exocortex-template/scripts/my-script.sh

cd FMT-exocortex-template
git add scripts/my-script.sh params.yaml update-manifest.json CHANGELOG.md
git commit -m "feat: promote my-script.sh from staging"
git push
```

## Удаление автора-версии (после промоции)

Если скрипт **не имеет** дополнительной авторской логики поверх универсальной —
удалить из `WORKSPACE/scripts/`. Следующий `update.sh` доставит FMT-версию
обратно в `WORKSPACE/scripts/` — единая точка истины.

Если у автора есть **дополнительная логика** (например, обёртка с авторскими
аргументами) — переименовать авторскую версию, чтобы избежать коллизии после
прихода универсальной.

## Откат

`git revert` коммита промоции + следующий `update.sh` у пилотов вернёт прежнее
состояние. Параметр в `params.yaml` остаётся (без вреда, неиспользуем).

## Золотое правило валидатора

> **«Зависишь от валидатора → проверь его на реальных данных в `env -i` перед коммитом»**

Корень B4-класса багов (clean-env blind spots, 20 мая 2026): скрипт работает у автора
(авторский `IWE_GOVERNANCE_REPO` перекрывает дефолт), но ломается у пользователя в чистом env.
Если изменяешь `validate-fmt-scripts.sh` или `integration-contract-validator.sh` — проверь:

```bash
env -i HOME="$HOME" PATH="$PATH" \
    bash scripts/validate-fmt-scripts.sh scripts/
```

`hook-promote.sh` и `script-promote.sh` уже содержат такую проверку при промоции.
При прямом `git commit` — твоя ответственность запустить её вручную.

## Связь с правилами

- **DP.KR.001 §5.6** — классификация скриптов как исполнителей ролей
- **DP.D.048** — Script ≠ Agent (детерминированный flow)
- **DP.D.049** — Log ≠ Incident ≠ State file (артефакты исполнения)
- **§9 CLAUDE.md** — авторский режим (`params.yaml: author_mode: true`)
- **Extensions Gate** — пользовательская кастомизация только через `extensions/`

---

## Класс багов B12: Promotion Completeness Drift

> Источник: peer-сессии 2026-05-29-15 и 2026-05-29-20. WP-347 закрывал «как доставлять» (release mechanism). B12 — «что и когда доставлять» (promotion governance). Orthogonal scope.

5 подклассов:

| ID | Имя | Симптом | Detector | Фикс |
|----|-----|---------|----------|-----|
| **B12a** | **Catalog drift** | `skills-catalog.yaml` в FMT stale: новый скилл промотирован, но не виден при discovery | `coverage-skills.sh --check-catalog` | `skill-promote.sh` теперь регенерирует FMT catalog (commit c2e96e6) |
| **B12b** | **Missing drift** | Артефакт есть в author/.claude/skills/, нет в FMT/.claude/skills/ | `coverage-skills.sh --check-missing` | Запустить `skill-promote.sh <name>` |
| **B12c** | **Reverse drift** | Артефакт промотирован однажды, обновления в author не доходят до FMT | `coverage-skills.sh --check-reverse` (normalize-перед-diff) | Расширенный `template-sync.sh` allowlist (commit d575a6b) |
| **B12d** | **Deletion drift** | Артефакт удалён в author, остался в FMT (dead code в шаблоне) | `coverage-skills.sh --check-deletion` | Ручная очистка по сигналу + лог в `promotion-status.yaml` |
| **B12e** | **Decay drift** | STAGING.md запись `testing` >30 дней без машинных критериев готовности | `staging-audit.sh` | Per-row frontmatter `decay_after` / `ready_signals` |

## Pair-on-Promote Convention (B12 prevention)

> Source-of-truth: запись о промоции живёт **парой**: STAGING.md (decision) + `promotion-status.yaml` (execution).

**При промоции скрипта/скилла/правила:**

1. **STAGING.md row → status: promoted**
   - Поля: `id`, `name`, `artefact_path`, `status`, `promoted_at`, `promoted_in_session`
   - Если row не было до промоции — создать (для post-hoc документирования)

2. **`promotion-status.yaml` append** (через `promote-common.sh::record_promotion()`)
   - Поля: `artifact_path`, `type` (skill|script|hook|rule|protocol), `source_sha` (author commit), `fmt_sha` (FMT commit), `promoted_at` (ISO-8601), `verified_in_clean_env` (bool)

3. **Smoke-check в clean-env обязателен** для скриптов и скиллов с executable содержимым:
   - `verified_in_clean_env: true` — прошёл `env -i` smoke (см. §B4 выше)
   - `verified_in_clean_env: false` — не критично для read-only артефактов (docs, rules)

**Запрещено:**
- Промотировать без записи в STAGING.md (исключения: emergency hotfix — задним числом сделать запись в течение 24h)
- Запускать promote-скрипт без `--dry-run` ревизии diff перед apply
- Push в FMT main без CI green (validate-template, integration-contract-validator)

**Связанные скрипты:**
- `scripts/coverage-skills.sh` — детектор B12a/b/c/d
- `scripts/staging-audit.sh` — детектор B12e
- `scripts/promote-common.sh::record_promotion()` — writer для promotion-status.yaml
- **RELEASE-PROCESS.md** — чеклист выпуска + конвенция `deprecated_files`
