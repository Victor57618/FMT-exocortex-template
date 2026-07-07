## Agent Fault Profile (WP-316)

Запустить перед проверками — чтобы не пропустить шаги с историей пропусков:

```bash
python3 {{WORKSPACE_DIR}}/{{GOVERNANCE_REPO}}/scripts/agent_fault_remind.py --protocol close
```

🔴-пункты = часто пропускаемые именно при Close. Применить немедленно к оставшимся шагам.

> Если в этой сессии обнаружен новый паттерн косяка — добавить feedback-файл в `memory/`, затем:
> ```bash
> python3 {{WORKSPACE_DIR}}/{{GOVERNANCE_REPO}}/scripts/sync_feedback_to_memory.py
> ```
