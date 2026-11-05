---
id: DRAFT-1
title: '공개 전 민감정보 정리: Drive ID·책 데이터·로컬/VM 정보·실명·옛 이메일'
status: Draft
assignee: []
created_date: '2026-11-05T20:01:00Z'
labels:
  - privacy
  - public
dependencies: []
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
