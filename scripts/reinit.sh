#!/bin/sh
# ---
# title: reinit
# description: 저장소의 .git을 지우고 사람 서명 첫 커밋으로 다시 시작해 Private 저장소로 push하는 재초기화 스크립트
# authors: [coralstay]
# license: AGPL-3.0-only
# status: draft
# created_date: '2026-11-06'
# updated_date: '2026-11-06'
# ---
# TASK-20 4단계: 저장소의 .git을 지우고 새 첫 커밋(사람 서명, Touch ID) 하나로 다시 시작한 뒤,
# coralstay 계정에 같은 이름의 Private 저장소를 만들어 push한다. 설명·토픽·홈페이지는 보관본에서 복원한다.
# 사용법: sh reinit.sh            (아래 순서대로 전부)
#         sh reinit.sh <로컬경로>  (하나만, 예: freeride/databases)
# 여러 번 실행해도 안전하다: 이미 새 이력(커밋 1개, origin=coralstay/<이름>)이면 건너뛴다.
# 지키는 것(TASK-20 B1·B2·B3)
#  - 로컬 mirror와 GitHub 보관본(coralstay-archive, Archived)이 둘 다 있어야만 .git을 지운다
#  - 첫 커밋 대상 파일 수가 3단계 미리보기(reinit-preview/<이름>.files)와 같아야 커밋한다
#  - 민감 패턴이 하나라도 있으면 멈춘다
#  - 새 저장소는 Private
set -u
G="$HOME/githubs"
D="$HOME/githubs-backup/2026-11-01"
A="$HOME/githubs-archive/2026-11-01"
NOREPLY="231006716+coralstay@users.noreply.github.com"
P="$(cd "$(dirname "$0")/.." && pwd)/local/patterns.sh"  # ---- 1
[ -f "$P" ] || { echo "민감 패턴 파일이 없습니다: $P"; exit 1; }
. "$P"
PAT="$PAT_REINIT"

LIST="
.github-profile coralstay
coralstay-software-factory coralstay-software-factory
coralstay-software-factory/components/agent-orchestrator agent-orchestrator
coralstay-software-factory/components/claude-code-agile-hooks claude-code-agile-hooks
coralstay-software-factory/components/coding-agent-git-commit-tool coding-agent-git-commit-tool
dev-tools/central-docs-collector central-docs-collector
dev-tools/dev-toolchain dev-toolchain
dev-tools/omnivim omnivim
freeride freeride
freeride/coding-style-refactoring-principles coding-style-refactoring-principles
freeride/databases databases
freeride/devOps-LifeCycle devOps-LifeCycle
freeride/doctree doctree
freeride/handcrafted-cpp handcrafted-cpp
freeride/handcrafted-java handcrafted-java
toy-project/react-next-spring-postgresql-terraform-aws react-next-spring-postgresql-terraform-aws
dev-tools/source-header source-header
"

owned_here() { [ "$(gh repo view "coralstay/$1" --json nameWithOwner -q .nameWithOwner 2>/dev/null)" = "coralstay/$1" ]; }  # ---- 2

# 보관본의 설명·홈페이지·토픽을 새 저장소에 복원한다
restore_meta() {
  meta=$(gh repo view "coralstay-archive/$1" --json description,homepageUrl,repositoryTopics -q '[.description, .homepageUrl, ([.repositoryTopics[]?.name]|join(","))]|@tsv')
  desc=$(printf '%s' "$meta" | cut -f1); home=$(printf '%s' "$meta" | cut -f2); topics=$(printf '%s' "$meta" | cut -f3)
  [ -n "$desc" ] && gh repo edit "coralstay/$1" --description "$desc" >/dev/null
  [ -n "$home" ] && gh repo edit "coralstay/$1" --homepage "$home" >/dev/null
  [ -n "$topics" ] && gh repo edit "coralstay/$1" --add-topic "$topics" >/dev/null
  return 0
}
# GitHub 쪽 결과: 공개 여부, 커밋 수, Verified
verify_remote() {
  v=$(gh api "repos/coralstay/$1/commits/main" -q '.commit.verification | (.verified|tostring) + " " + .reason' 2>/dev/null || echo "확인 실패")
  c=$(gh api "repos/coralstay/$1/commits" -q length 2>/dev/null || echo "?")
  echo "  GitHub: $(gh repo view "coralstay/$1" --json visibility -q .visibility), 커밋 ${c}개, verified=${v}"
}

