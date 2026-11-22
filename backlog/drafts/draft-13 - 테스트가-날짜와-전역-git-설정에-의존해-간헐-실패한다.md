---
id: DRAFT-13
title: 테스트가 날짜와 전역 git 설정에 의존해 간헐 실패한다
status: Draft
assignee: []
created_date: '2026-11-05T20:05:00Z'
labels:
  - friction
  - tool:tests
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
증상: source-header 테스트가 고정 날짜 픽스처로 날짜가 바뀌자 실패, 전역 mailmap.file·commit.gpgsign(Secretive)을 물려받아 실패하거나 Touch ID 창이 뜸. agile-hooks·commit-tool 테스트도 같은 문제. 고칠 곳: source-header DRAFT-3(테스트 git 격리)
<!-- SECTION:DESCRIPTION:END -->
