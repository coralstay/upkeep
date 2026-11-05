---
id: TASK-6
title: '저장소별 공개 전환: 재검사·기준선 확인 후 하나씩'
status: To Do
assignee: []
created_date: '2026-11-05T20:04:00Z'
updated_date: '2026-11-05T20:04:00Z'
labels:
  - public
dependencies: []
references:
  - source-header TASK-22(이관 원본)
documentation:
  - ~/.claude/plans/giggly-kindling-snowglobe.md
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
이관(2026-11-06): source-header TASK-22에서 옮겼다. 원래 카드는 source-header backlog/archive에 있고, 옛 커밋 해시는 coralstay-archive 보관본에서 확인한다. 이 저장소의 새 ID는 TASK-6.

## 배경
유저 최종 목표 5단계. 재초기화된 저장소를 gitleaks·민감 패턴 재검사와 보안 기준선 확인을 통과한 것부터 하나씩 유저가 공개하고, 중앙 워크플로가 즉시 main-protect를 건다. 계획: ~/.claude/plans/giggly-kindling-snowglobe.md
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 저장소마다 공개 전 체크리스트(gitleaks no leaks, 민감 패턴 0, 기준선 ok)를 통과한다
- [ ] #2 공개 직후 main-protect와 비밀값 push 보호가 적용된 것을 확인한다
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 저장소별 체크리스트 결과를 Notes에 첨부
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
### Subjective
유저가 보안 기준 적용 후 저장소별로 공개하기로 정했다.

### Objective
공개 시 무료 요금제에서도 규칙을 걸 수 있다. 중앙 워크플로가 수동 실행으로 즉시 적용한다.

### Assessment
저장소마다 체크리스트(gitleaks·민감 패턴·기준선)를 통과한 것만 유저가 공개한다.

### Plan
1. 저장소별 체크리스트 실행
2. 유저 공개
3. 워크플로 수동 실행으로 규칙 적용 확인
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## 범위 추가 (2026-11-06, 유저 결정)
보관본(coralstay-archive) 18곳도 공개한다. 선행 조건: doctree 보관본 공개 전 Drive 파일 234개의 링크 공유('anyone with link')가 0인지 확인하고, 켜진 파일은 '제한됨'으로 바꾼다. 앞으로 이 파일들의 링크 공유는 켜지 않는다.

## 보관본 저작권 확인 (2026-11-06) — 유저 기준: 저작권 문제만 없으면 모두 공개
- doctree: 실제 Drive file_id 234개 → 링크 공유가 켜진 파일이 있으면 책 PDF 배포가 됨. 공개 전 공유 전수 점검·해제 필수
- claude-code-agile-hooks: session_logger 프롬프트 로깅이 라이선스 없는 disler/claude-code-hooks-mastery 참고 코드였음(3324074~6060d3a). TASK-52에서 자체 구현으로 재작성, HEAD에는 없음. 몇 줄짜리 기능 코드이고 이미 공개돼 있었음 → 공개 가능으로 판단
- coding-agent-git-commit-tool: Pro Git(CC BY-NC-SA 3.0)·Google Shell Style Guide(CC BY 3.0) vendoring 이력(025eae4·d77c473 → 30d1056 제거). 출처 표시 조건으로 재배포 허용 → 공개 가능
- handcrafted-cpp 등 5곳: 책 원문 이력은 TASK-16에서 GitHub에서 이미 제거(로컬 백업에만). devOps 책 PDF는 push된 적 없음. dev-toolchain CC BY 출처 표시 있음. ebpf 커널 코드 GPL-2.0 선언 → 문제 없음
<!-- SECTION:NOTES:END -->
