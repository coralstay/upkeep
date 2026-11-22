---
id: DRAFT-14
title: toy-project _vm.sh가 VM 접속 설정을 다시 만들며 UseKeychain을 빼고 새 키를 암호 없이 만든다
status: Draft
assignee: []
created_date: '2026-11-05T20:05:00Z'
labels:
  - friction
  - tool:toy-project
dependencies: []
---

## Description

<!-- SECTION:DESCRIPTION:BEGIN -->
증상: protect-vm-key.sh로 rocky-dev 키에 암호·UseKeychain을 걸어도 scripts/_vm.sh가 config.d/rocky-dev를 재생성하면 사라짐. 고칠 곳: toy-project DRAFT-24
<!-- SECTION:DESCRIPTION:END -->
