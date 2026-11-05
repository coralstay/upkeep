---
id: TASK-3
title: '신원·키·계정 보안 재설계: 사람 키(Secure Enclave)·AI 키(Claude·Antigravity)·이메일 비공개'
status: To Do
assignee: []
created_date: '2026-11-05T20:02:00Z'
updated_date: '2026-11-05T20:02:00Z'
labels:
  - identity
  - security
dependencies: []
references:
  - source-header TASK-19(이관 원본)
documentation:
  - ~/.claude/plans/giggly-kindling-snowglobe.md
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
- [x] #1 [수동 검증] GitHub 계정: gmail 인증·primary(비공개), "Keep my email addresses private"·"Block command line pushes that expose my email" 켜 둠, 2FA(passkey+TOTP), 불필요한 앱·토큰·키 폐기, vigilant mode 켜짐
- [x] #2 [수동 검증] 새 신원으로 GitHub 인증이 된다(ssh -T 성공, 사람 인증 키는 Secure Enclave)
- [x] #3 [수동 검증] 사람 서명 키가 Secure Enclave에 있고 서명마다 Touch ID를 요구하며(B1) GitHub 서명 키로 등록돼 커밋이 Verified로 보인다
- [ ] #4 [수동 검증] Claude Code와 Antigravity가 각자 다른 AI 서명 키로 서명하고(B2) GitHub에서 Verified, git log --show-signature에서 principal이 구별된다
- [x] #5 [수동 검증] AI 서명으로 만든 Plan-Approved 커밋은 훅이 거부한다(B3)
- [x] #6 [수동 검증] git 전역 user.email·~/.mailmap이 coralstay <231006716+coralstay@users.noreply.github.com> 기준이고(B4), 옛 github_signature 키는 GitHub·로컬에서 폐기됐다
- [x] #7 [수동 검증] AI 서명 키(Claude·Antigravity)를 Secretive Secure Enclave 키(Touch ID 없음)로 옮겨 키 파일을 복사·유출할 수 없게 하고, 옛 파일 키는 GitHub·로컬에서 폐기한다
- [x] #8 [수동 검증] allowed_signers에 키마다 valid-after·valid-before가 있고, 교체 주기(사람 1년·AI 6개월)와 교체 절차가 키 목록 문서에 있다
- [x] #9 [수동 검증] 키 목록 문서(이름·용도·지문·위치·만든 날·만료일)와 사람 키 분실 시 복구 절차가 있다(예비 하드웨어 키는 장비가 생기면 추가)
- [x] #10 [수동 검증] VM 접속 키(rocky-dev)에 암호가 걸리고 macOS 키체인으로 열리며, gh 토큰에서 delete_repo·admin:org를 TASK-20 뒤 제거하는 일정이 문서에 있다
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [x] #1 [수동 검증] 검증 커밋 3종의 git log --show-signature 출력과 GitHub Verified 확인을 Notes에 첨부
- [x] #2 [수동 검증] 변경한 로컬 설정 파일 목록과 되돌리는 방법을 Notes에 기록
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

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
## 진행 (2026-11-01)
- AI 서명 키 생성: ~/.ssh/ai_claude_code_signing (SHA256:xJwF…), ~/.ssh/ai_antigravity_signing (SHA256:mvhT…), 암호 없음, 600
- 설정 초안: ~/githubs-backup/2026-11-01/identity/ — allowed_signers.new(human은 Secretive 키 자리표시), ssh_config.github.new, claude_settings_env.json, zshrc.snippet
- Antigravity: CLI(agy, Mach-O)와 Antigravity.app 둘. CLI 설정에는 env 항목이 없어 zsh 함수로 서명 키·AI_AGENT·gitformat.aiModel 주입
- 발견: git-commit-tool은 AI_AGENT 환경변수로만 AI 커밋을 판별 → Antigravity는 사람 커밋으로 오인됨. 래퍼가 AI_AGENT=antigravity_agy를 넣고, knownModel에 claude-opus-5-5 추가가 필요(GF 후속)
- 남은 유저 작업: 웹(이메일·2FA·점검·vigilant·보관 조직), Secretive 설치·키 생성, GitHub 키 등록, 설정 적용

