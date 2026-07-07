---
name: "Pack CI guard"
purpose: "Шаблон GitHub Action для новых Pack-репозиториев — детектор ID-коллизий"
created: 2026-05-18
source_wp: WP-5 F-pack-ci-guard
---

# Pack CI Guard — шаблон

Содержимое этой папки копируется в корень нового Pack-репозитория для активации защиты от ID-коллизий через GitHub Actions.

## Что это даёт

Каждый базовый ID в Pack-репо (DP.M.NNN, DP.D.NNN, DP.SC.NNN, AR.NNN и т.д.) должен быть уникален. При обнаружении двух файлов с одинаковым basename ID — CI fail на push/PR.

В отличие от local pre-commit hook'а, CI guard:
- Защищает от **всех** контрибьюторов (а не только тех, у кого настроен local hook)
- Не требует bootstrap'а после `git clone`
- Не зависит от hardcoded путей к sibling-репо

Local hook остаётся опциональным speed-up'ом (быстрая обратная связь до push'а).

## Установка в новый Pack-репо

```bash
cp -r FMT-exocortex-template/pack-templates/.github/ <new-pack-repo>/
cd <new-pack-repo>
git add .github/
git commit -m "feat(ci): pack-lint R4 — ID collision detector"
git push
```

После push'а первый workflow run появится в Actions tab.

## Что внутри

| Файл | Назначение |
|------|------------|
| `workflows/pack-lint.yml` | GitHub Action workflow (push/PR) |
| `scripts/check-pack-collisions.sh` | Standalone bash-скрипт детектора |

Скрипт самодостаточный — нет зависимостей вне `bash + git + grep + awk + sort + uniq + xargs + basename` (стандартные unix-утилиты, доступные в `ubuntu-latest`).

## Что делать при CI fail

CI напечатает пути дублирующихся файлов:

```
❌ pack-lint [R4]: обнаружены ID-коллизии:
  [DP.M.038]:
    pack/.../DP.M.038-personal-guide-onboarding.md
    pack/.../DP.M.038-idempotent-skill-distribution.md
```

Решение:
1. Определить, какой файл «новый» (создан позже / меньше упоминается) — он переезжает
2. Переименовать на следующий свободный ID того же типа
3. Обновить `id:` внутри файла + slug-ссылки на него во всём IWE
4. Re-push

## Источник

Шаблон создан в фазе WP-5 F-pack-ci-guard (18 мая 2026), как продолжение фазы WP-7 Ф-PACK-COLLISIONS (там 14 коллизий разрешено вручную; CI guard защищает от регрессии).

См. также:
- `knowledge-mcp/scripts/pack-lint.sh` — расширенный local linter (R1-R4)
- WP-5 F-pack-ci-guard — контекст фазы в governance-репо
- WP-7 Ф-PACK-COLLISIONS — источник правила (14 коллизий разрешены вручную)
