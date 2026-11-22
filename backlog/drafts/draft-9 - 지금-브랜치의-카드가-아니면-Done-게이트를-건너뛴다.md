---
id: DRAFT-9
title: 지금 브랜치의 카드가 아니면 Done 게이트를 건너뛴다
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
증상: source-header task/TASK-20 브랜치에서 `backlog task edit TASK-3 -s Done`·`TASK-16 -s Done`이 검사 없이 통과(require_test_first는 브랜치의 카드만 검사). 종류: 규칙이 새는 곳. 고칠 곳: agile-hooks DRAFT-11(브랜치 무관 검사)
<!-- SECTION:DESCRIPTION:END -->
