#!/bin/sh
# TASK-19 AC #7·#8: AI 서명 키를 파일에서 Secretive(Secure Enclave)로 옮기고, allowed_signers에 유효기간을 넣는다.
# 전제: Secretive에 Touch ID 없이(Require Authentication 끔) 키 두 개를 만들어 두었다 — 이름 ai-claude-code, ai-antigravity
# 여러 번 실행해도 안전하다. 바꾸는 파일은 처음 한 번만 .bak-ai-2026-11 로 백업한다.
# 옛 AI 파일 키는 여기서 지우지 않는다 — 새 키로 서명이 되는 걸 확인한 뒤 따로 폐기한다.
set -eu
S="$HOME/.ssh"
SOCK="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
TODAY=20261102
HUMAN_UNTIL=20271102   # 사람 키 1년
AI_UNTIL=20270502      # AI 키 6개월
backup() { [ -e "$1" ] && [ ! -e "$1.bak-ai-2026-11" ] && cp -p "$1" "$1.bak-ai-2026-11" || true; }

echo "== 1) Secretive에서 AI 공개키 꺼내기"
for a in ai-claude-code ai-antigravity; do
  f="$S/secretive_$(echo $a | tr - _).pub"
  SSH_AUTH_SOCK="$SOCK" ssh-add -L | grep " $a@" > "$f" || { echo "  Secretive에 '$a' 키가 없습니다. 먼저 만들어 주세요."; exit 1; }
  chmod 644 "$f"; echo "  $(ssh-keygen -lf "$f")"
done

echo "== 2) GitHub 서명 키 등록"
list=$(gh api user/ssh_signing_keys -q '.[].key')
for a in ai-claude-code ai-antigravity; do
  f="$S/secretive_$(echo $a | tr - _).pub"; k=$(cut -d' ' -f1,2 "$f")
  if printf '%s\n' "$list" | grep -qF "$k"; then echo "  이미 있음: $a"
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
} > "$S/allowed_signers"
awk '{print "  " $1, $2}' "$S/allowed_signers"

echo "== 4) ~/.zshrc 의 agy(): Antigravity 서명 키를 Secretive 공개키로"
backup "$HOME/.zshrc"
sed -i '' 's#GIT_CONFIG_VALUE_0="$HOME/.ssh/ai_antigravity_signing"#GIT_CONFIG_VALUE_0="$HOME/.ssh/secretive_ai_antigravity.pub"#' "$HOME/.zshrc"
grep -n 'GIT_CONFIG_VALUE_0' "$HOME/.zshrc" | sed 's/^/  /'

echo "== 5) 직접 바꿔 주세요: ~/.claude/settings.json 의 env"
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
