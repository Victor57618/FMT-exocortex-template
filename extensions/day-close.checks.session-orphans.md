### 🟡 ПРОВЕРКА: Незакрытые external-сессии (WP-358 Ф10)

> Финализация sessions через `/claude` бот — DP.SC.NNN §close.
> Warning, не block: если есть незакрытые SESSION-* post-cutover — напомнить, но коммит проходит.

```bash
SECTION=$(bash {{IWE_GOVERNANCE_REPO}}/scripts/check-open-sessions.sh 2>/dev/null)
if [ -n "$SECTION" ]; then
  COUNT=$(printf '%s\n' "$SECTION" | grep -c '^| \[SESSION-' || true)
  echo "  🟡 $COUNT незакрытых external-сессии в inbox/agent/sessions/ — рассмотри финализацию (DP.SC.NNN §close)"
  printf '%s\n' "$SECTION" | grep '^| \[SESSION-' | head -5
else
  echo "  ✅ Незакрытых external-сессий нет"
fi
```

- [ ] Если ⚠️ — оценить, нужна ли финализация прямо сейчас (создать `sessions/external/YYYY-MM/SESSION-<id>/report.md` + `git mv`). Если не сегодня — закоммитить как есть, продолжит висеть до Day Open завтра.
