#!/bin/bash
# day-close.sh — Автоматические шаги Day Close (backup + reindex + linear sync)
#
# Вызывается Claude из протокола Day Close (protocol-close.md § День, шаг 4).
# Объединяет три механических операции в одну команду.
#
# Использование:
#   day-close.sh              # все три шага
#   day-close.sh --backup     # только backup
#   day-close.sh --reindex    # только reindex
#   day-close.sh --linear     # только linear sync
#
# Конфигурация: Пути заданы через переменные ниже — настроить при установке.

set -euo pipefail

# === КОНФИГУРАЦИЯ (настроить при установке) ===
WORKSPACE_DIR="${WORKSPACE_DIR:-$HOME/IWE}"
DS_STRATEGY="$WORKSPACE_DIR/DS-strategy"
MEMORY_SRC="$HOME/.claude/projects/-Users-$(whoami)-IWE/memory"
EXOCORTEX_DST="$DS_STRATEGY/exocortex"
SELECTIVE_REINDEX="$WORKSPACE_DIR/DS-MCP/knowledge-mcp/scripts/selective-reindex.sh"
LINEAR_SYNC="$WORKSPACE_DIR/DS-IT-systems/DS-ai-systems/synchronizer/scripts/linear-sync.sh"
FPF_DIR="$WORKSPACE_DIR/FPF"
SPF_DIR="$WORKSPACE_DIR/SPF"
LOG_FILE="$WORKSPACE_DIR/DS-agent-workspace/scheduler/day-close.log"
# === /КОНФИГУРАЦИЯ ===

# Цвета
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

log() { echo -e "${GREEN}[day-close]${NC} $1"; }
warn() { echo -e "${YELLOW}[day-close]${NC} $1"; }
err() { echo -e "${RED}[day-close]${NC} $1" >&2; }

