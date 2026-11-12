#!/bin/sh
# ---
# title: apply-identity
# description: GitHub 키 등록, allowed_signers, ssh 설정, git 전역 서명 설정으로 새 신원을 적용하는 스크립트
# authors: [coralstay]
# license: AGPL-3.0-only
# status: draft
# created_date: '2026-11-06'
# updated_date: '2026-11-06'
# ---
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

backup() { [ -e "$1" ] && [ ! -e "$1.bak-2026-11" ] && cp -p "$1" "$1.bak-2026-11" || true; }  # ---- 1
fp() { ssh-keygen -lf "$1" | awk '{print $2}'; }

echo "== 1) GitHub 키 등록"
add_key() { # $1=파일 $2=type $3=title
  k=$(cut -d' ' -f1,2 "$1")
  if [ "$2" = signing ]; then list=$(gh api user/ssh_signing_keys -q '.[].key'); else list=$(gh api user/keys -q '.[].key'); fi
  if printf '%s\n' "$list" | grep -qF "$k"; then echo "  이미 있음: $3"; else gh ssh-key add "$1" --type "$2" --title "$3" && echo "  등록: $3"; fi  # ---- 2
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
} > "$S/allowed_signers"  # ---- 3
cat "$S/allowed_signers" | awk '{print "  " $1, $3}'

echo "== 3) ~/.ssh/config (github.com → Secretive)"
backup "$S/config"  # ---- 4
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
git config --global user.email "$NOREPLY"  # ---- 5
git config --global gpg.format ssh
git config --global user.signingkey "$S/secretive_git_signing.pub"  # ---- 6
git config --global commit.gpgsign true
git config --global tag.gpgsign true
git config --global gpg.ssh.allowedSignersFile "$S/allowed_signers"
git config --global --get-regexp '^(user|gpg|commit|tag)\.' | sed 's/^/  /'

echo "== 확인: GitHub 접속(Touch ID 요구가 뜨면 승인)"
ssh -T git@github.com 2>&1 | sed 's/^/  /' || true  # ---- 7
echo "끝"

# ======== 노트 ========
# 1 처음 한 번만 백업
#   설명: .bak-2026-11 백업이 이미 있으면 덮어쓰지 않는다. 그래서 여러 번 실행해도 원본이 보존된다.
#   개념: 멱등
# 2 공개키 본문으로 중복 등록 방지
#   설명: 파일의 앞 두 필드(키 종류와 본문)를 GitHub에 등록된 목록과 비교해 있으면 건너뛴다. 등록은 공개키만 쓴다.
# 3 allowed_signers는 통째로 다시 만든다
#   설명: human, ai-claude-code, ai-antigravity 세 principal을 줄마다 쓴다. 파일 전체를 덮어쓰므로 직접 넣은 줄은 남지 않는다(백업은 처음 한 번).
#   관련: scripts/identity/migrate-ai-keys.sh
# 4 ssh config는 github.com 블록만 교체
#   설명: Host github.com 블록을 정규식으로 찾아 교체하고, 없으면 파일 끝에 붙인다(아래 python 조각). 접속은 Secretive 에이전트 키만 쓰도록 IdentitiesOnly를 켠다.
# 5 커밋 이메일은 noreply
#   설명: git 전역 user.email을 GitHub noreply 주소로 둔다. 개인 이메일이 커밋에 남지 않게 한다.
# 6 기본 서명 키는 사람 키
#   설명: 전역 서명 키를 사람 서명 키(Secure Enclave, Touch ID)로 한다. AI 에이전트는 환경 변수로 자기 키를 덮어쓴다.
#   관련: scripts/reinit.sh
# 7 ssh -T 실패를 무시
#   설명: 마지막 확인 단계다. GitHub는 성공해도 0이 아닌 코드로 끝나고, Touch ID 요구가 뜰 수도 있어서 실패해도 스크립트를 멈추지 않는다.
