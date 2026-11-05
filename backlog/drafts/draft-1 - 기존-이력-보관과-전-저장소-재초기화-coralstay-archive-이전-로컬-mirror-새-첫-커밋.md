---
id: DRAFT-1
title: '기존 이력 보관과 전 저장소 재초기화: coralstay-archive 이전 + 로컬 mirror + 새 첫 커밋'
status: Draft
assignee: []
created_date: '2026-11-05T20:02:00Z'
labels:
  - archive
  - reinit
dependencies: []
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
