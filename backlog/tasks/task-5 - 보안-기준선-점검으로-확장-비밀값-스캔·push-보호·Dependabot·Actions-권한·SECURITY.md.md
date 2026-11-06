---
id: TASK-5
title: '보안 기준선 점검으로 확장: 비밀값 스캔·push 보호·Dependabot·Actions 권한·SECURITY.md'
status: To Do
assignee: []
created_date: '2026-11-05T20:03:00Z'
updated_date: '2026-11-06T04:31:00Z'
labels:
  - security
  - governance
  - ci
dependencies:
  - TASK-1
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

결정 필요(2026-11-06): private 저장소의 main 보호. GitHub Free는 ruleset을 public에만 적용하므로 지금 새 저장소 17개 + upkeep은 main 보호가 없다. 훅(pre_git_safety_check)은 문자열 판정이라 gh api 다른 경로 · curl · 스크립트 · SSH push 변형을 다 막지 못한다(friction draft 'private 저장소에 main 보호가 없고…'). 선택지: (a) 공개 시점 앞당기기(TASK-6) (b) GitHub Pro로 private ruleset (c) 에이전트 전용 fine-grained PAT(contents 읽기 + PR 생성) + 에이전트 전용 SSH 인증 경로. 에이전트 PR 병합 허용 조건(CI 통과 + 사람 승인)도 함께 정한다. 계획 리뷰 때 AC로 반영.

적용(2026-11-06, 유저 지시): coralstay 저장소 19개 전부 병합 방식을 merge commit만 허용으로 바꿨다(`gh api -X PATCH repos/coralstay/<n> -F allow_squash_merge=false -F allow_rebase_merge=false`, 다시 조회해 19/19 merge=true squash=false rebase=false 확인). 이유: squash · rebase 병합은 사람 서명 Plan-Approved 커밋을 다른 커밋으로 바꿔 훅의 승인 판정 근거가 사라진다. 훅은 사람이 하는 병합을 볼 수 없어 GitHub 설정으로 강제한다(무료 private에서도 됨). 기준선 항목으로 넣을 것: 새 저장소 생성 시 같은 설정, 'Require linear history'는 켜지 않음(merge commit과 충돌), 중앙 점검 워크플로(TASK-1)가 점검 · 복구.
<!-- SECTION:NOTES:END -->
