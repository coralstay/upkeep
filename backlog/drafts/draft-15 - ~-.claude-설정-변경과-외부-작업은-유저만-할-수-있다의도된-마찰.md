---
id: DRAFT-15
title: ~/.claude 설정 변경과 외부 작업은 유저만 할 수 있다(의도된 마찰)
status: Draft
assignee: []
created_date: '2026-11-05T20:05:00Z'
labels:
  - friction
  - tool:claude-code
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
증상: settings.json·hooks 설치·main push·gh repo delete·Touch ID 서명은 config_guard·훅·키 보호 때문에 에이전트가 못 하고 유저가 스크립트·명령으로 실행. 의도된 보호라 고치지 않는다 — 기록만. 개선 여지: 유저가 실행할 명령을 한 번에 모아 안내
<!-- SECTION:DESCRIPTION:END -->
