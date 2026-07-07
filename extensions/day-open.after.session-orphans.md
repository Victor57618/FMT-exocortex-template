### 7c. Незакрытые external-сессии через бот (WP-358 Ф10)

> Сканировать `inbox/agent/sessions/SESSION-*.md` (Telegram-инициированные сессии через `/claude`).
> Незакрытая = `status != "completed"` ИЛИ (`status: completed` И возраст ≥24ч без перемещения в `sessions/external/`).
> Backfill pre-cutover файлов не делаем — фильтр по mtime ≥ CUTOVER_DATE в скрипте.
> При N>0 — вставить markdown-секцию в DayPlan (между «Требует внимания» и «Контекст недели») + продублировать в stdout.
> Молча пропустить при N=0. Аналог 7a (peer-сессии DP.SC.154), но для external-канала (DP.SC.NNN external-session-request).

```bash
SECTION=$(bash {{IWE_GOVERNANCE_REPO}}/scripts/check-open-sessions.sh 2>/dev/null)
if [ -n "$SECTION" ]; then
  echo "$SECTION"
  FILE="$(ls {{IWE_GOVERNANCE_REPO}}/current/DayPlan\ *.md 2>/dev/null | head -1)"
  if [ -f "$FILE" ] && ! grep -q "Незакрытые сессии" "$FILE"; then
    if grep -q "<summary><b>Контекст недели" "$FILE"; then
      python3 -c "
import sys
file=sys.argv[1]; section=sys.argv[2]
with open(file) as f: lines=f.readlines()
out=[]
inserted=False
for line in lines:
    if not inserted and '<summary><b>Контекст недели' in line:
        out.append(section+'\n\n')
        inserted=True
    out.append(line)
with open(file,'w') as f: f.writelines(out)
" "$FILE" "$SECTION"
      echo "  ✅ Секция «Незакрытые сессии» вставлена в DayPlan"
    fi
  fi
fi
```

- [ ] Если есть `SESSION-*` post-cutover в `inbox/agent/sessions/` со status != completed или age≥24ч — секция вставлена в DayPlan со ссылками. Финализация — DP.SC.NNN §close.
