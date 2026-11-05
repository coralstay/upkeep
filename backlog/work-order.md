<!-- work-order-hash: b8e15ee4f2c0e241aa3b3e1c6767b0c0dc737a1d4a444aa622905c7fa131cce4 -->
# 작업 순서

`work_order.py`가 backlog/tasks의 의존(`dependencies`)으로 만든 파일이다 — 직접 고치지 말고 다시 생성한다. 같은 단계의 태스크는 병렬로, 단계는 위에서 아래로 순차로 진행한다. Done 태스크와 없는 태스크에 대한 의존은 충족된 것으로 본다.

| 단계 | ID | 제목 |
|---|---|---|
| 1 | TASK-1 | 중앙 점검 워크플로: 모든 public 저장소의 main-protect 규칙 자동 적용·복구 |
| 1 | TASK-2 | 공개 전 민감정보 정리: Drive ID·책 데이터·로컬/VM 정보·실명·옛 이메일 |