reinit_one() { # $1=로컬 경로 $2=GitHub 이름
  r="$1"; n="$2"; p="$G/$r"; key=$(echo "$r" | tr / _)
  echo "== $r → coralstay/$n"
  [ -d "$p/.git" ] || { echo "  .git 없음 — 건너뜀"; return 1; }
  if [ "$(git -C "$p" rev-list --count --all 2>/dev/null)" = 1 ] && git -C "$p" remote get-url origin 2>/dev/null | grep -q "coralstay/$n.git" && owned_here "$n"; then  # ---- 3
    local_head=$(git -C "$p" rev-parse HEAD)
    remote_head=$(git -C "$p" ls-remote origin refs/heads/main 2>/dev/null | cut -f1)
    if [ "$remote_head" = "$local_head" ]; then
      echo "  이미 새 이력이고 push도 됨 — 건너뜀"; verify_remote "$n"; return 0
    fi
    [ "$(git -C "$p" log -1 --format=%G?%GS)" = Ghuman ] || { echo "  ✗ 로컬 첫 커밋이 사람 서명이 아님 — 멈춤"; return 1; }
    echo "  새 저장소는 있지만 push가 안 됨 — push를 이어서 합니다(GitHub 접속에 Touch ID가 필요할 수 있어요)"
    git -C "$p" push -u origin main || { echo "  ✗ push 실패"; return 1; }
    restore_meta "$n"; verify_remote "$n"; return 0
  fi
  [ -d "$A/$key.git" ] || { echo "  ✗ 로컬 mirror 없음: $A/$key.git"; return 1; }  # ---- 4
  [ "$(gh repo view "coralstay-archive/$n" --json isArchived -q .isArchived 2>/dev/null)" = true ] || { echo "  ✗ GitHub 보관본(Archived) 없음"; return 1; }
  owned_here "$n" && { echo "  ✗ coralstay/$n 이 이미 있음(보관 이전이 안 됐거나 다른 저장소)"; return 1; }
  # 보관본 메타데이터
  meta=$(gh repo view "coralstay-archive/$n" --json description,homepageUrl,repositoryTopics -q '[.description, .homepageUrl, ([.repositoryTopics[]?.name]|join(","))]|@tsv')
  desc=$(printf '%s' "$meta" | cut -f1); home=$(printf '%s' "$meta" | cut -f2); topics=$(printf '%s' "$meta" | cut -f3)
  # 재초기화
  excl=$(mktemp); [ -f "$p/.git/info/exclude" ] && cp "$p/.git/info/exclude" "$excl"  # ---- 5
  rm -rf "$p/.git"  # ---- 6
  git -C "$p" init -q -b main
  [ -s "$excl" ] && cp "$excl" "$p/.git/info/exclude"; rm -f "$excl"
  git -C "$p" add -A
  cnt=$(git -C "$p" diff --cached --name-only | wc -l | tr -d ' ')
  exp=$(wc -l < "$D/reinit-preview/$key.files" | tr -d ' ')
  if [ "$cnt" != "$exp" ]; then  # ---- 7
    echo "  ✗ 첫 커밋 파일 수 $cnt ≠ 미리보기 $exp — 멈춤(.git은 새로 init된 상태, 커밋 전). 미리보기를 다시 돌려 확인하세요"; return 1
  fi
  if git -C "$p" diff --cached --name-only -z | (cd "$p" && xargs -0 grep -lIiE "$PAT" 2>/dev/null) | grep -q .; then  # ---- 8
    echo "  ✗ 민감 패턴이 남아 있음 — 멈춤:"; git -C "$p" diff --cached --name-only -z | (cd "$p" && xargs -0 grep -lIiE "$PAT") | sed 's/^/    /'; return 1
  fi
  case "$n" in coding-agent-git-commit-tool) msg="[chore] 새 출발 첫 커밋";; *) msg="chore: initial commit";; esac
  echo "  첫 커밋(파일 ${cnt}개) — Touch ID 창이 뜨면 승인하세요"
  git -C "$p" -c user.name=coralstay -c user.email="$NOREPLY" commit -q -S -m "$msg" || { echo "  ✗ 커밋 실패"; return 1; }
  git -C "$p" log -1 --format='  %h %an <%ae> 서명=%G? %GS %s'
  [ "$(git -C "$p" log -1 --format=%G?%GS)" = Ghuman ] || { echo "  ✗ 사람 서명(G/human)이 아님 — push하지 않고 멈춤"; return 1; }  # ---- 9
  # 새 저장소(Private) + push
  (cd "$p" && gh repo create "coralstay/$n" --private --source . --remote origin >/dev/null) || { echo "  ✗ 저장소 생성 실패"; return 1; }  # ---- 10
  echo "  push(GitHub 접속에 Touch ID가 필요할 수 있어요)"
  git -C "$p" push -u origin main || { echo "  ✗ push 실패 — 다시 실행하면 push만 이어서 합니다"; return 1; }
  restore_meta "$n"; verify_remote "$n"
}

