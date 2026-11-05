<!-- work-order-hash: d09bc0eac692d5a1d03bfe12442563839883143dc7cbc5feba39b10586bc2e7c -->
# 작업 순서

`work_order.py`가 backlog/tasks의 의존(`dependencies`)으로 만든 파일이다 — 직접 고치지 말고 다시 생성한다. 같은 단계의 태스크는 병렬로, 단계는 위에서 아래로 순차로 진행한다. Done 태스크와 없는 태스크에 대한 의존은 충족된 것으로 본다.

| 단계 | ID | 제목 |
|---|---|---|
| 1 | TASK-1 | 중앙 점검 워크플로: 모든 public 저장소의 main-protect 규칙 자동 적용·복구 |
| 1 | TASK-2 | 공개 전 민감정보 정리: Drive ID·책 데이터·로컬/VM 정보·실명·옛 이메일 |
| 1 | TASK-3 | 신원·키·계정 보안 재설계: 사람 키(Secure Enclave)·AI 키(Claude·Antigravity)·이메일 비공개 |
| 2 | TASK-4 | 기존 이력 보관과 전 저장소 재초기화: coralstay-archive 이전 + 로컬 mirror + 새 첫 커밋 |
