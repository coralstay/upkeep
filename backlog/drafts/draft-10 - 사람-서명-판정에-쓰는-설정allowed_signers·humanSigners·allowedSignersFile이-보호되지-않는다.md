---
id: DRAFT-10
title: 사람 서명 판정에 쓰는 설정(allowed_signers·humanSigners·allowedSignersFile)이 보호되지 않는다
status: Draft
assignee: []
created_date: '2026-11-05T20:05:00Z'
labels:
  - friction
  - tool:agile-hooks
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
증상: ~/.ssh/allowed_signers, 저장소 .claude-code-agile-hooks.json의 humanSigners, .git/config의 gpg.ssh.allowedSignersFile을 에이전트가 고칠 수 있어 Plan-Approved 사람 서명 판정을 속일 수 있음(config_guard 대상 아님). 종류: 규칙이 새는 곳. 고칠 곳: agile-hooks DRAFT-10(사람 키 지문 고정)
<!-- SECTION:DESCRIPTION:END -->
