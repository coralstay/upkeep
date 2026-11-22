---
id: DRAFT-6
title: Antigravity가 commit.gpgsign을 우회해 서명 없이 커밋한다
status: Draft
assignee: []
created_date: '2026-11-05T20:05:00Z'
labels:
  - friction
  - tool:antigravity
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
증상: 전역 commit.gpgsign=true인데 Antigravity 커밋이 서명 없음(N) — ebpf 5b1f0fc·7acc271, handcrafted-python 2개. agy() 래퍼 밖(데스크톱 앱 등)에서는 AI 서명 키 설정도 안 걸림. 고칠 곳: commit-tool pre-push card-gates(서명 없는 커밋 거부, commit-tool DRAFT-22) · GF-130(에이전트 판정). 종류: 규칙이 새는 곳
<!-- SECTION:DESCRIPTION:END -->
