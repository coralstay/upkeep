---
id: DRAFT-17
title: Secretive 에이전트의 쇼트 리드로 서명이 'communication with agent failed'로 실패한다
status: Draft
assignee: []
created_date: '2026-11-05T21:33:00Z'
labels:
  - friction
  - tool:secretive
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
증상: 병렬 테스트처럼 부하가 높을 때 git 서명이 간헐 실패(ssh-keygen 'Couldn't sign message (signer): communication with agent failed', git commit exit 128). 2026-11-06 agile-hooks 커밋 전 테스트에서 매번 1~3개 실패로 드러남.
원인(확인): Secretive 4.0.0이 SSH 에이전트 메시지를 길이 접두사만큼 모으지 않고 한 번 읽은 덩어리를 메시지로 처리한다. OpenSSH는 길이와 본문을 두 번에 나눠 쓴다. 쇼트 리드 결함이며 부하·지연은 드러나는 조건이다.
증거: runbooks/secretive-short-read/(README, 재현 스크립트). 대조 실험 Secretive 0/5 vs OpenSSH ssh-agent 5/5, 에이전트 디버그 로그 실패 4건 = 'Session closed' 4건.
영향: 테스트만이 아니라 부하가 높을 때 실제 커밋 서명(사람 · AI 키)도 실패할 수 있다.
대응: 테스트 쪽은 agile-hooks TASK-74(테스트 git 격리)로 서명 요청 자체를 없앤다. upstream #577에는 올리지 않기로 함(유저 결정, AI 코드 금지 정책). 실제 커밋 실패 시 재시도 장치는 미정.
<!-- SECTION:DESCRIPTION:END -->
