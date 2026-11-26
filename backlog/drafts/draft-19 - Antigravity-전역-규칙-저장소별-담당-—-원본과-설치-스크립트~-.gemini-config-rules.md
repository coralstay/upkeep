---
id: DRAFT-19
title: 'Antigravity 전역 규칙: 저장소별 담당 — 원본과 설치 스크립트(~/.gemini/config/rules/)'
status: Draft
assignee: []
created_date: '2026-11-26T08:24:00Z'
labels:
  - agents
  - antigravity
dependencies: []
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
