#!/bin/sh
# ---
# title: migrate-ai-keys
# description: AI 서명 키를 Secretive로 옮기고 allowed_signers에 유효기간을 넣는 스크립트
# authors: [coralstay]
# license: AGPL-3.0-only
# status: draft
# created_date: '2026-11-06'
# updated_date: '2026-11-06'
# ---
# TASK-19 AC #7·#8: AI 서명 키를 파일에서 Secretive(Secure Enclave)로 옮기고, allowed_signers에 유효기간을 넣는다.
# 전제: Secretive에 Touch ID 없이(Require Authentication 끔) 키 두 개를 만들어 두었다 — 이름 ai-claude-code, ai-antigravity
# 여러 번 실행해도 안전하다. 바꾸는 파일은 처음 한 번만 .bak-ai-2026-11 로 백업한다.
# 옛 AI 파일 키는 여기서 지우지 않는다 — 새 키로 서명이 되는 걸 확인한 뒤 따로 폐기한다.
set -eu
S="$HOME/.ssh"
SOCK="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
TODAY=20261102
HUMAN_UNTIL=20271102
AI_UNTIL=20270502  # ---- 1
backup() { [ -e "$1" ] && [ ! -e "$1.bak-ai-2026-11" ] && cp -p "$1" "$1.bak-ai-2026-11" || true; }  # ---- 2

echo "== 1) Secretive에서 AI 공개키 꺼내기"
for a in ai-claude-code ai-antigravity; do
  f="$S/secretive_$(echo $a | tr - _).pub"
  SSH_AUTH_SOCK="$SOCK" ssh-add -L | grep " $a@" > "$f" || { echo "  Secretive에 '$a' 키가 없습니다. 먼저 만들어 주세요."; exit 1; }  # ---- 3
  chmod 644 "$f"; echo "  $(ssh-keygen -lf "$f")"
done

echo "== 2) GitHub 서명 키 등록"
list=$(gh api user/ssh_signing_keys -q '.[].key')
for a in ai-claude-code ai-antigravity; do
  f="$S/secretive_$(echo $a | tr - _).pub"; k=$(cut -d' ' -f1,2 "$f")
  if printf '%s\n' "$list" | grep -qF "$k"; then echo "  이미 있음: $a"  # ---- 4
  else gh ssh-key add "$f" --type signing --title "coralstay $a signing (Secure Enclave, 2026-11)" && echo "  등록: $a"; fi
done

echo "== 3) allowed_signers (유효기간 포함, 옛 AI 파일 키는 오늘까지만 유효)"
backup "$S/allowed_signers"
{
  printf 'human valid-after="%s",valid-before="%s",namespaces="git" %s\n' $TODAY $HUMAN_UNTIL "$(cut -d' ' -f1,2 "$S/secretive_git_signing.pub")"
  printf 'ai-claude-code valid-after="%s",valid-before="%s",namespaces="git" %s\n' $TODAY $AI_UNTIL "$(cut -d' ' -f1,2 "$S/secretive_ai_claude_code.pub")"
  printf 'ai-antigravity valid-after="%s",valid-before="%s",namespaces="git" %s\n' $TODAY $AI_UNTIL "$(cut -d' ' -f1,2 "$S/secretive_ai_antigravity.pub")"
  [ -f "$S/ai_claude_code_signing.pub" ] && printf 'ai-claude-code valid-before="%s",namespaces="git" %s\n' 20261103 "$(cut -d' ' -f1,2 "$S/ai_claude_code_signing.pub")"
  [ -f "$S/ai_antigravity_signing.pub" ] && printf 'ai-antigravity valid-before="%s",namespaces="git" %s\n' 20261103 "$(cut -d' ' -f1,2 "$S/ai_antigravity_signing.pub")"
} > "$S/allowed_signers"  # ---- 5
awk '{print "  " $1, $2}' "$S/allowed_signers"

echo "== 4) ~/.zshrc 의 agy(): Antigravity 서명 키를 Secretive 공개키로"
backup "$HOME/.zshrc"
sed -i '' 's#GIT_CONFIG_VALUE_0="$HOME/.ssh/ai_antigravity_signing"#GIT_CONFIG_VALUE_0="$HOME/.ssh/secretive_ai_antigravity.pub"#' "$HOME/.zshrc"  # ---- 6
grep -n 'GIT_CONFIG_VALUE_0' "$HOME/.zshrc" | sed 's/^/  /'

echo "== 5) 직접 바꿔 주세요: ~/.claude/settings.json 의 env"  # ---- 7
cat <<EOF
  "env": {
    "GIT_CONFIG_COUNT": "1",
    "GIT_CONFIG_KEY_0": "user.signingkey",
    "GIT_CONFIG_VALUE_0": "$S/secretive_ai_claude_code.pub",
    "SSH_AUTH_SOCK": "$SOCK"
  },
  (GIT_CONFIG_VALUE_0 값을 바꾸고 SSH_AUTH_SOCK 줄을 추가한 뒤 Claude Code 재시작)
EOF
echo "끝"

# ======== 노트 ========
# 1 유효기간: 사람 1년, AI 6개월
#   설명: allowed_signers의 valid-before에 쓰는 날짜다. 사람 키는 1년(20271102), AI 키는 6개월(20270502)이라 AI 키를 더 자주 갈아 끼운다. TODAY는 valid-after다.
# 2 처음 한 번만 백업
#   설명: .bak-ai-2026-11 백업이 이미 있으면 덮어쓰지 않는다.
#   개념: 멱등
# 3 공개키만 꺼낸다
#   설명: Secretive 에이전트의 ssh-add -L 출력에서 이름이 맞는 공개키만 파일로 받는다. 비밀키는 Secure Enclave 밖으로 나오지 않는다. 키가 없으면 멈춘다.
# 4 이미 등록됐으면 건너뜀
#   설명: 공개키 본문을 GitHub 서명 키 목록과 비교한다.
#   개념: 멱등
# 5 옛 AI 파일 키는 하루만 유효
#   설명: 새 키를 유효기간과 함께 쓰고, 옛 파일 키가 남아 있으면 20261103까지만 유효하게 둔다. 새 키 서명이 확인되면 옛 키를 따로 폐기한다.
#   관련: scripts/identity/apply-identity.sh
# 6 zshrc는 sed로 제자리 수정
#   설명: agy()의 서명 키를 파일 키에서 Secretive 공개키로 바꾼다. macOS sed -i 문법이라 GNU sed에서는 그대로 쓸 수 없다. 바꾸기 전에 처음 한 번 백업한다.
# 7 settings.json은 스크립트가 고치지 않음
#   설명: Claude Code 설정은 스크립트가 아니라 사람이 직접 바꾸도록 안내만 출력한다(아래 heredoc). 값을 바꾼 뒤 Claude Code를 재시작해야 한다.
