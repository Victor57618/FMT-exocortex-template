#!/bin/bash
# Детерминированная очистка обработанных заметок из fleeting-notes.md.
#
# Страховочная сеть для Note-Review Step 10: LLM часто копирует заметки в архив,
# но забывает удалить из источника (галлюцинация tool-use).
#
# Логика:
# 1. Парсит fleeting-notes.md на заголовок + блоки заметок (разделитель ---)
# 2. Архивирует блоки без **жирного** заголовка и без 🔄 в Notes-Archive.md
# 3. Удаляет их из fleeting-notes.md
#
# Правила сохранения:
#   **жирный** заголовок → новая заметка, ОСТАВИТЬ
#   🔄 в заголовке        → нужен ревью, ОСТАВИТЬ
#   всё остальное          → обработано, АРХИВИРОВАТЬ

set -euo pipefail

WORKSPACE="/c/Users/tocpeople/IWE/DS-strategy"
FLEETING="${WORKSPACE}/inbox/fleeting-notes.md"
ARCHIVE="${WORKSPACE}/archive/notes/Notes-Archive.md"
TODAY=$(date +%Y-%m-%d)

if [ ! -f "$FLEETING" ]; then
    echo "fleeting-notes.md not found, nothing to do"
    exit 0
fi

# --- Парсинг: разделяем заголовок и блоки ---

# Находим конец заголовка: пропускаем frontmatter (---...---), затем ищем первый --- после него
HEADER_END=0
IN_FRONTMATTER=0
PAST_FRONTMATTER=0
LINE_NUM=0

while IFS= read -r line; do
    LINE_NUM=$((LINE_NUM + 1))
    stripped=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    if [ "$stripped" = "---" ] && [ "$PAST_FRONTMATTER" -eq 0 ]; then
        if [ "$IN_FRONTMATTER" -eq 0 ]; then
            IN_FRONTMATTER=1
        else
            PAST_FRONTMATTER=1
        fi
        continue
    fi

    if [ "$PAST_FRONTMATTER" -eq 1 ] && [ "$stripped" = "---" ]; then
        HEADER_END=$LINE_NUM
        break
    fi
done < "$FLEETING"

if [ "$HEADER_END" -eq 0 ]; then
    echo "No note blocks found (header end not detected), nothing to clean"
    exit 0
fi

# Извлекаем заголовок и остальное
HEADER=$(head -n "$HEADER_END" "$FLEETING")
REST=$(tail -n +"$((HEADER_END + 1))" "$FLEETING" | sed '/^$/d; /^[[:space:]]*$/d')

if [ -z "$REST" ]; then
    echo "No note blocks found, nothing to clean"
    exit 0
fi

# --- Разбиваем на блоки по разделителю --- ---

KEEP_BLOCKS=""
ARCHIVE_BLOCKS=""
KEEP_COUNT=0
ARCHIVE_COUNT=0
CURRENT_BLOCK=""

process_block() {
    local block="$1"
    [ -z "$block" ] && return

    local first_line
    first_line=$(echo "$block" | head -1 | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')

    # Проверка: жирный заголовок или 🔄
    if echo "$first_line" | grep -q '^\*\*'; then
        KEEP_BLOCKS="${KEEP_BLOCKS}${block}
---SEPARATOR---
"
        KEEP_COUNT=$((KEEP_COUNT + 1))
    elif echo "$first_line" | grep -q '🔄'; then
        KEEP_BLOCKS="${KEEP_BLOCKS}${block}
---SEPARATOR---
"
        KEEP_COUNT=$((KEEP_COUNT + 1))
    else
        # Защита: не удалять заметки моложе 24ч (catch-up note-review может снять bold без реальной обработки)
        local note_date_str
        note_date_str=$(echo "$block" | grep -oP '(?<=<sub>)\d{1,2}\s+\w{3}' | head -1)
        local is_fresh=0
        if [ -n "$note_date_str" ]; then
            # Простая проверка: если заметка от сегодня или вчера, считаем свежей
            local note_day note_month
            note_day=$(echo "$note_date_str" | awk '{print $1}')
            note_month=$(echo "$note_date_str" | awk '{print $2}')
            local today_day today_month yesterday_day yesterday_month
            today_day=$(date +%d | sed 's/^0//')
            today_month=$(date +%b | tr '[:upper:]' '[:lower:]')
            yesterday_day=$(date -v-1d +%d 2>/dev/null || date -d yesterday +%d 2>/dev/null | sed 's/^0//')
            yesterday_month=$(date -v-1d +%b 2>/dev/null || date -d yesterday +%b 2>/dev/null | tr '[:upper:]' '[:lower:]')
            note_month_lower=$(echo "$note_month" | tr '[:upper:]' '[:lower:]')
            if [ "$note_day" = "$today_day" ] || [ "$note_day" = "$yesterday_day" ]; then
                is_fresh=1
            fi
        fi
        if [ "$is_fresh" -eq 1 ]; then
            KEEP_BLOCKS="${KEEP_BLOCKS}${block}
---SEPARATOR---
"
            KEEP_COUNT=$((KEEP_COUNT + 1))
        else
            ARCHIVE_BLOCKS="${ARCHIVE_BLOCKS}${block}
---SEPARATOR---
"
            ARCHIVE_COUNT=$((ARCHIVE_COUNT + 1))
        fi
    fi
}

# Читаем REST построчно, разбивая на блоки по ---
while IFS= read -r line; do
    stripped=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    if [ "$stripped" = "---" ]; then
        process_block "$CURRENT_BLOCK"
        CURRENT_BLOCK=""
    else
        if [ -n "$CURRENT_BLOCK" ]; then
            CURRENT_BLOCK="${CURRENT_BLOCK}
${line}"
        else
            CURRENT_BLOCK="${line}"
        fi
    fi
done <<< "$REST"

# Обработать последний блок (если нет завершающего ---)
process_block "$CURRENT_BLOCK"

if [ "$ARCHIVE_COUNT" -eq 0 ]; then
    echo "No processed notes to archive"
    exit 0
fi

# --- Записываем в архив ---

ARCHIVE_SECTION="
## ${TODAY} — Auto-cleanup

"

# Разбираем ARCHIVE_BLOCKS по разделителю
while IFS= read -r -d '' block_chunk; do
    [ -z "$block_chunk" ] && continue
    ARCHIVE_SECTION="${ARCHIVE_SECTION}${block_chunk}
**Категория:** auto-cleanup

---

"
done < <(echo "$ARCHIVE_BLOCKS" | sed 's/---SEPARATOR---/\x00/g')

# Дописываем в архив
if [ -f "$ARCHIVE" ]; then
    printf '\n%s' "$ARCHIVE_SECTION" >> "$ARCHIVE"
else
    mkdir -p "$(dirname "$ARCHIVE")"
    printf '%s' "$ARCHIVE_SECTION" > "$ARCHIVE"
fi

# --- Перезаписываем fleeting-notes.md ---

if [ "$KEEP_COUNT" -gt 0 ]; then
    KEPT_SECTION=""
    while IFS= read -r -d '' block_chunk; do
        [ -z "$block_chunk" ] && continue
        KEPT_SECTION="${KEPT_SECTION}

${block_chunk}

---
"
    done < <(echo "$KEEP_BLOCKS" | sed 's/---SEPARATOR---/\x00/g')

    printf '%s\n%s\n' "$HEADER" "$KEPT_SECTION" > "$FLEETING"
else
    printf '%s\n' "$HEADER" > "$FLEETING"
fi

echo "Cleaned: ${ARCHIVE_COUNT} archived, ${KEEP_COUNT} kept"
