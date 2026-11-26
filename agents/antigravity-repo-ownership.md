---
trigger: always_on
description: ~/githubs 저장소별 담당 에이전트 규칙 — antigravity 담당이 아닌 저장소는 편집하지 않는다
---
# 저장소별 담당 (coralstay)

`~/githubs` 아래 저장소는 저장소마다 담당 에이전트가 하나 있다. 담당은 Claude Code · Antigravity · 다른 Claude 세션 중 하나이고, 같은 저장소를 두 에이전트가 함께 고치지 않는다.

- 작업을 시작하기 전에 대상 저장소의 담당을 확인한다: `dev-toolchain workspace owner <경로>`
  - 담당 표의 원본은 dev-toolchain `workspace/repos.tsv`의 담당 열이다. 이 규칙에는 표를 옮겨 적지 않는다.
- 결과가 `antigravity`면 그 저장소에서 자유롭게 일한다.
- 결과가 `antigravity`가 아니면(`claude`, `claude-other`) 편집 · 커밋하지 않고 읽기 · 보고만 한다. 고칠 것이 보이면 유저에게 알린다.
- 결과가 `unknown`이면(목록에 없는 저장소) 손대기 전에 유저에게 묻는다.
- 커밋은 자기 키(ai-antigravity)로 서명한다. 다른 에이전트의 키나 사람 키(human)로 서명하지 않는다.
