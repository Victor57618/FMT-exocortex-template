# Changelog

All notable changes to FMT-exocortex-template will be documented in this file.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning: [Semantic Versioning](https://semver.org/).

## [0.5.0] — 2026-03-10

### Added
- **CHANGELOG.md** — human-readable история изменений шаблона (Apple-style release notes)
- **update.sh: release notes** — при обновлении показывает «What's New» из CHANGELOG
- **update.sh: re-substitution** — автоматическая подстановка `{{WORKSPACE_DIR}}` после merge upstream (раньше плейсхолдеры оставались сырыми)
- **DATA-POLICY.md** — политика данных IWE + acceptance gate в setup.sh

### Fixed
- **Hardcoded paths** — 14 файлов с `~/Github` или `$HOME/Github` заменены на `{{WORKSPACE_DIR}}` (шаблон работает с любой рабочей директорией, не только `~/Github`)
  - `strategist.sh`, `cleanup-processed-notes.sh`, `scheduler.sh` (shell-скрипты)
  - `add-wp.md`, `check-plan.md`, `evening.md` (промпты стратега)
  - `seed/strategy/CLAUDE.md` (6 вхождений)
  - `memory/protocol-open.md`, `memory/fpf-reference.md`, `memory/checklists.md`
  - `setup/validate-template.sh`
- **update.sh fallback** — убран хардкод `~/Github/FMT-exocortex`, теперь только динамическое определение директории

### Changed
- **Default workspace name** — документация (README, SETUP-GUIDE, IWE-HELP, LEARNING-PATH) теперь рекомендует `~/IWE` вместо `~/Github` как имя рабочей директории

## [0.4.0] — 2026-03-01

### Added
- **setup.sh** встроен в шаблон (ADR-001, АрхГейт 6.4→8.3)
- **Модульные роли** с `role.yaml` autodiscovery (ADR-002, АрхГейт 8.9)
- **Core-режим** установки (`--core`) — только git, без сети
- **Vendor-agnostic AI CLI** — поддержка Codex, Aider, Continue.dev через переменные
- **Авто-переименование репо** при установке
- **Творческий конвейер** — 7 категорий заметок, draft-list, guards
- **WP-REGISTRY** — seed template для отслеживания РП
- **Экзоскелет vs протез** — принцип #21 в LEARNING-PATH

### Fixed
- **setup.sh fallback** — явное предупреждение при отсутствии `seed/strategy/`
- **Битая ссылка** FPF/README.md
- **Приватные ссылки** убраны из README

## [0.3.0] — 2026-02-16

### Added
- **LEARNING-PATH.md** — полный путь изучения экзокортекса (T1→T5)
- **update.sh** — обновление шаблона из upstream (fetch + merge + reinstall)
- **SETUP-GUIDE.md** — пошаговое руководство установки
- **IWE-HELP.md** — быстрый справочник
- **АрхГейт (ЭМОГССБ)** — 7 характеристик в CLAUDE.md
- **SOTA-reference.md** — справочник SOTA-практик
- **WakaTime** — интеграция в стратег-отчёты

## [0.2.0] — 2026-02-09

### Added
- **Note-Review** — сценарий обзора заметок + детерминированная очистка
- **WP Context Files** — поддержка inbox/WP-*.md
- **CI: validate-template.yml** — проверка генеративности на каждый push
- **ONTOLOGY.md** — терминология платформы

## [0.1.0] — 2026-01-27

### Added
- Начальная структура шаблона экзокортекса
- CLAUDE.md, memory/, roles/ (стратег, экстрактор, синхронизатор)
- Стратег: session-prep, day-plan, strategy-session, week-review
- seed/strategy/ — шаблон DS-strategy
