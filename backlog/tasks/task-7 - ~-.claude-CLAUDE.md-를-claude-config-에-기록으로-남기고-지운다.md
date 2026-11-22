---
id: TASK-7
title: ~/.claude/CLAUDE.md 를 claude-config/ 에 기록으로 남기고 지운다
status: In Progress
assignee: []
created_date: '2026-11-22T10:27:00Z'
updated_date: '2026-11-22T11:06:00Z'
labels:
  - claude-config
  - record
dependencies: []
documentation:
  - /Users/flynn_macpro/.claude/plans/upkeep-claude-config-record.md
  - /Users/flynn_macpro/githubs-backup/2026-11-21-CLAUDE.md.bak
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
## 배경
유저(2026-11-21~22): '클로드 md 지워.' '기록은 남겨둬야 해. 적절한 디렉터리가 있을 거야.' 지운 뒤 원칙 적용 여부는 '기록만, 적용 안 함'.
- 워크플로 블록(1~39행)은 2026-11-21 에 이미 지웠고(백업 ~/githubs-backup/2026-11-21-CLAUDE.md.bak, 전체 원본) 그 역할은 claude-code-agile-hooks TASK-76(session_start 가 안내문 출력)이 대신한다.
- 남은 33줄은 유저가 쓴 두 원칙: 서브에이전트 사용 원칙(구현·수정은 기본적으로 서브에이전트에 위임, 독립 검증이 목적), 다이어그램 표기 원칙(DOT 우선, 대응물 없으면 mermaid, 원본은 diagrams/, 색은 센티넬 hex).
- 위치: upkeep 은 ~/githubs 작업 환경을 유지·관리하는 저장소이고 Claude Code 사용자 설정도 그 일부다(scripts/identity/ 와 같은 결).
계획: ~/.claude/plans/upkeep-claude-config-record.md (승인됨)

## 범위
- claude-config/README.md: 무엇을 왜 보관하나, 각 파일의 쓰임·지금은 적용되지 않음·다시 적용하는 법
- claude-config/CLAUDE.md-2026-11-21.md: 2026-11-21 시점 ~/.claude/CLAUDE.md 전문(백업 그대로, 헤더 주석만 추가)
- 기록 커밋 뒤 ~/.claude/CLAUDE.md 삭제(직전 내용과 기록 대조)
- upkeep README 구성 목록에 claude-config/ 한 줄
- upkeep 은 PUBLIC: gitleaks·개인 경로 검사, /Users/<이름> 은 ~ 로(예외는 README 에 명시)

## 비즈니스 규칙
- B1 (AC #1) 기록은 원문과 같다(헤더 주석과 경로 치환 예외만). 정보를 버리지 않는다
- B2 (AC #2) ~/.claude/CLAUDE.md 는 기록이 커밋된 뒤에만 지운다
- B3 (AC #1) README 에 '지금은 적용되지 않음'과 다시 적용하는 법을 적는다

## 하지 않는 것
원칙 내용 수정, 원칙을 다른 곳으로 옮겨 계속 적용
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 claude-config/README.md 와 claude-config/CLAUDE.md-2026-11-21.md 가 있고, 기록 본문이 백업 원본(~/githubs-backup/2026-11-21-CLAUDE.md.bak)과 같다(diff 로 증명, 헤더 주석·경로 치환 예외는 README 에 명시). README 에 '지금은 적용되지 않음'과 다시 적용하는 법이 있다(B1·B3)
- [ ] #2 [수동 검증] 기록 커밋 뒤 ~/.claude/CLAUDE.md 를 지웠고, 지우기 직전 내용과 기록의 원칙 부분이 같음을 대조했다(B2)
- [ ] #3 upkeep README 구성 목록에 claude-config/ 가 있고 source-header lint --strict 0, gitleaks 0 이다
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 기록과 백업 원본의 diff 출력을 Notes 에 첨부
- [ ] #2 삭제 직전 대조와 삭제 확인(ls) 출력을 Notes 에 첨부
- [ ] #3 PR 이 있다
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
### Subjective
유저(2026-11-21~22)가 ~/.claude/CLAUDE.md 를 지우되 기록은 적절한 디렉터리에 남기라고 했다. 지운 뒤 원칙은 적용하지 않는다(기록만).

### Objective
- ~/.claude/CLAUDE.md 는 2026-11-21 워크플로 블록을 지운 뒤 33줄(서브에이전트·다이어그램 원칙)이다. 전체 원본 백업은 ~/githubs-backup/2026-11-21-CLAUDE.md.bak.
- upkeep 은 ~/githubs 작업 환경 운영 저장소(README), 구성: backlog/·scripts/(identity/ 포함)·runbooks/·local/. 2026-11-12 부터 PUBLIC.
- 워크플로 블록 역할은 claude-code-agile-hooks TASK-76 이 대신한다.

### Assessment
upkeep 에 claude-config/ 를 만들어 원본 전문을 바이트 그대로(헤더 주석만 추가) 보관하고, README 로 상태·재적용 방법을 남긴 뒤 원본을 지운다. 지우는 것은 되돌리기 어려우므로 기록 커밋 뒤에만, 직전 대조 후에 한다.

### Plan
1. 백업 원본에서 개인 경로·비밀값 검사(gitleaks, /Users/ grep).
2. claude-config/CLAUDE.md-2026-11-21.md(헤더 주석 + 원문), claude-config/README.md, upkeep README 한 줄.
3. diff 로 원문 동일 확인, lint·gitleaks, 커밋.
4. ~/.claude/CLAUDE.md 직전 대조 → 삭제 → 확인, Notes, Done, PR.
<!-- SECTION:PLAN:END -->
