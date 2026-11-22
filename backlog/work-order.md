<!-- work-order-hash: 180dd34ed935b46b959de04684b2690adb68ecbe0e07cfe80ce9b93a0afd549a -->
# 작업 순서

`work_order.py`가 backlog/tasks의 의존(`dependencies`)으로 만든 파일이다 — 직접 고치지 말고 다시 생성한다. 같은 단계의 태스크는 병렬로, 단계는 위에서 아래로 순차로 진행한다. Done 태스크와 없는 태스크에 대한 의존은 충족된 것으로 본다.

| 단계 | ID | 제목 |
|---|---|---|
| 1 | TASK-7 | ~/.claude/CLAUDE.md 를 claude-config/ 에 기록으로 남기고 지운다 |
