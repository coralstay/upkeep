---
id: TASK-4
title: '기존 이력 보관과 전 저장소 재초기화: coralstay-archive 이전 + 로컬 mirror + 새 첫 커밋'
status: To Do
assignee: []
created_date: '2026-11-05T20:02:00Z'
updated_date: '2026-11-05T20:03:00Z'
labels:
  - archive
  - reinit
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
이관(2026-11-06): source-header TASK-20에서 옮겼다. 원래 카드는 source-header backlog/archive에 있고, 옛 커밋 해시는 coralstay-archive 보관본에서 확인한다. 이 저장소의 새 ID는 TASK-4.

## 배경
유저 최종 목표 2·3단계. 계획: ~/.claude/plans/giggly-kindling-snowglobe.md
18개 저장소의 기존 이력(PR·이슈 포함)을 GitHub 무료 조직 coralstay-archive로 옮겨 Private·Archived로 보관하고, 로컬은 ~/githubs-archive/2026-11-01/에 mirror로 보관한 뒤, 모든 저장소를 coralstay <231006716+coralstay@users.noreply.github.com>으로 재초기화한다. TASK-18(HEAD 민감정보 정리)과 신원·키 카드가 선행한다. source-header는 진행 중 카드의 승인 이력이 있어 마지막에 한다.

## 비즈니스 규칙
- B1 (AC #1) 보관이 확인되기 전에는 어떤 저장소의 .git도 지우지 않는다
- B2 (AC #3) 새 첫 커밋 전에 추적 대상에 민감 패턴(옛 계정명·옛 이메일·실명, 로컬 홈 경로, VM 정보, Drive ID)과 제3자 경로가 0이어야 한다
- B3 (AC #3) 새 GitHub 저장소는 Private으로 만든다(공개는 별도 카드)
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 [수동 검증] 18개 저장소의 로컬 mirror가 ~/githubs-archive/2026-11-01/에 있고 git fsck가 통과한다
- [ ] #2 [수동 검증] 18개 저장소가 coralstay-archive 조직에 Private·Archived로 보관되고 PR·이슈 수가 이전 전과 같다(B1)
- [ ] #3 [수동 검증] 저장소마다 새 첫 커밋 전 추적 대상 민감 패턴·제3자 경로가 0이다(B2)
- [ ] #4 [수동 검증] 18개 저장소가 coralstay 계정에 Private으로 새로 만들어지고(B3) 커밋 1개, 작성자 coralstay <231006716+coralstay@users.noreply.github.com>, 사람 서명 Verified다
- [ ] #5 [수동 검증] 로컬 무시 파일(책 원본·데이터 등)이 그대로 남아 있다
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 [수동 검증] 저장소별 미리보기·패턴 검사·gitleaks 결과를 Notes에 첨부
- [ ] #2 [수동 검증] 보관 조직과 새 저장소 목록을 gh로 확인한 결과를 Notes에 첨부
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
### Subjective
유저가 기존 이력을 GitHub 보관 조직과 로컬에 보관한 뒤 모든 저장소를 새 신원으로 재초기화하길 원한다.

### Objective
18개 저장소, public 6(규칙 main-protect, PR만), private 12. 백업 bundle은 ~/githubs-backup/2026-10-31·2026-11-01. 훅이 gh repo delete·main push를 막는다. source-header에 진행 중 카드 승인 이력이 있다.

### Assessment
보관은 조직 이전(transfer)으로 PR·이슈까지 보존하고, 재초기화는 TASK-16과 같은 절차(미리보기→rm .git→init→사람 서명 첫 커밋→Private 생성→push). 외부 작업은 유저 실행 스크립트로.

### Plan
1. 로컬 mirror 18개 + fsck
2. 유저: coralstay-archive 조직 생성, transfer·Private·Archived 스크립트 실행
3. 저장소별 재초기화 준비(미리보기·패턴 0 확인)
4. 유저: 첫 커밋(Touch ID)·create·push 스크립트 실행
5. source-header 마지막, 진행 중 카드 재승인
<!-- SECTION:PLAN:END -->