## 검증 (2026-11-02)
- ssh -T git@github.com: 새 Secure Enclave 인증 키로 성공(유저 확인, Touch ID)
- 테스트 저장소 서명 결과(%G?/%GS): 사람 커밋 G/human(Touch ID), Claude 커밋 G/ai-claude-code(settings.json env), Antigravity 설정 커밋 G/ai-antigravity(agy()와 같은 env로 재현 — 실제 agy 실행 확인은 남음)
- 승인 게이트: agile-hooks require_implementation_plan.approval_status(humanSigners=["human"]) → 사람 Plan-Approved: ('approved','human'), Claude Plan-Approved: ('not_human','ai-claude-code') — AI 승인 거부 확인
- GitHub Verified 표시는 TASK-20 첫 push에서 확인
- 계정: gmail primary·private, public_email=null, 2FA on, 옛 개인 이메일 삭제(DELETE 204), coralstay-archive 조직 생성
- 남음: Vigilant mode 웹 확인, 옛 키(GitHub 인증 local-noreply-key-authN·서명 local-noreply-key, 로컬 ~/.ssh/github_signature) 폐기, ~/.mailmap 정리(보관 후)

## 마무리 (2026-11-02)
- 유저 확인: Vigilant mode 켜짐. 옛 키 폐기 확인: GitHub 인증키 1개(human auth), 서명키 3개(human·ai-claude-code·ai-antigravity), 로컬 ~/.ssh/github_signature 없음
- 실제 agy(Antigravity) 실행 서명 확인은 유저가 수동으로 한다
- ~/.mailmap은 이미 모든 옛 신원을 coralstay <noreply>로 묶음. 옛 이름 항목 자체의 삭제는 보관(TASK-20) 뒤에 한다

## 바꾼 로컬 설정과 되돌리는 법
| 파일 | 내용 | 되돌리기 |
|---|---|---|
| ~/.ssh/allowed_signers | human/ai-claude-code/ai-antigravity | allowed_signers.bak-2026-11 |
| ~/.ssh/config | github.com → Secretive 에이전트 키 | config.bak-2026-11 |
| ~/.gitconfig | user.email noreply, user.signingkey=secretive_git_signing.pub, commit/tag.gpgsign | git config --global로 이전 값 |
| ~/.zshrc | SSH_AUTH_SOCK(Secretive), agy() 래퍼 | '새 출발 신원 (TASK-19)' 블록 삭제 |
| ~/.claude/settings.json | env GIT_CONFIG_* → ai_claude_code_signing | env 블록 삭제 |
| 키 | ~/.ssh/ai_*_signing, Secretive github-auth·git-signing | GitHub Settings → SSH and GPG keys에서 삭제 |

정정(2026-11-02): AC #3·#4의 'GitHub에서 Verified'는 아직 확인 전(TASK-20 첫 push에서 확인) — 체크 해제. 로컬 서명·principal 구별은 확인됨.

## 수동 검증 증거
- 증거: TASK-3#1 TASK-3#B4 — `gh api user` → 2fa=true public_email=null / `gh api user/emails` → 계정 이메일(gmail) primary=true visibility=private, noreply만 추가로 남음(옛 개인 이메일 DELETE 204) / Vigilant mode·email private 2종은 유저가 웹에서 확인(2026-11-02)
- 증거: TASK-3#2 — 유저 터미널 `ssh -T git@github.com` → 'Hi coralstay!'(Touch ID 승인), `gh api user/keys` → 인증키 1개 'coralstay human auth (Secure Enclave, 2026-11)'
- 증거: TASK-3#3 TASK-3#B1 — Secretive 키 github-auth·git-signing(ECDSA, Require Authentication), 유저 터미널 사람 커밋 a4eef14 `%G?/%GS` → G/human(Touch ID). GitHub Verified는 TASK-20 첫 push에서 추가 증거
- 증거: TASK-3#4 TASK-3#B2 — 커밋 54edef7 G/ai-claude-code, 7dd7c2b G/ai-antigravity(agy() env 재현), 서명키 3개 GitHub 등록. 실제 agy 실행·GitHub Verified는 추가 증거 대기
- 증거: TASK-3#5 TASK-3#B3 — require_implementation_plan.approval_status(humanSigners=['human']): TEST-1(사람) ('approved','human'), TEST-2(Claude) ('not_human','ai-claude-code')
- 증거: TASK-3#6 — `git config --global user.email` → 231006716+coralstay@users.noreply.github.com, ~/.mailmap 대상 noreply, `gh api user/keys·ssh_signing_keys`에 옛 키 없음, `ls ~/.ssh | grep -c github_signature` → 0
- 증거: TASK-3#D1 TASK-3#D2 — 위 '검증'·'바꾼 로컬 설정과 되돌리는 법' 절

