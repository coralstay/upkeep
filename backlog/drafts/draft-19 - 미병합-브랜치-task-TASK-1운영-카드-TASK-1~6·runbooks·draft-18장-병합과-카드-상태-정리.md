---
id: DRAFT-19
title: 미병합 브랜치 task/TASK-1(운영 카드 TASK-1~6·runbooks·draft 18장) 병합과 카드 상태 정리
status: Draft
assignee: []
created_date: '2026-11-22T11:29:00Z'
labels:
  - cleanup
  - backlog
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
## 배경
유저(2026-11-22): 병합할 것을 모두 찾아 병합하자, 정리 카드를 먼저 하자.
- task/TASK-1: 커밋 53개, 원격 없음. 운영 카드 TASK-1~6(source-header TASK-17~22 에서 이관), friction 등 draft 18장, runbooks/secretive-short-read/ 가 들어 있다. main 에는 이 카드들이 없다(main 은 TASK-7 과 claude-config/ 만). backlog/work-order.md 충돌(add/add)
- 이 draft 는 번호 충돌을 피하려고 task/TASK-1 위에서 만들었다(main 에서 만들면 DRAFT-1 이 겹친다)
계획: ~/.claude/plans/cleanup-unmerged-branches-cards.md (승인됨)

## 비즈니스 규칙
- B1 (AC #2) 근거 없는 Done 금지
- B2 (AC #1) 이력 보존: rebase·squash·force push 없음
- B3 (AC #2) TASK-2·3·4 는 Manual-Verified 게이트(agile-hooks TASK-73, 미구현)를 기다리므로 상태 유지, 노트만

## 하지 않는 것
남은 운영 카드의 실제 작업, TASK-73 구현
<!-- SECTION:DESCRIPTION:END -->