# --- Шаг 1: Backup memory/ + CLAUDE.md → exocortex/ ---
do_backup() {
  log "Шаг 1/3: Backup memory/ → exocortex/"

  if [ ! -d "$MEMORY_SRC" ]; then
    err "Memory source not found: $MEMORY_SRC"
    return 1
  fi

  mkdir -p "$EXOCORTEX_DST"

  local count=0
  for f in "$MEMORY_SRC"/*.md "$MEMORY_SRC"/*.yaml "$MEMORY_SRC"/*.yml; do
    [ -f "$f" ] || continue
    cp "$f" "$EXOCORTEX_DST/"
    count=$((count + 1))
  done

  if [ -f "$WORKSPACE_DIR/CLAUDE.md" ]; then
    cp "$WORKSPACE_DIR/CLAUDE.md" "$EXOCORTEX_DST/CLAUDE.md"
    count=$((count + 1))
  fi

  log "  Скопировано: $count файлов → $EXOCORTEX_DST/"
}

# --- Шаг 2: Knowledge-MCP reindex ---
do_reindex() {
  log "Шаг 2/3: Knowledge-MCP reindex"

  if [ ! -x "$SELECTIVE_REINDEX" ]; then
    warn "  selective-reindex.sh не найден: $SELECTIVE_REINDEX — пропуск"
    return 0
  fi

  local changed_sources=""
  for repo in "$WORKSPACE_DIR"/PACK-* "$WORKSPACE_DIR"/DS-*; do
    [ -d "$repo/.git" ] || continue
    local repo_name
    repo_name=$(basename "$repo")
    local today_commits
    today_commits=$(git -C "$repo" log --since="today 00:00" --oneline --no-merges 2>/dev/null | wc -l | tr -d ' ')
    if [ "$today_commits" -gt 0 ]; then
      changed_sources="$changed_sources $repo_name"
    fi
  done

  if [ -z "$changed_sources" ]; then
    log "  Нет изменений в Pack/DS сегодня — пропуск reindex"
    return 0
  fi

  log "  Изменённые источники:$changed_sources"
  # shellcheck disable=SC2086
  "$SELECTIVE_REINDEX" $changed_sources
}

# --- Шаг 3: Linear sync ---
do_linear() {
  log "Шаг 3/3: Linear sync"

  if [ ! -x "$LINEAR_SYNC" ]; then
    warn "  linear-sync.sh не найден: $LINEAR_SYNC — пропуск"
    return 0
  fi

  "$LINEAR_SYNC"
}

# --- Шаг 4: FPF update ---
do_fpf_update() {
  log "Шаг 4/5: FPF git pull"

  if [ ! -d "$FPF_DIR/.git" ]; then
    warn "  FPF репозиторий не найден: $FPF_DIR — пропуск"
    return 0
  fi

  local result
  result=$(git -C "$FPF_DIR" pull --rebase 2>&1)
  if echo "$result" | grep -q "Already up to date"; then
    log "  FPF уже актуален"
  else
    log "  FPF обновлён: $(echo "$result" | tail -1)"
  fi
}

# --- Шаг 5: SPF update ---
do_spf_update() {
  log "Шаг 5/5: SPF git pull"

  if [ ! -d "$SPF_DIR/.git" ]; then
    warn "  SPF репозиторий не найден: $SPF_DIR — пропуск"
    return 0
  fi

  local result
  result=$(git -C "$SPF_DIR" pull --rebase 2>&1)
  if echo "$result" | grep -q "Already up to date"; then
    log "  SPF уже актуален"
  else
    log "  SPF обновлён: $(echo "$result" | tail -1)"
  fi
}

# --- Лог ---
write_log() {
  local date_str
  date_str=$(date "+%Y-%m-%d %H:%M")
  mkdir -p "$(dirname "$LOG_FILE")"
  echo "$date_str | day-close | backup=$1 reindex=$2 linear=$3 fpf=$4 spf=$5" >> "$LOG_FILE"
}

# --- Main ---
main() {
  local do_all=true
  local run_backup=false
  local run_reindex=false
  local run_linear=false
  local run_fpf=false
  local run_spf=false

  for arg in "$@"; do
    case "$arg" in
      --backup)  run_backup=true; do_all=false ;;
      --reindex) run_reindex=true; do_all=false ;;
      --linear)  run_linear=true; do_all=false ;;
      --fpf)     run_fpf=true; do_all=false ;;
      --spf)     run_spf=true; do_all=false ;;
      --help|-h)
        echo "Использование: day-close.sh [--backup] [--reindex] [--linear] [--fpf] [--spf]"
        echo "  Без аргументов — все пять шагов"
        exit 0
        ;;
      *)
        err "Неизвестный аргумент: $arg"
        exit 1
        ;;
    esac
  done

  if $do_all; then
    run_backup=true
    run_reindex=true
    run_linear=true
    run_fpf=true
    run_spf=true
  fi

  log "=== Day Close (автоматические шаги) ==="

  local backup_status="skip" reindex_status="skip" linear_status="skip" fpf_status="skip" spf_status="skip"

  if $run_backup; then
    if do_backup; then backup_status="ok"; else backup_status="fail"; fi
  fi

  if $run_reindex; then
    if do_reindex; then reindex_status="ok"; else reindex_status="fail"; fi
  fi

  if $run_linear; then
    if do_linear; then linear_status="ok"; else linear_status="fail"; fi
  fi

  if $run_fpf; then
    if do_fpf_update; then fpf_status="ok"; else fpf_status="fail"; fi
  fi

  if $run_spf; then
    if do_spf_update; then spf_status="ok"; else spf_status="fail"; fi
  fi

  write_log "$backup_status" "$reindex_status" "$linear_status" "$fpf_status" "$spf_status"

  log "=== Готово ==="
  log "  backup=$backup_status  reindex=$reindex_status  linear=$linear_status  fpf=$fpf_status  spf=$spf_status"
}

main "$@"
