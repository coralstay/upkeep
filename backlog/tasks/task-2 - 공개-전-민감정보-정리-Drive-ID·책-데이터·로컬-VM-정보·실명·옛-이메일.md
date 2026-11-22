---
id: TASK-2
title: '공개 전 민감정보 정리: Drive ID·책 데이터·로컬/VM 정보·실명·옛 이메일'
status: To Do
assignee: []
created_date: '2026-11-05T20:01:00Z'
updated_date: '2026-11-22T12:03:00Z'
labels:
  - privacy
  - public
dependencies: []
references:
  - source-header TASK-18(이관 원본)
documentation:
  - ~/.claude/plans/giggly-kindling-snowglobe.md
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
이관(2026-11-06): source-header TASK-18에서 옮겼다. 원래 카드는 source-header backlog/archive에 있고, 옛 커밋 해시는 coralstay-archive 보관본에서 확인한다. 이 저장소의 새 ID는 TASK-2.

## 배경
TASK-16(라이선스·저작권 정리)에 이어, 공개 전 노출 위험 감사(2026-11-01, Explore 서브에이전트, 18개 저장소 HEAD+이력)에서 나온 필수 항목을 정리한다.
유저 결정(2026-11-01): 실명은 coralstay로, 옛 이메일과 계정 연결 문장은 모두 삭제. doctree는 다른 4곳처럼 재초기화. dev-toolchain(이미 public)의 커밋 작성자 메타데이터는 그대로 두고(해시 406개 변경·잠금 해제 비용 대비 효과 낮음) 파일 내용의 언급만 지운다.
.env·OAuth·키·tfstate는 이력 어디에도 없었다. 세션 트레일러(Claude-Session 등)·.claude/plans 경로·공개 연락처는 2026-11-02 유저 결정으로 이메일을 모두 지우고 GitHub Issue 안내로 바꾼다(이메일 비공개).

## 대상
| 저장소 | 항목 | 조치 |
|---|---|---|
| doctree (private) | 개인 Drive file_id 234개·서재 목록(config/content_category_map.yaml, 이력의 config/categories.yaml), README·코드·테스트의 실제 ID | map을 .gitignore로 빼고 example 파일만 두기, 실제 ID를 가짜 ID로, 재초기화 + GitHub 재생성. Drive 공유 설정 점검은 유저 |
| coding-style (private, 커밋 1) | scripts/generate_unabbreviated_tocs.py·patch_missing_chapters.py·ocr_cache.py·ocr_pdf.swift(책 목차·OCR 도구), AGENTS.md의 file:///Users 링크 | .gitignore로 빼고 상대 링크로, 새 이력(amend 또는 재초기화) + force 대신 GitHub 재생성 여부는 커밋 1개라 재초기화로 통일 |
| handcrafted-cpp (private, 커밋 1) | scripts/generate_practice-01/02/03.py의 큰돌 교안 문제·페이지·입출력 예제, PRACTICE_GUIDE.md의 file:///Users 링크, README의 교안 PDF 보유 문구 | 생성기의 데이터 부분 분리·제외, 링크·문구 정리, 재초기화 |
| databases (private, 커밋 1) | file:///Users 링크 22곳, 도서 PDF 파일명 | 상대 경로·일반화, 재초기화 |
| ebpf (private, 커밋 6) | 로컬 경로 약 600곳, VM UUID·IP·MAC·SSH 별칭, Antigravity 세션 ID·에이전트 산출물(archive/), Makefile·vmtest.sh의 ssh 호스트 | archive/ 정리, 환경값 변수화, 산출물 경로 정리, 재초기화 + GitHub 재생성 |
| source-header (private) | 실명(테스트), 옛 이메일(README 예시·테스트·task-3), 계정 연결 문장, test 상수의 /Users 경로 | coralstay·@example.com으로, 문장 삭제, 이력 재작성(재초기화) + GitHub 재생성 |
| central-docs-collector (private) | 헤더 실명, 테스트의 UUID | coralstay로, 가짜 UUID로, 재초기화 + GitHub 재생성 |
| dev-toolchain (public) | task-175 노트·draft-11 PATH 덤프의 옛 이메일·로컬 홈 경로 | HEAD 파일만 수정(PR) |
| agent-orchestrator (public) | 테스트 픽스처 /Users 경로 5개, 실제 session_id | 가짜 값으로(PR), 테스트 통과 확인 |
| coding-agent-git-commit-tool (public) | gf-93의 claude.ai 세션 URL | 삭제(PR) |
<!-- SECTION:DESCRIPTION:END -->

