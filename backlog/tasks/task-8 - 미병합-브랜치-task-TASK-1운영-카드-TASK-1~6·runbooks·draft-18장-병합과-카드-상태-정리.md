---
id: TASK-8
title: 미병합 브랜치 task/TASK-1(운영 카드 TASK-1~6·runbooks·draft 18장) 병합과 카드 상태 정리
status: In Progress
assignee: []
created_date: '2026-11-22T11:29:00Z'
updated_date: '2026-11-22T12:02:00Z'
labels:
  - cleanup
  - backlog
dependencies: []
documentation:
  - /Users/flynn_macpro/.claude/plans/cleanup-unmerged-branches-cards.md
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

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 정리 브랜치(origin/main 기준)에 task/TASK-1 을 merge 로 합치고(rebase·squash 없음), work-order.md 충돌은 work-order 재생성으로 푼다. TASK-7·claude-config/ 와 TASK-1~6·runbooks·draft 18장이 모두 main 쪽에 들어온다(B2)
- [ ] #2 카드 TASK-1~6 과 draft 18장의 상태를 분류표로 Notes 에 남긴다. 증거 있는 끝난 카드만 Done, TASK-2·3·4 는 Manual-Verified 대기로 상태 유지·노트(B1·B3)
- [ ] #3 합친 뒤 tests/ pytest 가 통과하고 backlog task list·draft list 가 정상이며(번호 중복 없음), 기존 task/TASK-1 브랜치는 병합 확인 뒤 지운다
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 분류표와 증거를 Notes 에 첨부
- [ ] #2 pytest·backlog list 출력 첨부
- [ ] #3 PR 이 있다
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
### Subjective
유저(2026-11-22)가 병합할 것을 모두 찾아 병합하자고 했고 정리 카드를 먼저 하자고 했다. 계획: ~/.claude/plans/cleanup-unmerged-branches-cards.md

### Objective
- task/TASK-1: 53커밋, 원격 없음, 운영 카드 TASK-1~6·draft 18장·runbooks/secretive-short-read/. main 은 TASK-7·claude-config/·tests/test_claude_config.py.
- 충돌은 backlog/work-order.md(add/add) 하나.
- 메모리: TASK-2·3·4 는 Manual-Verified(agile-hooks TASK-73) 대기, TASK-3 AC #4 는 Antigravity 서명 Verified 확인 — handcrafted-python 커밋이 ai-antigravity 키로 G 검증됨(2026-11-22 확인).

### Assessment
main 에서 정리 브랜치를 파고 task/TASK-1 을 merge 해 이력을 보존한다. work-order 는 재생성. 카드는 증거 있는 것만 상태를 바꾼다.

### Plan
1. 승격 → 서명 → In Progress → origin/main 에서 task/<ID> → task/TASK-1 merge, work-order 재생성.
2. 카드·draft 분류표, 증거 있는 것만 처리.
3. pytest·list 확인 → 브랜치 삭제 → Done → PR.
<!-- SECTION:PLAN:END -->
