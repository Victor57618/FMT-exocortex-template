# Optional Components

Optional features that enhance IWE but are not required for core functionality.

## Pomodoro Break Reminders

Monitors your coding activity via WakaTime and sends a macOS notification when you've been working continuously for too long.

### Prerequisites

- **WakaTime** installed and configured (`~/.wakatime.cfg` with `api_key`)
- **macOS** (uses `osascript` for notifications)
- **Python 3** (pre-installed on macOS)

### Installation

```bash
# 1. Replace placeholder with your workspace path
sed "s|{{WORKSPACE_DIR}}|$HOME/IWE|g" setup/optional/pomodoro-alert.plist \
  > ~/Library/LaunchAgents/com.exocortex.pomodoro-alert.plist

# 2. Load the agent (starts immediately, runs every 5 min)
launchctl load ~/Library/LaunchAgents/com.exocortex.pomodoro-alert.plist

# 3. Verify it's running
launchctl list | grep pomodoro
```

### Configuration

Edit `memory/day-rhythm-config.yaml` → section `pomodoro`:

```yaml
pomodoro:
  work_minutes: 25          # Pomodoro work interval
  break_minutes: 5           # Short break
  long_break_minutes: 15     # Long break
  sessions_before_long_break: 4
  session_alert_minutes: 50  # Alert after this many continuous minutes
```

### How it works

1. Every 5 minutes, the script calls WakaTime Durations API
2. It calculates the current continuous work block (gaps > 5 min reset the counter)
3. If continuous work exceeds `session_alert_minutes`, a macOS notification appears
4. Alerts are suppressed for 10 minutes after each notification (no spam)

### Uninstall

```bash
launchctl unload ~/Library/LaunchAgents/com.exocortex.pomodoro-alert.plist
rm ~/Library/LaunchAgents/com.exocortex.pomodoro-alert.plist
```

### Files

| File | Purpose |
|------|---------|
| `pomodoro-alert.py` | Python script (WakaTime API + macOS notification) |
| `pomodoro-alert.plist` | launchd agent template (replace `{{WORKSPACE_DIR}}`) |

---

## Day Rhythm Config

The file `memory/day-rhythm-config.yaml` controls several Day Open features:

- **Strategy day** — which day of the week to suggest a strategy session
- **Self-development slot** — always first in the daily plan
- **News digest** — optional news topics at Day Open (disabled by default)
- **Pomodoro settings** — break reminder thresholds

This file is read by Claude during Day Open (`protocol-open.md § День`). No installation needed — it works automatically once present in `memory/`.

---

## Cloud Scheduler (GitHub Actions)

IWE автоматика в облаке — работает даже когда Mac выключен. Базовый уровень: backup + health check. $0/мес.

**Сценарий:** [DP.SC.019](../../../PACK-digital-platform/pack/digital-platform/08-service-clauses/DP.SC.019-autonomous-cloud-runtime.md)

### Что делает

- **Backup memory:** ежедневно копирует `memory/` → `exocortex/` (git commit + push)
- **Health check:** проверяет наличие DayPlan, WeekPlan, свежесть backup, незакрытые сессии
- **Telegram-уведомления** (опционально): отправляет health report в Telegram

### Установка

```bash
bash setup/optional/setup-cloud-scheduler.sh
```

Скрипт проверит gh CLI, настроит секреты и запустит тестовый workflow.

### Ручная настройка

1. Убедитесь, что `.github/workflows/cloud-scheduler.yml` запушен в ваш DS-strategy репо
2. (Опционально) Настройте Telegram:
   ```bash
   gh secret set TELEGRAM_BOT_TOKEN --repo ВАШ_РЕПО --body "ТОКЕН"
   gh secret set TELEGRAM_CHAT_ID --repo ВАШ_РЕПО --body "ВАШ_ID"
   ```
3. Тестовый запуск: `gh workflow run cloud-scheduler.yml --repo ВАШ_РЕПО`

### Расписание

Ежедневно в 04:00 MSK (01:00 UTC): backup + health check.

### Files

| File | Purpose |
|------|---------|
| `cloud-scheduler.yml` | GitHub Actions workflow (backup + health check) |
| `setup-cloud-scheduler.sh` | Скрипт настройки (gh secrets + тест) |

---

## Cover Images (S48)

Автоматическая генерация обложек для постов через OpenAI GPT Image API. Каждая обложка уникальна и отражает содержание статьи.

Подробная инструкция: [COVER-IMAGES.md](COVER-IMAGES.md)

### Quick start

```bash
# 1. Положите API key
echo "sk-proj-ВАШ_КЛЮЧ" > .secrets/openai-api-key

# 2. Установите зависимости
pip install httpx pyyaml

# 3. Сгенерируйте обложку
python setup/optional/generate-post-image.py path/to/post.md
```

### Files

| File | Purpose |
|------|---------|
| `generate-post-image.py` | Python-скрипт генерации (GPT Image 1) |
| `COVER-IMAGES.md` | Подробная инструкция: промпты, параметры, стоимость |
