---
id: TASK-5
title: '보안 기준선 점검으로 확장: 비밀값 스캔·push 보호·Dependabot·Actions 권한·SECURITY.md'
status: To Do
assignee: []
created_date: '2026-11-05T20:03:00Z'
updated_date: '2026-11-05T20:03:00Z'
labels:
  - security
  - governance
  - ci
dependencies: []
references:
  - source-header TASK-21(이관 원본)
documentation:
  - ~/.claude/plans/giggly-kindling-snowglobe.md
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
이관(2026-11-06): source-header TASK-21에서 옮겼다. 원래 카드는 source-header backlog/archive에 있고, 옛 커밋 해시는 coralstay-archive 보관본에서 확인한다. 이 저장소의 새 ID는 TASK-5.

## 배경
유저 최종 목표 4단계. TASK-17(main-protect 중앙 점검 워크플로)을 확장해 저장소 보안 기준선 전체를 매일 점검·적용한다. 계획: ~/.claude/plans/giggly-kindling-snowglobe.md
항목: 비밀값 스캔 + push 보호, Dependabot 알림·보안 업데이트, private 취약점 신고, CodeQL 기본 설정(public), Actions 기본 토큰 읽기 전용·PR 생성 금지·허용 액션 제한, SECURITY.md·LICENSE·dependabot.yml 존재 보고, 로컬 .githooks에 gitleaks 플러그인.
TASK-17에 의존한다.
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 워크플로가 저장소마다 비밀값 스캔·push 보호·Dependabot 알림/보안 업데이트·private 취약점 신고·CodeQL 기본 설정(public)을 점검하고 가능한 것은 켠다
- [ ] #2 Actions 설정(기본 토큰 읽기 전용, Actions의 PR 생성·승인 금지, 허용 액션 제한)을 점검·적용한다
- [ ] #3 SECURITY.md·LICENSE·.github/dependabot.yml 존재 여부를 표로 보고한다
- [ ] #4 dry-run과 실제 실행 결과가 Step Summary 표로 남는다
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 판정 로직 단위 테스트 통과
- [ ] #2 dry-run·실제 실행 결과를 Notes에 첨부
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
### Subjective
유저가 새 출발에 맞춰 저장소 보안 설정을 여러 방법을 비교해 새로 구성하길 원한다.

### Objective
TASK-17이 main-protect 중앙 점검 워크플로를 만든다. 무료 요금제에서 규칙·비밀값 push 보호는 public 저장소만 된다.

### Assessment
TASK-17의 조정 루프에 기준선 항목을 플러그인처럼 더한다. 쓰기 API가 없는 항목은 보고만 한다.

### Plan
1. 항목별 API 확인과 판정 함수 테스트
2. 워크플로에 기준선 단계 추가
3. GF 쪽 .githooks gitleaks 플러그인(별도 카드 연계)
4. dry-run → 실제 실행
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
계획 4절(2026-11-06): 이 카드에서 CI 최종 방어선을 함께 만든다 — PR에서 Done으로 바뀐 카드마다 Plan-Approved · Manual-Verified 커밋이 GitHub Verified이고 사람 키 지문과 맞는지 확인하는 필수 검사(판정은 agile-hooks scripts/card_gate.py). 무료 요금제에서 필수 검사는 public 저장소만 강제되므로 private 저장소는 로컬 방어(agile-hooks 훅 · commit-tool pre-push)에 의존한다는 점을 runbook에 적는다. AC로 넣는 것은 승인 전 계획 리뷰 때 정한다.
<!-- SECTION:NOTES:END -->
