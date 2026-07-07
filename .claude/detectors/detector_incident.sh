#!/bin/bash
# detector_incident.sh
# see DP.SC.025 (capture-bus service clause), DP.ROLE.001#R47 (Детектор)
# event_type: agent_incident
# cost_class: free (rule-based)
# runtime: shell
#
# Нумерация паттернов — source-of-truth:
#   PACK-digital-platform/pack/digital-platform/05-failure-modes/DP.FM.010
#
# v1 ловит один паттерн:
#   P3_structure_without_map — Write нового .md в корень репо без проверки
#                              routing-карты DP.KR.001 §5 (кроме enumerated CLAUDE.md,
#                              README.md, MEMORY.md и т.п.).
#
# TODO расширение в Ф8.3+: отдельные детекторы для остальных паттернов DP.FM.010 —
#   P1 (detector_pattern_awareness, write в feedback_*.md),
#   P4 (detector_owner_integrity),
#   P5 (detector_verification),
#   P6 (detector_snapshot — destructive-команды без предшествующего read),
#   P7 (detector_confirmation — regex на Stop output),
#   P8 (detector_layer_leak),
#   P9 (detector_compound_command).

set -uo pipefail

# Load unified environment: WORKSPACE_DIR, IWE_ROOT, IWE_SCRIPTS, etc.
DETECTOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$(cd "$DETECTOR_DIR/.." && pwd)"
# shellcheck source=../lib/iwe-env-bootstrap.sh
source "$CLAUDE_DIR/lib/iwe-env-bootstrap.sh" || exit 1

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')
CWD=$(echo "$INPUT" | jq -r '.cwd // empty')

# v1: ловим только Write/Edit в enumerated подозрительные места.
# Расширение — отдельный WP.
if [ "$TOOL_NAME" != "Write" ] && [ "$TOOL_NAME" != "Edit" ]; then
  exit 0
fi

if [ -z "$FILE_PATH" ]; then
  exit 0
fi

# Определяем target_repo для эмиссии
IWE_ROOT="${IWE_ROOT:-$HOME/IWE}"
TARGET_REPO_HINT=""

# Если file_path абсолютный → ищем git root выше
# ВАЖНО: нормализуем FILE_PATH через realpath директории, чтобы совпадали префиксы
# (macOS /var → /private/var, symlinks и т.п.)
if [[ "$FILE_PATH" == /* ]]; then
  DIR=$(dirname "$FILE_PATH")
  if [ -d "$DIR" ]; then
    DIR_REAL=$(cd "$DIR" 2>/dev/null && pwd -P)
    BASENAME=$(basename "$FILE_PATH")
    FILE_PATH="$DIR_REAL/$BASENAME"
    GIT_ROOT=$(cd "$DIR_REAL" 2>/dev/null && git rev-parse --show-toplevel 2>/dev/null || true)
    if [ -n "$GIT_ROOT" ]; then
      TARGET_REPO_HINT="$GIT_ROOT"
    fi
  fi
fi

# Fallback: cwd как hint, если внутри ~/IWE/*/
if [ -z "$TARGET_REPO_HINT" ] && [ -n "$CWD" ]; then
  if [[ "$CWD" == "$IWE_ROOT"/* ]]; then
    REL="${CWD#$IWE_ROOT/}"
    FIRST_SEG="${REL%%/*}"
    if [ -n "$FIRST_SEG" ] && [ -d "$IWE_ROOT/$FIRST_SEG" ]; then
      TARGET_REPO_HINT="$IWE_ROOT/$FIRST_SEG"
    fi
  fi
fi

# Если target_repo не определился — проглатываем (OwnerIntegrity: не угадываем)
if [ -z "$TARGET_REPO_HINT" ]; then
  exit 0
fi

# v1 правило: Write нового файла в папку, которой нет в routing карте.
# Проверяем один конкретный паттерн — новый .md в корне любого репо ~/IWE/*
# (обычно знания уходят в docs/, inbox/, memory/ — корень для CLAUDE.md, README.md и т.п.)
matched=""
pattern=""
description=""

if [ "$TOOL_NAME" = "Write" ] && [[ "$FILE_PATH" == *.md ]]; then
  # relative to target repo
  REL_PATH="${FILE_PATH#$TARGET_REPO_HINT/}"
  # Нет слэша = файл в корне
  if [[ "$REL_PATH" != */* ]]; then
    # Известные разрешённые корневые .md
    base=$(basename "$REL_PATH")
    case "$base" in
      CLAUDE.md|README.md|MEMORY.md|WORKPLAN.md|REGISTRY.md|MAP.md|STAGING.md|PROCESSES.md|CHANGELOG.md)
        : ;;
      *)
        matched="true"
        pattern="P3_structure_without_map"
        description="Write новый .md в корень репо ($base). Routing карта (DP.KR.001 §5) ожидает знание в docs/, inbox/ или тематической подпапке."
        ;;
    esac
  fi
fi

if [ -z "$matched" ]; then
  exit 0
fi

jq -n \
  --arg pattern "$pattern" \
  --arg severity "minor" \
  --arg description "$description" \
  --arg tool_name "$TOOL_NAME" \
  --arg file_path "$FILE_PATH" \
  --arg hint "$TARGET_REPO_HINT" \
  '{
    event_type: "agent_incident",
    payload: {
      pattern: $pattern,
      severity: $severity,
      description: $description,
      tool_context: {
        tool_name: $tool_name,
        file_path: $file_path
      }
    },
    repo_ctx: {
      target_repo_hint: $hint
    }
  }'

exit 0