case "${GIT_CONFIG_VALUE_0:-}${AI_AGENT:-}" in  # ---- 11
  *ai_*|*secretive_ai_*|*antigravity*|*claude*) echo "✗ AI 서명 환경에서 실행 중입니다. Claude Code의 ! 가 아니라 별도 터미널에서 실행하세요."; exit 1;;
esac
[ "$(git config --global user.signingkey)" = "$HOME/.ssh/secretive_git_signing.pub" ] || { echo "✗ 전역 서명 키가 사람 키가 아닙니다"; exit 1; }  # ---- 12

fail=0
echo "$LIST" | while read -r r n; do  # ---- 13
  [ -n "$r" ] || continue
  [ $# -eq 0 ] || [ "$1" = "$r" ] || continue
  reinit_one "$r" "$n" || echo "  → 실패: $r"
done
echo "끝"

# ======== 노트 ========
# 1 민감 패턴은 저장소 밖에서 읽는다
#   설명: 민감 패턴(대소문자 무시 grep 식)은 저장소에 두지 않고 local/patterns.sh(로컬 전용, .gitignore)에서 읽는다. 파일이 없으면 멈춘다.
#   관련: README.md
# 2 옛 주소는 보관본으로 자동 연결된다
#   설명: 이전한 저장소의 옛 주소 coralstay/<이름>은 보관본으로 연결되므로, 조회 결과의 nameWithOwner가 정확히 coralstay/<이름>인지까지 본다. 그래야 "새 저장소가 이미 있다"를 정확히 판별한다.
# 3 이미 새 이력이면 건너뛰거나 push만 이어서
#   설명: 커밋이 1개이고 origin이 coralstay/<이름>이고 새 저장소가 있으면 재초기화를 다시 하지 않는다. 원격 main이 로컬 HEAD와 같으면 건너뛰고, 다르면 사람 서명을 확인한 뒤 push만 이어서 한다.
#   개념: 멱등
# 4 B1 보관 확인
#   설명: 로컬 mirror와 GitHub 보관본(Archived)이 둘 다 있어야만 .git을 지운다. 보관본이 없으면 이 저장소는 건너뛴다.
#   관련: TASK-20
# 5 .git/info/exclude 보존
#   설명: 로컬 전용 제외 목록(dev-toolchain이 넣는 .opensource/, 개인 메모 등)을 임시 파일로 빼 두었다가 새 .git으로 옮긴다. 지우면 이 파일이 사라지기 때문이다.
# 6 되돌릴 수 없는 지점
#   설명: 이 줄이 기존 이력을 지운다. 위의 보관 확인(B1)을 통과한 뒤에만 도달해야 하고, 이후 단계가 실패해도 이력을 복구하는 길은 보관본뿐이다.
#   관련: TASK-20
# 7 B2 첫 커밋 파일 수 일치
#   설명: git add -A로 올라온 파일 수가 3단계 미리보기(reinit-preview.sh)의 .files 개수와 다르면 커밋하지 않고 멈춘다.
#   관련: scripts/reinit-preview.sh
# 8 B3 민감 패턴이 있으면 멈춤
#   설명: staged 파일에 민감 패턴이 하나라도 있으면 목록을 보이고 멈춘다. 패턴 자체는 local/patterns.sh에만 있다.
# 9 사람 서명이 아니면 push하지 않음
#   설명: 첫 커밋의 서명 상태가 "G"(유효)이고 서명자가 human인 경우만 원격에 올린다. 사람 키(Touch ID)로 서명된 이력만 올린다.
# 10 저장소 생성과 push를 나눔
#   설명: Private으로 만들고 push는 따로 한다. push가 실패해도 다시 실행하면 위의 "이미 새 이력" 분기로 push만 이어서 한다.
#   개념: 멱등
# 11 AI 서명 환경에서는 실행하지 않음
#   설명: Claude Code(!)나 agy 안에서 실행하면 GIT_CONFIG_* 환경 변수로 AI 키가 서명 키가 되어 첫 커밋이 AI 서명이 된다. 별도 터미널에서 실행해야 한다.
# 12 전역 서명 키가 사람 키여야 함
#   설명: git 전역 user.signingkey가 사람 서명 공개키 파일을 가리키는지 확인한다. 다르면 시작하지 않는다.
#   관련: scripts/identity/apply-identity.sh
# 13 LIST가 대상 목록
#   설명: 로컬 경로와 GitHub 이름 쌍을 줄마다 적은 목록이다. ebpf-wire-to-code-tracer는 Antigravity 작업 중이라 이번에는 목록에서 뺐다. 인자로 경로 하나를 주면 그것만 처리한다.
