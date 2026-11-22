#!/bin/sh
# ---
# title: archive-transfer
# description: coralstay 계정 저장소를 보관 조직으로 이전하고 Archived로 바꾼 뒤 이전 전후 수치를 비교하는 스크립트
# authors: [coralstay]
# license: AGPL-3.0-only
# status: draft
# created_date: '2026-11-06'
# updated_date: '2026-11-06'
# ---
# TASK-20 2단계: coralstay 계정의 저장소 18개를 coralstay-archive 조직으로 옮기고(transfer) Archived(읽기 전용)로 바꾼다.
# - 공개 여부는 바꾸지 않는다(Public은 Public, Private은 Private). 보관본 공개는 TASK-22에서.
# - 여러 번 실행해도 안전하다: 이미 옮겼거나 Archived면 건너뛴다.
# - 끝나면 archive-baseline.tsv(옮기기 전 PR·이슈·릴리스 수)와 비교한다.
# 옮긴 뒤 github.com/coralstay/<이름>은 비어서, 다음 단계에서 같은 이름으로 새 저장소를 만들 수 있다.
set -u
SRC=coralstay
DST=coralstay-archive
BASE="$HOME/githubs-backup/2026-11-01/archive-baseline.tsv"
[ -f "$BASE" ] || { echo "기준 파일이 없습니다: $BASE"; exit 1; }  # ---- 1

names=$(tail -n +2 "$BASE" | cut -f1)
fail=0
for n in $names; do
  echo "== $n"
  if gh repo view "$DST/$n" >/dev/null 2>&1; then  # ---- 2
    echo "  이미 $DST 에 있음"
  else
    if ! gh api -X POST "repos/$SRC/$n/transfer" -f new_owner="$DST" >/dev/null; then
      echo "  transfer 실패"; fail=$((fail+1)); continue
    fi
    i=0; until gh repo view "$DST/$n" >/dev/null 2>&1 || [ $i -ge 30 ]; do sleep 2; i=$((i+1)); done  # ---- 3
    gh repo view "$DST/$n" >/dev/null 2>&1 && echo "  옮김" || { echo "  옮긴 저장소가 보이지 않음"; fail=$((fail+1)); continue; }
  fi
  if [ "$(gh repo view "$DST/$n" --json isArchived -q .isArchived)" = true ]; then  # ---- 4
    echo "  이미 Archived"
  else
    gh repo archive "$DST/$n" --yes >/dev/null && echo "  Archived" || { echo "  archive 실패"; fail=$((fail+1)); }
  fi
done

echo
echo "== 확인 (옮기기 전 → 후)"
printf "%-44s %-8s %s\n" 이름 공개 "PR / 이슈 / 릴리스"
tail -n +2 "$BASE" | while IFS="$(printf '\t')" read -r n vis prs iss rel _rest; do
  v2=$(gh repo view "$DST/$n" --json visibility,isArchived -q '.visibility + (if .isArchived then " Archived" else " (Archived 아님)" end)' 2>/dev/null || echo "없음")
  p2=$(gh pr list -R "$DST/$n" --state all --limit 1000 --json number -q length 2>/dev/null)
  i2=$(gh issue list -R "$DST/$n" --state all --limit 1000 --json number -q length 2>/dev/null)
  r2=$(gh release list -R "$DST/$n" --limit 100 --json tagName -q length 2>/dev/null)
  ok="같음"; [ "$prs/$iss/$rel" = "$p2/$i2/$r2" ] && [ "${v2%% *}" = "$vis" ] || ok="⚠️ 다름"  # ---- 5
  printf "%-44s %-8s %s → %s  %s (%s)\n" "$n" "$vis" "$prs/$iss/$rel" "$p2/$i2/$r2" "$ok" "$v2"
done
echo
[ $fail -eq 0 ] && echo "끝 (실패 0)" || echo "끝 (실패 $fail — 다시 실행하면 남은 것만 처리합니다)"

# ======== 노트 ========
# 1 기준 파일이 전제
#   설명: 옮길 저장소 목록과 옮기기 전 PR·이슈·릴리스 수는 백업 폴더의 archive-baseline.tsv에서 읽는다. 파일이 없으면 아무것도 하지 않고 멈춘다.
#   관련: TASK-20
# 2 이미 옮겼으면 건너뜀 (멱등)
#   설명: 조직 쪽에 저장소가 이미 보이면 transfer를 다시 부르지 않는다. 그래서 중간에 실패해도 다시 실행하면 남은 것만 처리한다.
#   개념: 멱등
# 3 transfer 완료 대기
#   설명: transfer는 비동기라 조직 쪽에 저장소가 보일 때까지 2초 간격으로 최대 30번(60초) 기다린다. 끝내 안 보이면 실패로 세고 다음 저장소로 넘어간다.
# 4 이미 Archived면 건너뜀
#   설명: 옮긴 뒤에만 Archived(읽기 전용)로 바꾼다. 이미 Archived면 다시 하지 않는다.
# 5 옮기기 전후 비교
#   설명: 공개 여부와 PR/이슈/릴리스 수가 baseline과 같은지 한 줄씩 표로 보인다. 다르면 "다름"으로 표시한다. 이전이 데이터를 잃지 않았다는 증거다.
#   관련: TASK-20
