# upkeep

`~/githubs` 작업 환경을 유지·관리하는 저장소다. 계정·키·서명, 저장소 보관·재초기화·공개, 보안 기준선 같은 운영 작업의 카드와 스크립트, 절차를 한곳에 둔다.

**Private 전용 — 공개하지 않는다.** 운영 기록에는 키 지문, 로컬 환경 정보가 들어간다. 그래도 민감한 값(옛 신원 패턴, 키 목록)은 저장소에 넣지 않고 `local/`(무시 파일)에 둔다.

## 구성
- `backlog/`: 운영 카드와 draft (Backlog.md)
- `scripts/`: 유저가 직접 실행하는 운영 스크립트. 외부 상태를 바꾸는 작업(저장소 이전·생성·push, Touch ID 서명)은 에이전트가 아니라 유저가 실행한다
  - `reinit-preview.sh`, `reinit.sh`: 저장소 재초기화 미리보기와 실행
  - `archive-transfer.sh`: 보관 조직(coralstay-archive)으로 이전 + Archived
  - `identity/`: 신원·키 적용 스크립트와 셸 설정 조각
- `runbooks/`: 반복되는 운영 절차
- `local/`: 로컬 전용(커밋 안 함). `patterns.sh`(민감 패턴) 등

## 운영 카드 규칙
- 테스트로 확인할 수 없는 수용 기준은 `[수동 검증]`으로 시작하고, Notes에 `- 증거: <ID>#n — …` 줄(다시 확인할 수 있는 명령·해시·경로·URL 포함)을 남긴다
- 수동 항목이 있는 카드의 Done에는 사람 키로 서명한 `Manual-Verified: <ID>` 커밋이 필요하다(claude-code-agile-hooks)
- `scripts/`를 바꾸는 작업은 테스트를 먼저 쓴다(`tests/test_*`)

## friction: 운영하다 생긴 마찰 기록
CLI로 일하다 흐름이 막히거나, 도구가 예상과 다르게 동작하거나, 규칙이 새는 곳을 발견하면 그 자리에서 draft 1장을 만든다.
- 라벨: `friction` + 원인 도구 `tool:<이름>`(예: `tool:agile-hooks`, `tool:gh`, `tool:bash`)
- 내용: 증상, 재현, 원인 추정. 고치는 작업은 해당 도구 저장소의 카드로 만들고 여기서 연결한다

## 라이선스
AGPL-3.0-only. 전문은 `LICENSE`, 소스 파일 헤더의 `license` 필드도 같다.
