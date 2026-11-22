<!-- work-order-hash: 708fb9831984f7a93fd34c67264716f277d8b50e0f291182891bbcf9b34e9e1e -->
# 작업 순서

`work_order.py`가 backlog/tasks의 의존(`dependencies`)으로 만든 파일이다 — 직접 고치지 말고 다시 생성한다. 같은 단계의 태스크는 병렬로, 단계는 위에서 아래로 순차로 진행한다. Done 태스크와 없는 태스크에 대한 의존은 충족된 것으로 본다.

| 단계 | ID | 제목 |
|---|---|---|
| 1 | TASK-1 | 중앙 점검 워크플로: 모든 public 저장소의 main-protect 규칙 자동 적용·복구 |
| 1 | TASK-2 | 공개 전 민감정보 정리: Drive ID·책 데이터·로컬/VM 정보·실명·옛 이메일 |
| 1 | TASK-3 | 신원·키·계정 보안 재설계: 사람 키(Secure Enclave)·AI 키(Claude·Antigravity)·이메일 비공개 |
| 1 | TASK-8 | 미병합 브랜치 task/TASK-1(운영 카드 TASK-1~6·runbooks·draft 18장) 병합과 카드 상태 정리 |
| 2 | TASK-4 | 기존 이력 보관과 전 저장소 재초기화: coralstay-archive 이전 + 로컬 mirror + 새 첫 커밋 |
| 2 | TASK-5 | 보안 기준선 점검으로 확장: 비밀값 스캔·push 보호·Dependabot·Actions 권한·SECURITY.md |
| 3 | TASK-6 | 저장소별 공개 전환: 재검사·기준선 확인 후 하나씩 |
