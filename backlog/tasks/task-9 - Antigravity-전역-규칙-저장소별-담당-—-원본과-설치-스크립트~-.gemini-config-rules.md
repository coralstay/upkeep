---
id: TASK-9
title: 'Antigravity 전역 규칙: 저장소별 담당 — 원본과 설치 스크립트(~/.gemini/config/rules/)'
status: In Progress
assignee: []
created_date: '2026-11-26T08:24:00Z'
updated_date: '2026-11-26T09:14:00Z'
labels:
  - agents
  - antigravity
dependencies: []
documentation:
  - >-
    /Users/flynn_macpro/githubs/dev-tools/dev-toolchain/backlog/decisions/decision-25
    - 저장소를-에이전트별로-나눠-갖는다-담당은-workspace-repos.tsv-담당-열이-SSOT.md
  - https://antigravity.google/docs/rules
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
## 배경
유저 결정(2026-11-22): 저장소를 에이전트별로 나눠 갖는다. Antigravity 는 자기 담당 저장소에서 자유롭게 일하고, 남의 담당 저장소는 건드리지 않는다. 담당 SSOT 는 dev-toolchain workspace/repos.tsv 담당 열, 조회는 dev-toolchain workspace owner <경로>(TASK-179, PR #6 병합). Claude 쪽 안내문은 agile-hooks 카드로 따로 한다.
계획: ~/.claude/plans/agent-repo-split-record.md (승인됨, 3번 항목)

## 확인한 사실(2026-11-26)
- Antigravity 전역 규칙 위치(공식 문서 antigravity.google/docs/rules): 독립 파일 ~/.gemini/GEMINI.md · AGENTS.md(프론트매터 불필요, 항상 적용) 또는 모듈 규칙 ~/.gemini/config/rules/*.md(YAML 프론트매터 필수: trigger = always_on | model_decision | glob | manual, description 권장). 규칙은 누적, 파일당 24KB·활성 전역 규칙 합 20,000 토큰 예산
- 이 머신에는 전역 규칙 파일이 하나도 없다(~/.gemini/config/rules 폴더도 없음)

## 범위
- upkeep/agents/antigravity-repo-ownership.md: 원본(SSOT). trigger: always_on, 담당 규칙·자기 키(ai-antigravity) 서명·담당 확인 명령·자기 저장소는 자유·Claude 담당 저장소는 읽기만
- upkeep/scripts/install-antigravity-rules.sh: ~/.gemini/config/rules/coralstay-repo-ownership.md 로 복사(유저가 실행). 같으면 할 일 없음, 다르면 덮지 않고 diff 를 보여 주며 종료(--force 로만 교체)
- tests/test_install_antigravity_rules(테스트 먼저, 가짜 HOME)

## 비즈니스 규칙
- B1 (AC #1) 원본은 담당 표를 복사하지 않고 workspace owner 명령을 가리킨다
- B2 (AC #2) 설치 스크립트는 사용자의 기존 규칙 파일을 묻지 않고 덮지 않는다
- B3 (AC #2) 다른 전역 규칙 파일(GEMINI.md·AGENTS.md)은 건드리지 않는다

## 하지 않는 것
Antigravity 쪽 강제 장치, 저장소별 AGENTS.md 수정(Antigravity 담당 저장소라)
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 agents/antigravity-repo-ownership.md 가 trigger: always_on 프론트매터와 담당 규칙(workspace owner 로 확인, antigravity 가 아니면 편집·커밋하지 않고 읽기·보고만, unknown 이면 유저에게 묻기, 자기 키 ai-antigravity 서명)을 담고 담당 표를 복사하지 않는다(B1)
- [ ] #2 scripts/install-antigravity-rules.sh 가 ~/.gemini/config/rules/coralstay-repo-ownership.md 를 만든다. 같으면 할 일 없음, 다르면 덮지 않고 diff 를 보여 주며 1로 끝나고 --force 로만 교체한다. 다른 전역 규칙 파일은 건드리지 않는다(B2·B3)
- [ ] #3 tests 가 가짜 HOME 에서 새로 설치·같음·다름·--force·다른 파일 불변을 검사하고 <ID>#n·#Bk 표식이 있다
- [ ] #4 README 구성 목록에 agents/ 원본과 install-antigravity-rules.sh(유저가 실행, 덮지 않음)가 있다
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 pytest·shellcheck 출력을 Notes 에 첨부
- [ ] #2 [수동 검증] 유저가 설치 스크립트를 실행하고 Antigravity 새 세션에서 규칙을 받는지 확인
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
### Subjective
유저(2026-11-22)가 저장소를 에이전트별로 나눠 갖기로 했고 Antigravity 안내문에도 '남의 담당 저장소는 건드리지 않는다'를 넣기로 했다. 계획: ~/.claude/plans/agent-repo-split-record.md

### Objective
- 공식 문서: 전역 모듈 규칙은 ~/.gemini/config/rules/*.md(YAML trigger 필수), 독립 파일은 ~/.gemini/GEMINI.md 등. 규칙은 누적. 이 머신에는 전역 규칙이 없다.
- upkeep README: 외부 상태를 바꾸는 스크립트는 유저가 실행, scripts/ 변경은 테스트 먼저(testFirst sourceGlobs scripts/**).
- 담당 SSOT: dev-toolchain workspace/repos.tsv, 조회: dev-toolchain workspace owner <경로>.

### Assessment
사용자 파일을 덮지 않도록 독립 모듈 규칙 파일 하나만 설치한다. 원본은 upkeep 에 두고, 스크립트는 같음·다름·--force 만 다룬다.

### Plan
1. 테스트 먼저(가짜 HOME) — 실패 확인.
2. agents/antigravity-repo-ownership.md, scripts/install-antigravity-rules.sh(헤더·표식·노트), README 구성 목록.
3. pytest·shellcheck, 유저 실행 → Antigravity 새 세션 확인 → Done·PR.
<!-- SECTION:PLAN:END -->
