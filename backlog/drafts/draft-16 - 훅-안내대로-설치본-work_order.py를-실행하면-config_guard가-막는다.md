---
id: DRAFT-16
title: 훅 안내대로 설치본 work_order.py를 실행하면 config_guard가 막는다
status: Draft
assignee: []
created_date: '2026-11-05T20:05:00Z'
labels:
  - friction
  - tool:agile-hooks
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
증상: require_work_order가 'python3 ~/.claude/hooks/claude-code-agile-hooks/work_order.py로 작업 순서를 다시 만들라'고 안내하는데, 그 명령은 config_guard가 '훅 경로 근처 인터프리터'로 차단(2026-11-06 upkeep 이관 중). 우회: 저장소 사본 scripts/work_order.py(설치본과 `cmp` 동일) 실행. 고칠 곳: 안내 문구를 config_guard가 허용하는 형태로 바꾸거나 config_guard가 읽기 전용 실행을 허용
<!-- SECTION:DESCRIPTION:END -->
