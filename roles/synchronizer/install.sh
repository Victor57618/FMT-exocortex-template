#!/bin/bash
# Synchronizer: установка центрального диспетчера (launchd)
# Заменяет отдельные launchd-агенты Стратега единым scheduler
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLIST_SRC="$SCRIPT_DIR/scripts/launchd/com.exocortex.scheduler.plist"
PLIST_DST="$HOME/Library/LaunchAgents/com.exocortex.scheduler.plist"

echo "Installing Synchronizer (central scheduler)..."

if [ ! -f "$PLIST_SRC" ]; then
    echo "ERROR: $PLIST_SRC not found"
    exit 1
fi

# Делаем скрипты исполняемыми
chmod +x "$SCRIPT_DIR/scripts/"*.sh
chmod +x "$SCRIPT_DIR/scripts/templates/"*.sh 2>/dev/null || true

# Выгружаем старые агенты
launchctl unload "$PLIST_DST" 2>/dev/null || true
# Выгружаем также legacy Стратег-агенты (если были)
launchctl unload "$HOME/Library/LaunchAgents/com.strategist.morning.plist" 2>/dev/null || true
launchctl unload "$HOME/Library/LaunchAgents/com.strategist.weekreview.plist" 2>/dev/null || true

# Создаём директории состояния
mkdir -p "$HOME/.local/state/exocortex"
mkdir -p "$HOME/logs/synchronizer"

# Копируем и загружаем
cp "$PLIST_SRC" "$PLIST_DST"
launchctl load "$PLIST_DST"

echo "  ✓ Installed: com.exocortex.scheduler"
echo "  ✓ Schedule: 10 dispatch points per day"
echo "  ✓ Manages: Strategist, Extractor, Code-Scan, Daily Report"
echo "  ✓ State: ~/.local/state/exocortex/"
echo "  ✓ Logs: ~/logs/synchronizer/"
echo ""
echo "Verify: launchctl list | grep exocortex"
echo "Status: bash $SCRIPT_DIR/scripts/scheduler.sh status"
echo ""
echo "Auto-wake (recommended): plan ready before you wake up"
if [[ "$(uname)" == "Darwin" ]]; then
    echo "  sudo pmset repeat wakeorpoweron MTWRFSU 03:55:00"
    echo "  sudo pmset -b sleep 0 && sudo pmset -b standby 0  # laptop: prevent sleep on battery profile"
    echo "  (Cancel: sudo pmset repeat cancel)"
else
    echo "  Linux: sudo rtcwake or systemd timer with WakeSystem=true"
    echo "  See docs/SETUP-GUIDE.md for details"
fi
echo ""
echo "Telegram (optional): create ~/.config/aist/env with:"
echo "  export TELEGRAM_BOT_TOKEN=\"your-token\""
echo "  export TELEGRAM_CHAT_ID=\"your-id\""
echo ""
echo "Uninstall: launchctl unload $PLIST_DST && rm $PLIST_DST"
