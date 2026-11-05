#!/bin/sh
# TASK-19: 새 신원 적용. 여러 번 실행해도 안전하다(있는 키는 건너뛰고, 바꾸는 파일은 처음 한 번만 .bak-2026-11 으로 백업).
# 하는 일
#   1) GitHub에 키 4개 등록: 사람 접속(Secure Enclave), 사람 서명(Secure Enclave), AI 서명 Claude·Antigravity
#   2) ~/.ssh/allowed_signers: human / ai-claude-code / ai-antigravity principal로 분리
#   3) ~/.ssh/config: github.com 접속을 Secretive 에이전트 키로
#   4) git 전역: 커밋 이메일 noreply, 기본 서명 키 = 사람 서명 키(Touch ID)
# 옛 키(github_signature)는 지우지 않는다 — 검증이 끝난 뒤 따로 폐기한다.
set -eu
S="$HOME/.ssh"
SOCK="$HOME/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
NOREPLY="231006716+coralstay@users.noreply.github.com"

backup() { [ -e "$1" ] && [ ! -e "$1.bak-2026-11" ] && cp -p "$1" "$1.bak-2026-11" || true; }
fp() { ssh-keygen -lf "$1" | awk '{print $2}'; }

echo "== 1) GitHub 키 등록"
add_key() { # $1=파일 $2=type $3=title
  k=$(cut -d' ' -f1,2 "$1")
  if [ "$2" = signing ]; then list=$(gh api user/ssh_signing_keys -q '.[].key'); else list=$(gh api user/keys -q '.[].key'); fi
  if printf '%s\n' "$list" | grep -qF "$k"; then echo "  이미 있음: $3"; else gh ssh-key add "$1" --type "$2" --title "$3" && echo "  등록: $3"; fi
}
add_key "$S/secretive_github_auth.pub" authentication "coralstay human auth (Secure Enclave, 2026-11)"
add_key "$S/secretive_git_signing.pub" signing "coralstay human signing (Secure Enclave, 2026-11)"
add_key "$S/ai_claude_code_signing.pub" signing "coralstay ai-claude-code signing (2026-11)"
add_key "$S/ai_antigravity_signing.pub" signing "coralstay ai-antigravity signing (2026-11)"

echo "== 2) allowed_signers"
backup "$S/allowed_signers"
{
  printf 'human namespaces="git" %s\n' "$(cut -d' ' -f1,2 "$S/secretive_git_signing.pub")"
  printf 'ai-claude-code namespaces="git" %s\n' "$(cut -d' ' -f1,2 "$S/ai_claude_code_signing.pub")"
  printf 'ai-antigravity namespaces="git" %s\n' "$(cut -d' ' -f1,2 "$S/ai_antigravity_signing.pub")"
} > "$S/allowed_signers"
cat "$S/allowed_signers" | awk '{print "  " $1, $3}'

echo "== 3) ~/.ssh/config (github.com → Secretive)"
backup "$S/config"
python3 - "$S/config" "$SOCK" <<'PY'
import sys, re
p, sock = sys.argv[1], sys.argv[2]
s = open(p).read()
block = ("Host github.com\n  HostName github.com\n  User git\n"
         f"  IdentityAgent \"{sock}\"\n  IdentityFile ~/.ssh/secretive_github_auth.pub\n  IdentitiesOnly yes\n")
new, n = re.subn(r"(?ms)^Host github\.com\n(?:[ \t]+.*\n?)*", block, s)
if n == 0:
    new = s.rstrip("\n") + "\n" + block
open(p, "w").write(new)
PY
sed -n '/^Host github.com/,/^$/p' "$S/config" | sed 's/^/  /'

echo "== 4) git 전역"
git config --global user.name coralstay
git config --global user.email "$NOREPLY"
git config --global gpg.format ssh
git config --global user.signingkey "$S/secretive_git_signing.pub"
git config --global commit.gpgsign true
git config --global tag.gpgsign true
git config --global gpg.ssh.allowedSignersFile "$S/allowed_signers"
git config --global --get-regexp '^(user|gpg|commit|tag)\.' | sed 's/^/  /'

echo "== 확인: GitHub 접속(Touch ID 요구가 뜨면 승인)"
ssh -T git@github.com 2>&1 | sed 's/^/  /' || true
echo "끝"
