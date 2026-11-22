---
id: DRAFT-2
title: 옮긴 저장소의 옛 주소가 보관본으로 자동 연결돼 gh repo view가 성공한다
status: Draft
assignee: []
created_date: '2026-11-05T20:05:00Z'
labels:
  - friction
  - tool:gh
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
증상: coralstay/<이름>을 coralstay-archive로 transfer한 뒤에도 `gh repo view coralstay/<이름>`이 성공(리다이렉트)해, reinit.sh가 '새 저장소가 이미 있음'으로 오판. 해결: nameWithOwner로 실제 소유자 비교(scripts/reinit.sh owned_here). 교훈: 존재 확인은 리다이렉트를 따라간 결과의 소유자까지 본다. 출처: TASK-4 Notes '진행 중 고친 스크립트 문제 (1)'
<!-- SECTION:DESCRIPTION:END -->
