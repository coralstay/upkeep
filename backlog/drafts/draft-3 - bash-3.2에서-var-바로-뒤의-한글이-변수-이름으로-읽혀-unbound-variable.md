---
id: DRAFT-3
title: bash 3.2에서 $var 바로 뒤의 한글이 변수 이름으로 읽혀 unbound variable
status: Draft
assignee: []
created_date: '2026-11-05T20:05:00Z'
labels:
  - friction
  - tool:bash
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
증상: `set -u` 스크립트에서 `$cnt개`가 unbound variable로 멈춤(macOS /bin/sh = bash 3.2가 멀티바이트를 변수 이름 문자로 읽음). 해결: `${cnt}`처럼 중괄호. 교훈: 셸 스크립트의 변수 뒤에 한글이 붙으면 항상 중괄호. 출처: TASK-4 Notes (2)
<!-- SECTION:DESCRIPTION:END -->