범위 확장(2026-11-02, 유저 요청): 키 관리 점검 결과 AI 키 Secretive 이전, 유효기간·교체 주기·키 목록 문서, gh 토큰 축소·VM 키 보호, 예비 사람 키(지금은 복구 절차 문서화만)를 AC #7~#10으로 추가.

## 키 관리 강화 준비 (2026-11-02)
- 키 목록·정책·복구 절차 문서: ~/githubs-backup/2026-11-01/identity/KEYS.md(로컬 전용, 600) — 지문·위치·만료, 교체 주기(사람 1년·AI 6개월)와 절차, 사람 키 분실 시 복구 절차, gh 토큰 축소 일정
- migrate-ai-keys.sh: Secretive AI 키 공개키 추출 → GitHub 서명 키 등록 → allowed_signers 유효기간(사람 20261102~20271102, AI 20261102~20270502, 옛 AI 파일 키 valid-before 20261103) → zshrc agy() 경로 교체, settings.json 변경안 출력
- protect-vm-key.sh: rocky-dev 키 암호 설정 + config.d UseKeychain

## 키 관리 강화 결과 (2026-11-05)
- 증거: TASK-3#7 — Secretive ai-claude-code·ai-antigravity(ECDSA, Notify, 알림 스타일 없음·알림 센터 기록). Claude 커밋 59a6146 G/ai-claude-code(ECDSA SHA256:ve62…), agy() 래퍼(가짜 agy로 실제 함수 실행) 커밋 d99360e G/ai-antigravity(ECDSA SHA256:s+pS…), env: AI_AGENT=antigravity_agy·gitformat.aiModel=claude-opus-5-5. 옛 파일 키: GitHub 서명키 1291793·1291794 삭제(유저), 로컬 ~/.ssh/ai_*_signing 4개 삭제, macOS 기본 에이전트의 옛 github_signature 메모리 사본 ssh-add -D로 제거. 실제 Antigravity 실행 확인은 쿼터 복구 뒤 유저가 수동으로
- 증거: TASK-3#8 — allowed_signers: human 20261102~20271102, ai-* 20261102~20270502, 옛 AI 파일 키 valid-before 20261103. 2026-11-05(만료 뒤)에도 11-02 커밋 54edef7·7dd7c2b·240e71b가 G로 확인 — 커밋 시각 기준 검증 실측. 교체 주기·절차는 KEYS.md 2절
- 증거: TASK-3#9 — ~/githubs-backup/2026-11-01/identity/KEYS.md(600): 키 목록(지문·위치·보호·만든 날·만료), 교체 절차, 사람 키 분실 복구 절차(예비 하드웨어 키는 장비가 생기면)
- 증거: TASK-3#10 — rocky-dev 키 암호 설정(ssh-keygen -y -P '' 실패), config.d UseKeychain, 'ssh -o BatchMode=yes rocky-dev' 성공(암호 입력 없이 → 키체인 사용). gh 토큰 축소 일정은 KEYS.md 4절(TASK-20 뒤)
- rocky-dev: Rocky Linux 9.8 (Blue Onyx), 커널 5.14.0-687.10.1.el9_8.0.1.aarch64, openssh-server 9.9p1-7.el9_8 — KEYS.md·config.d 주석에 기록. PQ 키 교환 경고는 서버 지원은 있으나 crypto-policies로 꺼진 것으로 보임(앞서 '8.x라 미지원'으로 추정한 설명은 틀렸음)
- 발견: toy-project scripts/_vm.sh가 config.d/rocky-dev를 재생성하며 UseKeychain을 빼고, 새 VM 키를 암호 없이 만든다 → toy-project DRAFT-24로 남김

증거: TASK-3#3 (GitHub) — 2026-11-06 재초기화한 17개 저장소의 사람 서명 첫 커밋이 GitHub에서 verified=true/valid(예: coralstay/freeride 01ed502). AC #4(AI 키의 GitHub Verified)는 Claude 커밋이 처음 push될 때 확인
<!-- SECTION:NOTES:END -->
