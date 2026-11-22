---
id: DRAFT-1
title: ~/.claude/CLAUDE.md 를 claude-config/ 에 기록으로 남기고 지운다
status: Draft
assignee: []
created_date: '2026-11-22T10:27:00Z'
labels:
  - claude-config
  - record
dependencies: []
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
