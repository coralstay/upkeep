# claude-config

Claude Code 사용자 설정(`~/.claude/`)에 있던 지시문의 **기록**이다. 지금은 적용되지 않는다.

## 파일

| 파일 | 원래 위치 | 기간 | 지금 상태 |
| --- | --- | --- | --- |
| `CLAUDE.md-2026-11-21.md` | `~/.claude/CLAUDE.md` | ~2026-11-21 | 기록만. 원본과 바이트까지 같다(손대지 않음) |

`CLAUDE.md-2026-11-21.md`는 2026-11-21에 워크플로 블록을 지우기 직전의 `~/.claude/CLAUDE.md` 전문이다. 세 절로 되어 있다.

| 절 | 줄 | 어떻게 됐나 |
| --- | --- | --- |
| Backlog.md 워크플로 (`CLAUDE-CODE-AGILE-HOOKS` 마커 블록) | 1~39 | claude-code-agile-hooks TASK-76에서 대체됐다. 이제 훅과 함께 설치되는 짧은 안내문(`hooks/workflow_guide.md`)을 `session_start` 훅이 매 세션 맥락으로 넣는다. 2026-11-21에 이 블록을 지웠다 |
| 서브에이전트 사용 원칙 | 41~52 | 기록만 한다(유저 결정 2026-11-22). 더는 Claude에게 읽히지 않는다 |
| 다이어그램 표기 원칙 | 54~73 | 기록만 한다(유저 결정 2026-11-22). 더는 Claude에게 읽히지 않는다 |

`~/.claude/CLAUDE.md`는 이 기록을 커밋한 뒤 지웠다(upkeep TASK-7).

## 다시 적용하려면

원하는 절만 `~/.claude/CLAUDE.md`에 옮겨 적으면 다음 세션부터 Claude가 읽는다. 워크플로 블록은 옮기지 않는다 —
그 역할은 claude-code-agile-hooks의 안내문이 맡고, 옮기면 훅과 판이 다시 어긋난다.

```sh
# 예: 서브에이전트 · 다이어그램 원칙만 되살리기
sed -n '41,73p' claude-config/CLAUDE.md-2026-11-21.md > ~/.claude/CLAUDE.md
```
