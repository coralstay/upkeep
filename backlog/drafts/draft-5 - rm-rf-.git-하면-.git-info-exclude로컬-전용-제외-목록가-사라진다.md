---
id: DRAFT-5
title: rm -rf .git 하면 .git/info/exclude(로컬 전용 제외 목록)가 사라진다
status: Draft
assignee: []
created_date: '2026-11-05T20:05:00Z'
labels:
  - friction
  - tool:git
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
증상: 재초기화 뒤 dev-toolchain이 넣는 .opensource/, 개인 .todo/ 등이 추적 대상에 들어와 첫 커밋 파일 수가 미리보기와 달라짐(agile-hooks·commit-tool·toy-project). 해결: exclude를 새 .git으로 옮기고 완료 저장소에도 복원. 교훈: .git 안에도 작업 트리 상태를 바꾸는 로컬 설정(info/exclude, hooks, config)이 있다. 출처: TASK-4 Notes (4)
<!-- SECTION:DESCRIPTION:END -->
