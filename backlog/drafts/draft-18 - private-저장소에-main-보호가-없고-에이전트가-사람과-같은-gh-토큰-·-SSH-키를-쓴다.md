---
id: DRAFT-18
title: private 저장소에 main 보호가 없고, 에이전트가 사람과 같은 gh 토큰 · SSH 키를 쓴다
status: Draft
assignee: []
created_date: '2026-11-05T22:12:00Z'
labels:
  - friction
  - tool:github
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
증상: 2026-11-06 PR 병합을 에이전트가 'gh pr merge'로 하려다 pre_git_safety_check에 막혔다(의도대로). 점검 결과 훅은 명령 문자열 판정이라 gh api의 다른 경로(merges · git/refs · contents PUT · 자동 병합 GraphQL), curl + gh auth token, 스크립트 · bash -c 안의 호출, SSH 키 git push 변형을 다 막지 못한다.
원인: 새 저장소 17개 + upkeep이 모두 private이라 GitHub Free에서 main-protect ruleset이 걸리지 않는다(public만 지원). 에이전트(Claude · Antigravity)가 사람과 같은 gh 토큰과 같은 SSH 인증 키(Secretive github-auth)를 써서, 서버 쪽에서 에이전트 쓰기를 구별 · 제한할 수 없다.
종류: 규칙이 새는 곳(gap).
고칠 곳: (1) 훅 규칙 확장 — agile-hooks draft 'gh api · GraphQL로 main에 직접 쓰는 경로' (2) 근본 — TASK-5(보안 기준선)에서 결정: 공개 시점(TASK-6) · GitHub Pro로 private ruleset · 에이전트 전용 fine-grained PAT와 별도 SSH 인증 경로
참고: PR 병합은 지금 유저가 직접 한다(의도된 마찰). 에이전트 병합을 'CI 통과 + 사람 승인' 조건에서 허용할지도 같은 결정에서 다룬다.
<!-- SECTION:DESCRIPTION:END -->
