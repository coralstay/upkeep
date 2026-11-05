---
id: DRAFT-1
title: '신원·키·계정 보안 재설계: 사람 키(Secure Enclave)·AI 키(Claude·Antigravity)·이메일 비공개'
status: Draft
assignee: []
created_date: '2026-11-05T20:02:00Z'
labels:
  - identity
  - security
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
이관(2026-11-06): source-header TASK-19에서 옮겼다. 원래 카드는 source-header backlog/archive에 있고, 옛 커밋 해시는 coralstay-archive 보관본에서 확인한다. 이 저장소의 새 ID는 TASK-3.

## 배경
유저 최종 목표(2026-11-01) 0단계. 계획: ~/.claude/plans/giggly-kindling-snowglobe.md
현재 SSH 키 하나(~/.ssh/github_signature, 설명에 옛 계정 noreply)가 GitHub 인증과 커밋 서명(allowed_signers human)을 모두 맡아, Claude·Antigravity 커밋도 사람 서명으로 찍힌다. 새 이력을 시작하기 전에 신원과 키를 나눈다.

## 비즈니스 규칙
- B1 (AC #3) [수동 검증] 사람 서명 키는 Secure Enclave 안에 있고 서명마다 Touch ID를 요구한다 — 에이전트가 사람 서명을 만들 수 없다
- B2 (AC #4) [수동 검증] AI 서명 키는 에이전트마다 하나(ai-claude-code, ai-antigravity)이고 allowed_signers principal로 구별된다
- B3 (AC #5) [수동 검증] humanSigners는 ["human"]뿐이라 AI 서명 Plan-Approved 커밋은 훅이 거부한다
- B4 (AC #1) [수동 검증] 새 커밋 작성자·커미터는 coralstay <231006716+coralstay@users.noreply.github.com>이다. 계정 이메일(gmail)은 비공개로 두고 저장소 파일·커밋 어디에도 쓰지 않는다(2026-11-02 유저 결정)
<!-- SECTION:DESCRIPTION:END -->
