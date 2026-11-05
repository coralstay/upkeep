---
id: TASK-6
title: '저장소별 공개 전환: 재검사·기준선 확인 후 하나씩'
status: To Do
assignee: []
created_date: '2026-11-05T20:04:00Z'
updated_date: '2026-11-05T20:04:00Z'
labels:
  - public
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
이관(2026-11-06): source-header TASK-22에서 옮겼다. 원래 카드는 source-header backlog/archive에 있고, 옛 커밋 해시는 coralstay-archive 보관본에서 확인한다. 이 저장소의 새 ID는 TASK-6.

## 배경
유저 최종 목표 5단계. 재초기화된 저장소를 gitleaks·민감 패턴 재검사와 보안 기준선 확인을 통과한 것부터 하나씩 유저가 공개하고, 중앙 워크플로가 즉시 main-protect를 건다. 계획: ~/.claude/plans/giggly-kindling-snowglobe.md
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 저장소마다 공개 전 체크리스트(gitleaks no leaks, 민감 패턴 0, 기준선 ok)를 통과한다
- [ ] #2 공개 직후 main-protect와 비밀값 push 보호가 적용된 것을 확인한다
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 저장소별 체크리스트 결과를 Notes에 첨부
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
### Subjective
유저가 보안 기준 적용 후 저장소별로 공개하기로 정했다.

### Objective
공개 시 무료 요금제에서도 규칙을 걸 수 있다. 중앙 워크플로가 수동 실행으로 즉시 적용한다.

### Assessment
저장소마다 체크리스트(gitleaks·민감 패턴·기준선)를 통과한 것만 유저가 공개한다.

### Plan
1. 저장소별 체크리스트 실행
2. 유저 공개
3. 워크플로 수동 실행으로 규칙 적용 확인
<!-- SECTION:PLAN:END -->
