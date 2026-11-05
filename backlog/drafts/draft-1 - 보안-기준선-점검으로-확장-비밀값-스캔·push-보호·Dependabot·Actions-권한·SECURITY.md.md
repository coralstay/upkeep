---
id: DRAFT-1
title: '보안 기준선 점검으로 확장: 비밀값 스캔·push 보호·Dependabot·Actions 권한·SECURITY.md'
status: Draft
assignee: []
created_date: '2026-11-05T20:03:00Z'
labels:
  - security
  - governance
  - ci
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
이관(2026-11-06): source-header TASK-21에서 옮겼다. 원래 카드는 source-header backlog/archive에 있고, 옛 커밋 해시는 coralstay-archive 보관본에서 확인한다. 이 저장소의 새 ID는 TASK-5.

## 배경
유저 최종 목표 4단계. TASK-17(main-protect 중앙 점검 워크플로)을 확장해 저장소 보안 기준선 전체를 매일 점검·적용한다. 계획: ~/.claude/plans/giggly-kindling-snowglobe.md
항목: 비밀값 스캔 + push 보호, Dependabot 알림·보안 업데이트, private 취약점 신고, CodeQL 기본 설정(public), Actions 기본 토큰 읽기 전용·PR 생성 금지·허용 액션 제한, SECURITY.md·LICENSE·dependabot.yml 존재 보고, 로컬 .githooks에 gitleaks 플러그인.
TASK-17에 의존한다.
<!-- SECTION:DESCRIPTION:END -->
