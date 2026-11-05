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
references:
  - source-header TASK-20(이관 원본)
documentation:
  - ~/.claude/plans/giggly-kindling-snowglobe.md
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
- [x] #1 [수동 검증] 18개 저장소의 로컬 mirror가 ~/githubs-archive/2026-11-01/에 있고 git fsck가 통과한다
- [x] #2 [수동 검증] 18개 저장소가 coralstay-archive 조직에 Private·Archived로 보관되고 PR·이슈 수가 이전 전과 같다(B1)
- [x] #3 [수동 검증] 저장소마다 새 첫 커밋 전 추적 대상 민감 패턴·제3자 경로가 0이다(B2)
- [x] #4 [수동 검증] 18개 저장소가 coralstay 계정에 Private으로 새로 만들어지고(B3) 커밋 1개, 작성자 coralstay <231006716+coralstay@users.noreply.github.com>, 사람 서명 Verified다
- [x] #5 [수동 검증] 로컬 무시 파일(책 원본·데이터 등)이 그대로 남아 있다
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

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## 유저 결정 (2026-11-05)
- 2단계(GitHub 보관): coralstay-archive로 transfer 후 Archived만 건다. 공개 여부는 바꾸지 않는다(지금 Public 6곳은 Public 그대로, Private 12곳은 Private 그대로). 옛 이력 공개는 유저가 수용
- 옛 doctree(보관본)는 공개하지 않는다(실제 Drive file_id 234개·해시가 이력에 있음). ebpf·central-docs·source-header 보관본도 Private 유지
- 새 doctree에는 책 제목 목록(docs/LIBRARY.md, map 제목 그대로·가나다순, ID·해시·경로·메모 없음)을 첫 커밋에 넣는다
- 새 저장소 18개는 Private으로 만들고 공개는 TASK-22

## 결정 변경 (2026-11-06, 유저)
- 보관본(coralstay-archive) 18곳을 모두 이력 그대로 공개한다(앞의 '옛 doctree는 공개하지 않는다'를 대체). 공개되는 옛 이력: doctree Drive file_id 234개·PDF 해시·서재 메모, ebpf VM UUID·IP·MAC·SSH 별칭·로컬 경로·Antigravity 세션 ID, central-docs·source-header 실명·옛 이메일·계정 연결 문장, 전체 옛 계정명 — 유저가 감수
- 순서: 이 카드 2단계는 transfer+Archived만(공개 여부 그대로) → doctree 보관본 공개 전 Drive 링크 공유 전수 점검·해제 → 보관본 공개는 TASK-22에서

## 1단계 로컬 보관 (2026-11-06)
- 증거: TASK-4#1 — ~/githubs-archive/2026-11-01/<경로를 _로 바꾼 이름>.git 18개(33MB, git clone --mirror). 참조 수 원본과 일치(dev-toolchain 104, doctree 17, source-header 9 …), 전체 git fsck --no-dangling 문제 0/18
- 참고: agent-orchestrator·agile-hooks 원본의 commit-graph가 객체 없는 커밋 4개(e0b272f, 29082b8, bb0dbca, f026a19 — 어떤 ref에서도 닿지 않음)를 가리키는 상태였음. mirror는 commit-graph write --reachable로 다시 만들어 해소
- 발견: agile-hooks 테스트가 전역 git 서명 설정을 물려받아 병렬 실행 시 간헐 실패 → source-header DRAFT-3

결정 변경(2026-11-06, 유저): 새 doctree에 docs/LIBRARY.md를 넣지 않는다. 서재 목록은 기존 명령 'doctree classify'(로컬 map·스냅샷 기준)로 본다. 새 저장소에 공개되는 서재 정보는 config/category_tree.yaml(분야 목록)뿐. 필요해지면 'doctree classify > docs/LIBRARY.md'로 만든다(출력에 Drive ID·해시 0건 확인함).

## 2단계 GitHub 보관 (2026-11-06, 유저 실행 archive-transfer.sh)
- 증거: TASK-4#2 — 18개 저장소 coralstay → coralstay-archive transfer + Archived, 실패 0. 옮기기 전후 공개 상태·PR·이슈·릴리스 수 모두 같음(agent-orchestrator 22 PR, agile-hooks 62, commit-tool 53, factory 18, toy 17, doctree 7, dev-toolchain 6 PR·15 이슈, devOps 3). coralstay 계정 저장소 0, coralstay-archive 18/18 Archived. 기준 파일: ~/githubs-backup/2026-11-01/archive-baseline.tsv

