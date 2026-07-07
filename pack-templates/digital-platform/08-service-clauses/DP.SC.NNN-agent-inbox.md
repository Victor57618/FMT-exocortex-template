---
id: DP.SC.NNN
name: Agent Inbox — конвейер агентных задач IWE
type: sc
status: draft
layer: L2-Platform
summary: "Создатель IWE ставит задачу агенту в единое место и получает результат в декларированной точке не позднее чем через 1 час после due"
consumer: DP.ROLE.001  # IWE Creator
created: YYYY-MM-DD
updated: YYYY-MM-DD
related:
  realizes: []
  uses:
    - DP.ROLE.NNN   # Dispatcher (свой номер)
    - DP.ROLE.NNN   # Notification Dispatcher (для уведомлений о failed P0)
  extends: []
---

<!--
ШАБЛОН (FMT-exocortex-template/pack-templates/).

Это перенос обещания из авторского Pack (WP-324, 17 мая 2026).
При адаптации в свой Pack:
1. Заменить `DP.SC.NNN` на следующий свободный номер в твоём Pack
2. Заменить `DP.ROLE.NNN` на соответствующие номера ролей в твоём Pack
3. Подставить `created` / `updated` на сегодняшнюю дату
4. Удалить этот HTML-комментарий перед коммитом
-->

# DP.SC.NNN — Agent Inbox

## Правило (инвариант)

- [ ] Каждая task в финальном статусе (completed / failed / blocked) имеет соответствующий result-файл в `inbox/agent/results/`.
- [ ] Task'и в статусе `assigned` старше 2 часов автоматически возвращаются Scout sweeper'ом в `pending` (или помечаются failed).
- [ ] `result_location` task'а — единственная точка истины: агенту запрещено создавать результат в другом месте через fallback. Несоответствие = `status: failed`.
- [ ] Промпт task'а исполняется только через предусмотренный template (никакого произвольного bash).

## Обещание

**Кому:** DP.ROLE.001 Создатель IWE (пилот платформы).

**Зачем:** Делегировать асинхронные/отложенные задачи (анализ материала, разведка медленных источников, soak-verify, weekly evolution) без удержания их в работающей сессии. Видеть в одном месте, что висит на агенте и что уже сделано.

**Что получит:**
1. Задача из `inbox/agent/tasks/*.md` со `status: pending` будет запущена через подходящий канал (CCR / systemd / local) не позднее 1 часа после `due`.
2. Результат окажется ровно в `result_location` (repo + branch + path).
3. Аудит-трейл в `inbox/agent/results/RESULT-<task-id>.md`: время старта, модель, стоимость, ссылка на артефакт, ошибки.

**Триггер:**
- Появление в git нового `tasks/*.md` со `status: pending` и наступление `due`.
- Periodic dispatcher cycle (часовой).

**Время отклика:** ≤1 час после `due`.

**Режим отказа:**
- Dispatcher недоступен → задачи накапливаются в `pending`, следующий запуск подхватит. Через 24h без запуска dispatcher → уведомление пилоту через DP.ROLE.NNN (Notification Dispatcher).
- `result_location` недоступен → `status: failed` с причиной; артефакт встроен в result-файл как fallback (не теряется).
- Канал запуска (RemoteTrigger / SSH / launchd) вернул ошибку → retry 3× через час; после 3 неудач → `status: failed` с причиной.
- Task >5 одновременно pending → запускаются top-N по `priority` (P0 → P1 → P2 → P3), остальные ждут следующего цикла.

## Свидетельства (критерий приёмки)

**Данные:**

| Критерий | Как проверить |
|----------|--------------|
| `inbox/agent/` структура существует с подкаталогами tasks/results/scout/templates/archive | `test -d {{GOVERNANCE_REPO}}/inbox/agent/tasks && test -d ...` |
| Dispatcher запущен (cron / systemd timer / CCR) | по выбранному каналу: `systemctl status iwe-agent-dispatcher.timer` ИЛИ `RemoteTrigger list \| jq '.data[] \| select(.name == "Dispatcher")'` |
| Для каждой task в `completed/failed/blocked` существует result-файл | `for f in tasks/*.md; do id=$(yq .id $f); test -f results/RESULT-$id.md \|\| echo MISSING; done` |
| Артефакт в `result_location` совпадает с задекларированным path | acceptance-check внутри dispatcher (часть алгоритма) |

