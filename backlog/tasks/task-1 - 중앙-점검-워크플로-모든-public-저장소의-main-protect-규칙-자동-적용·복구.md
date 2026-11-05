---
id: TASK-1
title: '중앙 점검 워크플로: 모든 public 저장소의 main-protect 규칙 자동 적용·복구'
status: To Do
assignee: []
created_date: '2026-11-05T20:01:00Z'
updated_date: '2026-11-05T20:01:00Z'
labels:
  - governance
  - github
  - ci
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
이관(2026-11-06): source-header TASK-17에서 옮겼다. 원래 카드는 source-header backlog/archive에 있고, 옛 커밋 해시는 coralstay-archive 보관본에서 확인한다. 이 저장소의 새 ID는 TASK-1.

## 배경
유저 결정(2026-11-01): 모든 저장소의 main은 직접 병합을 잠근다(ruleset main-protect: PR 필수, 서명 필수, 강제 push·삭제 금지, bypass 없음).
GitHub 무료 요금제는 private 저장소에 규칙을 걸 수 없어(403) 공개 직후 걸어야 하고, 기존에도 dev-toolchain처럼 꺼진 규칙이 방치된 사례가 있었다.
그래서 수동 스크립트(~/githubs-backup/2026-10-31/publish-and-protect.sh) 대신, 중앙 점검 워크플로가 주기적으로 모든 저장소를 기준 규칙으로 맞춘다(유저가 고른 안 A).
공개 전환 자체는 되돌릴 수 없는 결정이라 자동화하지 않는다.

## 설계
- 위치: coralstay/coralstay(프로필 저장소, public, main-protect 적용됨) — 로컬 ~/githubs/.github-profile
  - `.github/workflows/enforce-main-protect.yml`
  - `policy/main-protect.json` (기준 규칙, 지금 공개 저장소에 걸린 정의와 같음)
  - `scripts/enforce_main_protect.py` (표준 라이브러리 + 러너에 기본 설치된 gh CLI)
  - `tests/` (비교·판정 로직 단위 테스트, PR에서 실행)
- 트리거: schedule(매일 1회), workflow_dispatch(입력 dry_run), policy·스크립트를 바꾼 main push
- 인증: Fine-grained PAT 비밀값 `GOVERNANCE_TOKEN` (대상 coralstay 모든 저장소, Administration read/write, Metadata read) — 유저가 직접 만들어 등록. 기본 GITHUB_TOKEN은 다른 저장소의 규칙을 바꿀 수 없다
- 동작: gh repo list coralstay → 저장소마다 판정 → 결과를 $GITHUB_STEP_SUMMARY 표로 출력

## 비즈니스 규칙
- B1 (AC #2) public이고 포크·보관(archived)이 아닌 저장소는 이름이 main-protect인 규칙이 기준 정의와 같아야 한다. 없으면 만들고, 다르면(enforcement·대상 브랜치·rules·bypass_actors) 기준으로 되돌린다
- B2 (AC #2) private 저장소는 무료 요금제에서 규칙을 걸 수 없으므로 건너뛰고 "private-skip"으로 보고한다(실패 아님)
- B3 (AC #2) 포크와 archived 저장소는 건너뛰고 보고한다
- B4 (AC #3) dry_run이면 어떤 쓰기 API도 호출하지 않고 판정 결과만 보고한다
- B5 (AC #2) main-protect 외의 다른 규칙(예: 옛 main-protection)은 건드리지 않고, 기준과 충돌하면 보고만 한다
- B6 (AC #4) API 오류가 하나라도 있으면 워크플로는 실패(exit 1)한다 — 조용히 보호가 빠지는 일을 막는다
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 policy/main-protect.json이 현재 공개 저장소에 걸린 main-protect 정의(기본 브랜치, deletion·non_fast_forward·required_signatures·pull_request(merge, 승인 0), bypass 없음)와 같다
- [ ] #2 판정 로직이 B1·B2·B3·B5에 따라 저장소마다 create·update·ok·private-skip·fork-skip·archived-skip 중 하나를 내고, 단위 테스트로 검증된다
- [ ] #3 dry_run 입력이면 쓰기 API를 호출하지 않고(B4) 같은 판정 표를 출력한다
- [ ] #4 워크플로가 schedule(매일)·workflow_dispatch로 돌고, 결과를 Step Summary 표로 남기며, API 오류가 있으면 실패한다(B6)
- [ ] #5 README에 동작·PAT(GOVERNANCE_TOKEN) 만드는 법·수동 실행 방법을 적는다
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 단위 테스트 전체 통과(로그를 Implementation Notes에 첨부)
- [ ] #2 유저가 GOVERNANCE_TOKEN을 등록한 뒤 dry_run 실행 결과와 실제 실행 결과(공개 저장소 6곳 ok)를 Implementation Notes에 첨부
- [ ] #3 변경이 PR로 coralstay/coralstay main에 병합됨
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
### Subjective
유저가 모든 저장소의 main 직접 병합을 잠그라고 했고, 수동 스크립트 대신 CI로 거는 방법 중 A(중앙 점검 워크플로)를 골랐다(2026-11-01).

### Objective
coralstay 저장소 18개(포크·보관 0), public 6개는 main-protect 적용됨, private 12개는 무료 요금제라 규칙 API가 403. 기존 dev-toolchain에는 꺼지고 대상이 빈 main-protection 규칙이 있었다(이번에 main-protect로 교체). 프로필 저장소도 main-protect가 걸려 있어 변경은 PR로만 들어간다.

### Assessment
GitHub Actions의 schedule + workflow_dispatch로 조정(reconcile) 루프를 만든다. 판정 로직(기준과 실제 규칙 비교)은 순수 함수로 두고 단위 테스트한다. 쓰기는 gh api로만 한다. 공개 전환은 자동화하지 않는다. PAT는 유저가 만들어 비밀값으로 등록한다.

### Plan
1. 판정 로직 테스트 먼저(B1~B5) → scripts/enforce_main_protect.py
2. workflow 파일(schedule·dispatch·dry_run·summary) + PR용 테스트 job
3. README 절(동작, PAT 만드는 법, 수동 실행)
4. PR로 coralstay/coralstay에 반영 → 유저가 GOVERNANCE_TOKEN 등록 → dry_run 수동 실행 → 실제 실행 실측
<!-- SECTION:PLAN:END -->
