---
id: DRAFT-7
title: 훅이 명령의 대상 저장소가 아니라 세션 작업 폴더를 기준으로 판정한다
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
증상: `cd <B> && git commit`이 세션 저장소 A의 testCommand·브랜치 규칙으로 판정됨. 실제로 다른 저장소의 task 브랜치 때문에 push가 막힘. 우회로 `cd`를 별도 명령으로 먼저 실행. 고칠 곳: agile-hooks TASK-67
<!-- SECTION:DESCRIPTION:END -->
