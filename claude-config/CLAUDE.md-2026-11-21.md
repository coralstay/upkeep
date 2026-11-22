<!-- CLAUDE-CODE-AGILE-HOOKS:BEGIN -->

## Backlog.md 워크플로 (claude-code-agile-hooks)

이 환경에는 backlog.md 태스크를 중심으로 한 워크플로 일부가 훅으로 강제되어 있습니다.
(원본: claude-code-agile-hooks 저장소. 이 로컬 환경은 유지보수성을 위해 `~/.claude/hooks/claude-code-agile-hooks/*.sh`를
`*.py`로 포팅해서 씀 + `~/.claude/settings.json`)

1. **브리핑**: 새 요청을 받으면 `backlog overview` / `backlog board view` / `backlog search`로
   현황을 먼저 파악한다.
2. **백로깅 (plan mode + draft 경유)**: `/backlogging` 스킬은 쓰지 않는다. plan mode에서
   계획을 프롬프트 출력으로 먼저 보여주고, 그게 승인되면 `backlog draft create`로 그 결과를
   draft에 담는다 — 아직 실제 task가 아니다. 유저가 그 draft를 확인하고 다시 승인하면
   `backlog draft promote <ID>`로 실제 task로 승격한다. 승격 직후 관련 의사결정은
   `backlog task edit <ID> --add-ref decision-N`으로, 관련 문서/외부링크는
   `--doc <path|url>`으로 반드시 연결한다 — 이렇게 해야 나중에 `task view` 한 번으로 필요한
   컨텍스트가 전부 로딩된다.
3. **검토**: 유저가 draft를 승인해 task로 승격되기 전까지는 실행을 시작하지 않는다.
4. **실행** (태스크당):
   - 시작 전 `backlog task view <ID> --plain`으로 반드시 먼저 읽는다 — 안 읽으면 훅이
     Edit/Write를 차단한다.
   - `backlog task edit <ID> -s "In Progress"` + `task/<ID>` 브랜치로 전환한다 — 훅이 In
     Progress 상태와 브랜치명을 확인한다.
   - AC 하나씩: 테스트(`<ID>#<n>` · `<ID>#B<k>` 표식) → 구현 → 커밋을 반복한다. 테스트 이름 · 표시
     이름 · 주석에 AC 표식 `<ID>#<n>`과, 그 AC에 묶인 비즈니스 규칙 표식 `<ID>#B<k>`를 넣는다. 비즈니스
     규칙은 카드 설명의 `## 비즈니스 규칙` 절에 `- B<k> (AC #<n>) <규칙>` 형식으로 적는다. 프로젝트 설정에
     `testFirst`(`sourceGlobs` · `testGlobs`)가 있으면, 다음 AC의 표식이 테스트에 없을 때 소스 편집을, 모든
     AC · 규칙 표식이 없을 때 `-s Done`을 훅이 막는다.
   - 프로젝트에 `.claude-code-agile-hooks.json`(옛 이름 `.claude-rails.json`도 읽음)의 `testCommand`가
     설정돼 있으면 테스트 실패 시 훅이 커밋을 막는다.
   - 변경사항을 커밋하지 않은 채 턴을 끝내려 하면 훅이 막는다 — 먼저 커밋부터 마무리한다.
   - AC 밖의 작업이 발견되면 조용히 범위를 넓히지 말고 유저에게 먼저 확인한다.
5. **완료**: 테스트 통과 로그 등 객관적 증거를 확인한 뒤에만 `--check-ac`/`--check-dod`를
   체크하고 `--final-summary`를 쓴 다음 `-s Done`으로 옮긴다. Done 상태 + final summary가
   없으면 훅이 push를 막는다.

세부 설계와 아직 훅으로 강제하지 못하는 부분(스코프 판단, AC 증거 검증 등)은 저장소
README.md를 참고.
<!-- CLAUDE-CODE-AGILE-HOOKS:END -->

## 서브에이전트 사용 원칙

실제 구현/수정 작업은 내가 직접(인라인으로) 처리하는 게 더 저렴하고 빠를 것 같아도,
기본적으로 서브에이전트(격리된 워크트리 등)에 위임하는 걸 기본값으로 삼는다. 토큰을
아끼겠다고 인라인으로 처리하는 걸 우선하지 않는다.

이유: 문맥을 이미 알고 있는 나 자신(또는 에이전트)도 그 익숙함 때문에 놓치는 맹점이 생길 수
있다. 서브에이전트를 새로 띄우면 코드베이스를 처음부터 다시 읽으면서 독립적인 시각으로
검증/피드백을 받을 수 있다는 게 핵심 가치이지, 단순히 병렬화나 컨텍스트 절약이 목적이 아니다.
이건 특정 프로젝트에 한정된 판단이 아니라 평소 기본 방침이다. 사소하고 위험이 낮은 변경까지
전부 서브에이전트로 돌리라는 뜻은 아니고, 실제 구현/버그 수정처럼 실수가 있을 수 있는
작업에는 이 원칙을 기본으로 적용한다.

## 다이어그램 표기 원칙

**DOT(Graphviz)로 먼저 쓰고, DOT으로 표현할 수 없는 것만 mermaid로 쓴다.**

- DOT으로 쓰는 것: 그래프·트리·DAG·플로우차트·파이프라인·클래스 다이어그램
  (`shape=record` 또는 HTML-like 레이블), C4류 경계 표현(`subgraph cluster_*`).
  Graphviz에 전용 셰이프가 없더라도 표기 규약을 정해 DOT으로 쓴다.
- mermaid로 쓰는 것: DOT에 대응물이 없는 것 — 시퀀스 다이어그램, 간트, 파이차트 등.

이유: 레이아웃 품질(특히 의존성 DAG)과 소스 분리다. `.dot`을 파일로 두면 diff·리뷰가
되고, 빌드 시점에 SVG로 렌더해 인라인하면 실행 시 자바스크립트가 필요 없다 —
문서가 가벼워지고 GitHub·PDF·아티팩트 어디서나 같게 보인다.

구현 규칙:
- 다이어그램 원본은 `diagrams/` 같은 별도 디렉토리에 두고, 렌더된 SVG는 생성물로 취급한다.
  문서 안의 `<svg>`를 직접 고치지 않는다.
- 색은 `.dot`에 센티넬 hex로 적고 빌드가 CSS 변수로 치환한다. 그래야 SVG 하나가 문서의
  라이트/다크 테마를 그대로 따라간다.
- 참고 구현: `coralstay-software-factory`의 `build-diagrams.py` + `diagrams/*.dot`
  (`<!--dot:이름-->` 마커 사이를 교체하는 방식).
