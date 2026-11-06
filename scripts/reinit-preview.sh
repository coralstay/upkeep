#!/bin/sh
# ---
# title: reinit-preview
# description: 저장소 재초기화 시 첫 커밋 대상 파일을 읽기 전용으로 뽑아 민감 패턴·대용량·제3자 흔적을 검사하는 스크립트
# authors: [coralstay]
# license: AGPL-3.0-only
# status: draft
# created_date: '2026-11-06'
# updated_date: '2026-11-06'
# ---
# TASK-20 3단계: 재초기화하면 첫 커밋에 들어갈 파일을 미리 뽑아 검사한다. 저장소는 아무것도 바꾸지 않는다(읽기 전용).
# 첫 커밋 대상 = (추적 중 + 추적 안 된 파일) 중 .gitignore에 걸리지 않는 것 — git init 뒤 `git add -A`와 같다.
# 검사: 민감 패턴 grep, gitleaks(대상 파일만 임시 폴더에 복사해 dir 스캔), 1MB 넘는 파일, 제3자 흔적 경로.
# 결과: <out>/<이름>.files(대상 목록), <out>/<이름>.findings(걸린 줄), 표 요약
set -u
G="$HOME/githubs"
OUT="${1:-$HOME/githubs-backup/2026-11-01/reinit-preview}"
mkdir -p "$OUT"
GITLEAKS="$G/bin/gitleaks"
# 민감 패턴(대소문자 무시). Drive ID는 doctree의 실제 map ID와 대조한다(아래).
# 민감 패턴은 저장소에 두지 않는다: local/patterns.sh(로컬 전용, .gitignore)에서 읽는다
P="$(cd "$(dirname "$0")/.." && pwd)/local/patterns.sh"
[ -f "$P" ] || { echo "민감 패턴 파일이 없습니다: $P"; exit 1; }
. "$P"
PAT="$PAT_PREVIEW"
THIRD='(^|/)(official_sources|\.ocr-cache|jls-spec|googletest|jongmanbook|stone-lecture|08_prof_cpp|07_extreme_c)(/|$)|\.(pdf|epub)$'

printf "%-58s %6s %6s %6s %6s %6s %s\n" 저장소 파일수 패턴 비밀값 1MB초과 제3자 비고
cd "$G" || exit 1
for g in $(find . -path ./opensource -prune -o -path '*/references' -prune -o -name .git -maxdepth 5 -print | sort); do
  r=${g%/.git}; r=${r#./}; n=$(echo "$r" | tr / _)
  f="$OUT/$n.files"; : > "$OUT/$n.findings"
  # 첫 커밋 대상 목록(추적 중이지만 .gitignore에 걸린 파일은 뺀다)
  git -C "$r" ls-files -co --exclude-standard -z | tr '\0' '\n' | while IFS= read -r p; do
    [ -e "$r/$p" ] || [ -L "$r/$p" ] || continue
    git -C "$r" check-ignore -q --no-index -- "$p" 2>/dev/null && continue
    printf '%s\n' "$p"
  done | sort > "$f"
  cnt=$(wc -l < "$f" | tr -d ' ')
  # 민감 패턴
  pat=0; while IFS= read -r p; do [ -f "$r/$p" ] && [ ! -L "$r/$p" ] || continue
    if grep -InIiE "$PAT" "$r/$p" >/dev/null 2>&1; then grep -InIiE "$PAT" "$r/$p" | sed "s|^|PAT $p:|" >> "$OUT/$n.findings"; pat=$((pat+1)); fi
  done < "$f"
  # 제3자 흔적 경로
  third=$(grep -cE "$THIRD" "$f"); grep -E "$THIRD" "$f" | sed 's/^/THIRD /' >> "$OUT/$n.findings"
  # 1MB 초과
  big=0; while IFS= read -r p; do [ -f "$r/$p" ] || continue; s=$(stat -f %z "$r/$p"); [ "$s" -gt 1048576 ] && { echo "BIG $p $s" >> "$OUT/$n.findings"; big=$((big+1)); }; done < "$f"
  # gitleaks: 대상 파일만 복사해 스캔
  tmp=$(mktemp -d); rsync -a --files-from="$f" "$r/" "$tmp/" 2>/dev/null
  leaks=$("$GITLEAKS" dir --no-banner --redact --report-format json --report-path "$tmp.json" "$tmp" >/dev/null 2>&1; python3 -c "import json,sys;print(len(json.load(open(sys.argv[1]))))" "$tmp.json" 2>/dev/null || echo "?")
  [ "$leaks" != 0 ] && python3 -c "import json,sys;[print('LEAK',x['File'].replace(sys.argv[2]+'/',''),x['StartLine'],x['RuleID']) for x in json.load(open(sys.argv[1]))]" "$tmp.json" "$tmp" >> "$OUT/$n.findings" 2>/dev/null
  rm -rf "$tmp" "$tmp.json"
  note=""
  # doctree: 실제 Drive ID가 대상 파일에 들어갔는지
  if [ "$n" = freeride_doctree ] && [ -f "$r/config/content_category_map.yaml" ]; then
    ids=$(python3 - "$r" "$f" <<'PY'
import sys,re,pathlib
r,f=sys.argv[1],sys.argv[2]
ids=set(re.findall(r'file_id:\s*"?([A-Za-z0-9_-]{20,})',open(f"{r}/config/content_category_map.yaml").read()))
hit=0
for p in open(f).read().split("\n"):
    q=pathlib.Path(r,p)
    if p and q.is_file() and not q.is_symlink():
        try: t=q.read_text(errors="ignore")
        except Exception: continue
        hit+=sum(1 for i in ids if i in t)
print(hit)
PY
)
    note="DriveID=$ids"
  fi
  printf "%-58s %6s %6s %6s %6s %6s %s\n" "$r" "$cnt" "$pat" "$leaks" "$big" "$third" "$note"
done
echo "자세한 내용: $OUT/<이름>.findings"