**Контекст:**

| Условие | Проверка |
|---------|---------|
| Пилот имеет git-доступ к governance-репо | `git push {{GOVERNANCE_REPO}}` от имени пилота работает |
| Канал запуска доступен | соответствующий health-check (claude CLI установлен / RemoteTrigger 200 / SSH ok) |
| Шаблон task.template существует в templates/ | `test -f inbox/agent/templates/<template>.md` |

**Полномочия:**

| Роль | Что подтверждает |
|------|-----------------|
| DP.ROLE.NNN Dispatcher | Что task запущена / завершена / зафиксирован статус |
| DP.ROLE.001 IWE Creator | Что промпт корректно сформулирован и acceptance применим |
| Git commit history | Что лента событий (создание → status changes → archive) сохранена |

**Свидетельства:**

| Свидетельство | Источник |
|--------------|---------|
| RESULT-файл с completed_at | `inbox/agent/results/RESULT-*.md` |
| Артефакт в декларированном repo+branch+path | внешний репозиторий |
| Audit-trail в archive/YYYY/ | `inbox/agent/archive/YYYY/{tasks,results}/` после move |

## Реализующие сервисы (MAP.002)

| Сервис | Роль | Триггер |
|--------|------|---------|
| Dispatcher (CCR / systemd / local) | DP.ROLE.NNN | ⏰ cron 0 * * * * |
| Scout + sweeper | DP.ROLE.NNN | ⏰ cron 0 4 * * * |
| `inbox/agent/` (governance-репо) | артефакт-хранилище | 👤 пилот / dispatcher |

## Пользовательский путь

| # | Шаг | Кто | Сервис |
|---|-----|-----|--------|
| 1 | Создать task-файл из шаблона | DP.ROLE.001 (пилот) | git Write + push |
| 2 | Зафиксировать в git | DP.ROLE.001 | git commit |
| 3 | Подхватить task'и `pending+due` | DP.ROLE.NNN (Dispatcher) | Dispatcher cycle |
| 4 | Запустить агента через канал | DP.ROLE.NNN | claude CLI / RemoteTrigger / SSH / launchd |
| 5 | Записать `trigger_id`, `status: assigned` | DP.ROLE.NNN | git commit |
| 6 | Дождаться завершения | агент | внешний канал |
| 7 | Проверить acceptance | DP.ROLE.NNN | acceptance-check |
| 8 | Записать result-файл, `status: completed/failed` | DP.ROLE.NNN | git commit |
| 9 | При P0-failed — уведомить пилота | DP.ROLE.NNN → DP.ROLE.NNN | Telegram |
| 10 | Архивировать через 7 дней | DP.ROLE.NNN (Scout sweeper) | mv в archive/YYYY/ |

## Связь с другими обещаниями

- Потребляет: **DP.SC.NNN** (Notification Dispatcher — для уведомлений о P0-failed) — указать свой номер
- Используется в: будущие интеграции с ботами / онбордингом / nudges

---

## Заметки для адаптации

**Когда уместен этот паттерн:**
- Появилось ≥3 типов задач, делегируемых агенту по расписанию или вне сессии
- Результаты регулярно теряются (где сложил агент?), нужна единая точка
- Несколько каналов запуска (CCR + systemd + local) — нужен координатор

**Когда НЕ уместен:**
- Одна-две разовые задачи — проще руками
- Все задачи однотипны и идут через один канал — добавь явный `result_location` в каждую без Dispatcher-абстракции

**Принцип однозначного `result_location` (см. distinctions):** задача обязана содержать явный путь результата (`repo+branch+path`). Карта-derived маршрутизация (когда путь выводится из таблицы) — допустима только с 4 условиями: нет override, тотальная derivation, freeze-at-assignment, отделённая Карта-функция. На малых масштабах не стоит — явный путь проще.
