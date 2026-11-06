#!/bin/sh
# ---
# title: protect-vm-key
# description: VM 접속 키에 암호를 걸고 macOS 키체인으로 열리게 설정하는 스크립트
# authors: [coralstay]
# license: AGPL-3.0-only
# status: draft
# created_date: '2026-11-06'
# updated_date: '2026-11-06'
# ---
# TASK-19 AC #10: VM 접속 키(rocky-dev)에 암호를 걸고 macOS 키체인으로 열리게 한다. 여러 번 실행해도 안전하다.
set -eu
K="$HOME/.ssh/rocky-dev_ed25519"
if ssh-keygen -y -P "" -f "$K" >/dev/null 2>&1; then  # ---- 1
  echo "== 암호 설정 (새 암호를 두 번 입력. 기존 암호는 없으니 첫 질문에는 Enter)"
  ssh-keygen -p -f "$K"
else
  echo "== 이미 암호가 걸려 있음"
fi
for f in "$HOME/.ssh/config.d/rocky-dev" "$HOME/.ssh/config.d/ebpf-tracer-v2.0.0"; do  # ---- 2
  grep -q 'UseKeychain' "$f" || { [ -e "$f.bak-2026-11" ] || cp -p "$f" "$f.bak-2026-11"; sed -i '' '/IdentitiesOnly yes/a\
  UseKeychain yes
' "$f"; }
  echo "  $(basename "$f"): $(grep -c UseKeychain "$f") UseKeychain"
done
echo "== 첫 접속(암호를 한 번 입력하면 키체인에 저장됨)"
ssh -o ConnectTimeout=5 rocky-dev true && echo "  접속 OK" || echo "  VM이 꺼져 있으면 실패해도 정상 — 다음 접속 때 암호를 한 번 입력"  # ---- 3

# ======== 노트 ========
# 1 빈 암호로 열리면 암호 없음
#   설명: 빈 암호로 공개키를 뽑을 수 있으면 아직 암호가 없는 키다. 그때만 암호를 설정하므로 여러 번 실행해도 안전하다.
#   개념: 멱등
# 2 UseKeychain은 없을 때만 추가
#   설명: ssh 설정 두 곳에 UseKeychain이 없으면 처음 한 번 백업하고 IdentitiesOnly yes 다음 줄에 넣는다(macOS sed -i 문법). 이 줄을 sed의 여러 줄 인자와 같은 줄에 두지 않으려고 표식은 for 줄에 달았다.
# 3 접속 실패는 정상일 수 있음
#   설명: VM이 꺼져 있으면 실패하지만 설정은 이미 끝난 것이다. 첫 접속에서 암호를 한 번 입력하면 키체인에 저장된다.
