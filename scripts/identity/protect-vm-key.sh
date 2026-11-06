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
if ssh-keygen -y -P "" -f "$K" >/dev/null 2>&1; then
  echo "== 암호 설정 (새 암호를 두 번 입력. 기존 암호는 없으니 첫 질문에는 Enter)"
  ssh-keygen -p -f "$K"
else
  echo "== 이미 암호가 걸려 있음"
fi
for f in "$HOME/.ssh/config.d/rocky-dev" "$HOME/.ssh/config.d/ebpf-tracer-v2.0.0"; do
  grep -q 'UseKeychain' "$f" || { [ -e "$f.bak-2026-11" ] || cp -p "$f" "$f.bak-2026-11"; sed -i '' '/IdentitiesOnly yes/a\
  UseKeychain yes
' "$f"; }
  echo "  $(basename "$f"): $(grep -c UseKeychain "$f") UseKeychain"
done
echo "== 첫 접속(암호를 한 번 입력하면 키체인에 저장됨)"
ssh -o ConnectTimeout=5 rocky-dev true && echo "  접속 OK" || echo "  VM이 꺼져 있으면 실패해도 정상 — 다음 접속 때 암호를 한 번 입력"
