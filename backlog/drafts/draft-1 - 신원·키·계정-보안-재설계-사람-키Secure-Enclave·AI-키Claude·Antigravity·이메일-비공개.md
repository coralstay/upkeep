---
id: DRAFT-1
title: '신원·키·계정 보안 재설계: 사람 키(Secure Enclave)·AI 키(Claude·Antigravity)·이메일 비공개'
status: Draft
assignee: []
created_date: '2026-11-05T20:02:00Z'
updated_date: '2026-11-05T20:02:00Z'
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

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 [수동 검증] GitHub 계정: gmail 인증·primary(비공개), "Keep my email addresses private"·"Block command line pushes that expose my email" 켜 둠, 2FA(passkey+TOTP), 불필요한 앱·토큰·키 폐기, vigilant mode 켜짐
- [ ] #2 [수동 검증] 새 신원으로 GitHub 인증이 된다(ssh -T 성공, 사람 인증 키는 Secure Enclave)
- [ ] #3 [수동 검증] 사람 서명 키가 Secure Enclave에 있고 서명마다 Touch ID를 요구하며(B1) GitHub 서명 키로 등록돼 커밋이 Verified로 보인다
- [ ] #4 [수동 검증] Claude Code와 Antigravity가 각자 다른 AI 서명 키로 서명하고(B2) GitHub에서 Verified, git log --show-signature에서 principal이 구별된다
- [ ] #5 [수동 검증] AI 서명으로 만든 Plan-Approved 커밋은 훅이 거부한다(B3)
- [ ] #6 [수동 검증] git 전역 user.email·~/.mailmap이 coralstay <231006716+coralstay@users.noreply.github.com> 기준이고(B4), 옛 github_signature 키는 GitHub·로컬에서 폐기됐다
- [ ] #7 [수동 검증] AI 서명 키(Claude·Antigravity)를 Secretive Secure Enclave 키(Touch ID 없음)로 옮겨 키 파일을 복사·유출할 수 없게 하고, 옛 파일 키는 GitHub·로컬에서 폐기한다
- [ ] #8 [수동 검증] allowed_signers에 키마다 valid-after·valid-before가 있고, 교체 주기(사람 1년·AI 6개월)와 교체 절차가 키 목록 문서에 있다
- [ ] #9 [수동 검증] 키 목록 문서(이름·용도·지문·위치·만든 날·만료일)와 사람 키 분실 시 복구 절차가 있다(예비 하드웨어 키는 장비가 생기면 추가)
- [ ] #10 [수동 검증] VM 접속 키(rocky-dev)에 암호가 걸리고 macOS 키체인으로 열리며, gh 토큰에서 delete_repo·admin:org를 TASK-20 뒤 제거하는 일정이 문서에 있다
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 [수동 검증] 검증 커밋 3종의 git log --show-signature 출력과 GitHub Verified 확인을 Notes에 첨부
- [ ] #2 [수동 검증] 변경한 로컬 설정 파일 목록과 되돌리는 방법을 Notes에 기록
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
### Subjective
유저가 새 신원(coralstay, 커밋 이메일은 GitHub noreply, gmail은 비공개)으로 새 출발하며 GitHub 보안·인증을 새로 구성하길 원하고, 사람 키는 Secure Enclave+Touch ID로 정했다. Claude와 Antigravity 두 에이전트가 있다.

### Objective
키는 github_signature 하나(인증+서명, 설명에 옛 계정명). allowed_signers는 human 하나. gh 토큰에 user 범위 없음. git 전역 email은 noreply.

### Assessment
GitHub 웹 설정·Touch ID·settings.json 수정은 유저만 할 수 있으므로, 나는 키 생성 명령·설정 파일 초안·검증 절차를 준비하고 유저가 실행한다. 사람 키와 AI 키를 분리해야 Plan-Approved 게이트가 의미를 가진다.

### Plan
1. 유저 웹: 이메일 인증·primary·비공개 해제, 2FA(passkey+TOTP), 앱·토큰·키 점검, vigilant mode
2. Secretive 설치·사람 인증/서명 키 생성(유저) → GitHub 등록
3. AI 키 두 개 생성(나) → GitHub 서명 키 등록(유저)
4. allowed_signers·git 전역·~/.mailmap·ssh config 갱신
5. Claude settings env, Antigravity 실행 환경에 각자 서명 키 지정(유저)
6. 검증 커밋 3종(사람·Claude·Antigravity) → 옛 키 폐기
<!-- SECTION:PLAN:END -->