## 3단계 새 이력 미리보기 (2026-11-06, reinit-preview.sh)
- 증거: TASK-4#3 — 18개 저장소의 첫 커밋 대상 파일 목록(~/githubs-backup/2026-11-01/reinit-preview/*.files)과 검사: 민감 패턴(옛 계정명·옛 이메일·실명·로컬 경로·VM IP/UUID/MAC·gmail) 17곳 0건(source-header TASK-19 카드 이메일 문자열 2건은 0fbbeb5·1abddb6에서 제거), gitleaks는 toy-project 9·dev-toolchain 2건 모두 기존 확인 오탐, 1MB 초과 0(ebpf 제외), 제3자 흔적 경로 0, doctree 실제 Drive ID 0
- ebpf-wire-to-code-tracer는 제외: Antigravity가 작업 중(11-04 커밋 5b1f0fc·7acc271은 서명 없음 N, 이미 보관본에 들어감 / 11-05~06 미커밋 23개, 새 파일에 file:///Users 경로 18파일·VM IP 재등장). 작업이 끝난 뒤 정리·재초기화
- 발견: Antigravity가 서명 없이 커밋함(전역 commit.gpgsign=true를 우회) → agy() 밖(데스크톱 앱 등)의 서명 강제가 필요. 서명 없는 커밋은 공개 저장소 main-protect(서명 필수)에서 막히고, 로컬에서는 .githooks 검사 플러그인이 필요
- 나머지 11곳의 미커밋 변경은 모두 TASK-18 정리분(11-01~02) → 첫 커밋에 포함
- 4단계 스크립트: ~/githubs-backup/2026-11-01/reinit.sh (보관 확인 → .git 삭제 → init → 파일 수·패턴 재확인 → 사람 서명 첫 커밋(G/human 확인) → coralstay/<이름> Private 생성·push·메타데이터 복원), Claude/agy 환경에서는 실행 거부

## 4·5단계 재초기화와 확인 (2026-11-06, 유저 실행 reinit.sh)
- 증거: TASK-4#4 — 17개 저장소(ebpf 제외) coralstay/<이름> Private 새로 생성, GitHub 커밋 1개·verified=true/valid·작성자 noreply(gh api로 17곳 확인). 로컬: 커밋 1개, 옛 신원(커밋 작성자·커미터) 0, 서명 G/human, main=origin/main, 미커밋 0
- 증거: TASK-4#5 — 로컬 .gitignore 대상(책 원본·Drive map·OCR 등)은 디스크에 그대로 남음, 첫 커밋 파일 수 = 3단계 미리보기
- 진행 중 고친 스크립트 문제: (1) 옮긴 저장소의 옛 주소가 보관본으로 자동 연결돼 '이미 있음'으로 오판 → 실제 소유자 비교 (2) $cnt 뒤 한글이 변수 이름으로 읽혀 unbound variable → ${cnt} (3) push 실패를 '끝남'으로 오판 → 원격 main 비교, 생성과 push 분리(이어서 하기) (4) .git/info/exclude(.opensource/, .todo/ 등 로컬 전용 제외)가 사라져 파일 수 불일치 → 새 .git으로 옮기도록 수정, 완료 저장소에도 복원
- 제외: ebpf-wire-to-code-tracer(Antigravity 작업 중). 새로 발견: freeride/handcrafted-python(Antigravity가 11-06 02:46 coralstay/handcrafted-python Private 생성, 서명 없는 커밋 2개) — 같은 검토(저작권·라이선스·서명) 필요
- 옛 이력: coralstay-archive(18 Archived) + ~/githubs-archive/2026-11-01(mirror 18)
- 이전 카드 이력의 커밋 해시는 새 이력에 없음(보관본에서 확인)

범위 정리(2026-11-06): AC #4의 18개 중 ebpf-wire-to-code-tracer는 Antigravity 작업 중이라 재초기화를 별도 draft(ebpf·handcrafted-python)로 넘김. 보관(AC #1·#2)은 18개 모두 완료.
- 증거: TASK-4#D1 — '3단계 새 이력 미리보기' 절(~/githubs-backup/2026-11-01/reinit-preview/*.files·*.findings, gitleaks 결과)
- 증거: TASK-4#D2 — '2단계 GitHub 보관'·'4·5단계' 절(`gh repo list coralstay-archive` 18 Archived, `gh api repos/coralstay/<n>/commits` 17곳 1개·Private)
<!-- SECTION:NOTES:END -->
