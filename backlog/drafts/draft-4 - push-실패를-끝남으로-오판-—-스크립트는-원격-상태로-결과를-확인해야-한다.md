---
id: DRAFT-4
title: push 실패를 '끝남'으로 오판 — 스크립트는 원격 상태로 결과를 확인해야 한다
status: Draft
assignee: []
created_date: '2026-11-05T20:05:00Z'
labels:
  - friction
  - tool:upkeep-scripts
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
증상: reinit.sh가 push 실패 뒤 다시 실행하면 '이미 새 이력'으로 건너뜀. 해결: 로컬 HEAD와 원격 main(`git ls-remote`) 비교, 저장소 생성과 push를 분리해 이어서 하기. 교훈: 외부 작업 스크립트는 로컬이 아니라 원격 결과로 완료를 판정한다. 출처: TASK-4 Notes (3)
<!-- SECTION:DESCRIPTION:END -->
