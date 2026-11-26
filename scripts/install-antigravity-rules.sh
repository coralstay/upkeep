#!/bin/sh
# ---
# title: install-antigravity-rules
# description: upkeep/agents 의 Antigravity 전역 규칙 원본을 ~/.gemini/config/rules/ 에 설치하되 다른 내용이 있으면 덮지 않고 차이만 보이는 스크립트
# authors: [coralstay]
# license: AGPL-3.0-only
# status: draft
# task: TASK-9
# created_date: '2026-11-26'
# updated_date: '2026-11-26'
# ---
# TASK-9: 저장소별 담당 규칙을 Antigravity 전역 모듈 규칙으로 설치한다. 유저가 직접 실행한다.
# 사용: scripts/install-antigravity-rules.sh [--force]
# 종료 코드: 0 설치함 · 이미 같음, 1 다른 내용이 있어 덮지 않음, 2 사용법 오류
set -eu
FORCE=0
case "${1:-}" in  # ---- 1
  "") ;;
  --force) FORCE=1 ;;
  *) echo "사용법: $0 [--force]" >&2; exit 2 ;;
esac
SRC="$(cd "$(dirname "$0")/.." && pwd)/agents/antigravity-repo-ownership.md"
DEST="$HOME/.gemini/config/rules/coralstay-repo-ownership.md"  # ---- 2

if [ -e "$DEST" ] && [ "$FORCE" -eq 0 ]; then
  if cmp -s "$SRC" "$DEST"; then
    echo "이미 같음: $DEST"
    exit 0
  fi
  echo "설치된 규칙이 원본과 다릅니다. 덮어쓰지 않았습니다: $DEST"  # ---- 3
  diff -u "$DEST" "$SRC" || true
  echo "원본으로 바꾸려면 --force 를 붙여 다시 실행하세요."
  exit 1
fi
mkdir -p "$(dirname "$DEST")"
cp "$SRC" "$DEST"
echo "설치함: $DEST"

# ======== 노트 ========
# 1 인자는 --force 하나뿐
#   설명: 오타(--forse 등)를 조용히 무시하면 덮어쓰기 의도가 묻히므로, 모르는 인자는 아무것도 하지 않고 2로 끝낸다.
# 2 설치 위치는 모듈 규칙 파일 하나
#   설명: Antigravity 전역 규칙은 ~/.gemini/GEMINI.md · AGENTS.md(독립 파일) 또는 ~/.gemini/config/rules/*.md(모듈 규칙, trigger 프론트매터 필요)에서 읽고 모두 합쳐 적용한다. 유저 파일과 섞이지 않도록 이름이 정해진 모듈 파일 하나만 쓰고, 다른 파일은 건드리지 않는다.
#   관련: TASK-9, decision-25
#   출처: https://antigravity.google/docs/rules
# 3 다르면 덮지 않음
#   설명: 설치된 파일을 유저가 고쳤을 수 있으므로 묻지 않고 덮지 않는다. 차이(설치본 → 원본)를 보이고 1로 끝내며, 바꾸는 건 --force 로만 한다.