## Acceptance Criteria
<!-- AC:BEGIN -->
- [ ] #1 [수동 검증] 대상 저장소 전체를 ~/githubs-backup/2026-11-01/에 git bundle로 백업하고 verify가 통과한다
- [ ] #2 [수동 검증] doctree: 실제 Drive ID와 서재 목록이 HEAD·새 이력에 없고(map은 .gitignore + example 파일), 테스트가 통과하며, 재초기화·GitHub 재생성 스크립트가 준비된다
- [ ] #3 [수동 검증] coding-style·handcrafted-cpp·databases: 책 목차·교안 데이터와 file:///Users 링크가 HEAD·새 이력에 없고 재초기화된다(로컬 생성용 데이터는 무시 파일로 남김)
- [ ] #4 [수동 검증] ebpf: /Users 경로·VM UUID·IP·MAC·SSH 별칭·Antigravity 세션 ID가 HEAD·새 이력에 없고 검증 스위트가 통과하며 재초기화된다
- [ ] #5 [수동 검증] source-header·central-docs-collector: 실명과 옛 이메일·계정 연결 문장이 HEAD·새 이력에 없고 테스트가 통과하며 재초기화된다
- [ ] #6 [수동 검증] dev-toolchain·agent-orchestrator·coding-agent-git-commit-tool: 해당 HEAD 파일을 고치는 PR이 준비되고(테스트 통과) 병합된다
- [ ] #7 [수동 검증] 18개 저장소 전체에 패턴 재검사와 gitleaks를 다시 돌려, 남은 것이 유지 허용 항목(세션 트레일러·.claude/plans·공개 연락처·dev-toolchain 커밋 메타데이터)뿐임을 Notes에 기록한다
<!-- AC:END -->

## Definition of Done
<!-- DOD:BEGIN -->
- [ ] #1 [수동 검증] 백업 verify 로그와 재검사 결과를 Implementation Notes에 첨부
- [ ] #2 [수동 검증] 재초기화 저장소마다 테스트·검증 스위트 통과
- [ ] #3 [수동 검증] 로컬에서 뺀 원본 데이터가 지워지지 않고 남아 있음을 확인
<!-- DOD:END -->

## Implementation Plan

<!-- SECTION:PLAN:BEGIN -->
### Subjective
유저가 공개 전 민감정보 점검을 요청했고(2026-11-01), 감사 결과에 대해 실명→coralstay, 옛 이메일 전부 삭제, doctree 재초기화, dev-toolchain 커밋 메타데이터는 유지로 정했다.

### Objective
감사 결과는 Description 표. 대상 private 저장소는 모두 PR·이슈가 0이거나(재초기화 4곳과 같은 조건) 재초기화를 유저가 승인했다(doctree, PR 7). public 저장소는 main-protect 때문에 PR로만 반영된다. 훅이 gh repo delete와 main push를 막으므로 GitHub 삭제·재생성·push는 유저가 스크립트로 실행한다.

### Assessment
TASK-16과 같은 절차(백업 → HEAD 정리 → 추적 대상 미리보기 → 재초기화 → gitleaks·패턴 재검사 → 유저 스크립트)를 쓴다. 지운 값은 로컬에 남긴다(.gitignore). public 저장소는 HEAD만 고친다. 생성기에서 뺀 데이터는 별도 무시 파일로 옮겨 로컬 생성은 계속 되게 한다.

### Plan
1. 대상 전체 bundle 백업(~/githubs-backup/2026-11-01/) + verify
2. private 7곳 HEAD 정리 → 재초기화
3. public 3곳 HEAD 정리 → PR
4. 패턴 재검사(로컬 홈 경로, 옛 이메일, 실명, Drive ID 패턴, 192.168., VM UUID, brain ID)와 gitleaks → Notes
5. GitHub 재생성·push·PR 스크립트를 유저가 실행
<!-- SECTION:PLAN:END -->

## Implementation Notes

<!-- SECTION:NOTES:BEGIN -->
2026-11-01 범위 조정: 유저가 새 출발 계획(전 저장소 보관 후 재초기화, 계획 파일 참조)을 승인. 이 카드는 1단계(현재 파일 민감정보 정리, 옛 계정명·옛 이메일 파일 언급 포함)까지만 맡고, 재초기화·GitHub 재생성·public PR은 새 카드(DRAFT-2 보관·재초기화)로 넘긴다. public 저장소도 재초기화되므로 PR 없이 HEAD만 고친다. 진행: doctree 완료(282 passed), 나머지는 서브에이전트 진행 중.

- 2026-11-22 TASK-8 분류: 남은 일(AC 0/7). 11-12 공개 때 유저가 알고 공개한 항목(키 이름·VM·로컬 경로·Drive 링크·책 내용)과 겹치므로 남은 범위는 6번 공개 작업 때 다시 판단
<!-- SECTION:NOTES:END -->
