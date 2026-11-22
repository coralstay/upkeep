# 노트: 소켓 · 프레이밍 · Secretive 서명 경로 (2026-11-06)

agile-hooks 커밋이 테스트 간헐 실패로 막힌 일을 따라가다 정리한 내용. 결함 기록은 [README.md](README.md), 재현은 `secretive_short_read_repro.py`, 해결 기법 예제는 `framing_demo.c`.

## 1. 무엇이 일어났나
- agile-hooks는 Claude가 커밋할 때마다 전체 테스트(2,450개, `pytest -n auto`)를 돌린다(TASK-43 도그푸딩, `pre_commit_check`).
- 테스트가 임시 저장소에서 `git commit`을 할 때 사용자 설정(전역 `commit.gpgsign=true`, Claude env의 AI 서명 키)을 물려받아, 실행마다 Secretive에 실제 서명을 약 60번 요청했다.
- Secretive가 그중 1~3번을 `communication with agent failed`로 실패시켜 커밋이 절반쯤 막혔다. 같은 증상이 테스트 없이 실제 rebase 서명에서도 한 번 났다.
- 대응: 테스트 쪽은 agile-hooks TASK-74(테스트 git 격리, `hooks/conftest.py`)로 서명 요청 자체를 없앴다. Secretive 결함은 #577에 원인 · 재현 코멘트(`issue-577-comment.md`)로 알린다.

## 2. 이름 붙이기: race가 아니라 쇼트 리드
- 처음에 "동시성 문제 / race"라고 불렀다가 정정했다. race는 여러 주체가 공유 상태를 두고 순서에 따라 결과가 달라지는 버그다. 여기는 1:1 연결 하나에서도 생긴다.
- 정확한 이름: **스트림 소켓에서 메시지 경계(framing)를 처리하지 않는 쇼트 리드**. 부하 · 지연은 원인이 아니라 드러나는 조건이다.
- 교훈: 조건과 원인을 구분하고, 완화책을 해결책이라 부르지 않는다. 코드를 읽고 실측한 뒤 이름을 붙인다.

## 3. 소켓 기초
- 유닉스 도메인 소켓(`AF_UNIX`): 같은 컴퓨터 안의 프로세스 통신. 주소가 파일 경로(`ls -l`의 `s`, 크기 0). 데이터는 디스크가 아니라 커널 버퍼를 지난다. BSD 기원이라 macOS에도 있다.
- 파일처럼 fd로 `read`/`write`/`close`하지만 파일이 아니다: 읽으면 사라지고, 상대 프로세스가 있고, `read`는 지금 와 있는 만큼만 준다.
- 서버: `socket → bind → listen → accept`(연결마다 새 fd). 클라이언트: `socket → connect`. 공부는 보통 서버부터(주소를 먼저 만들어 기다리므로).
- 경로 칸 `sun_path`는 고정 크기(리눅스 108, macOS 104). 긴 경로는 못 쓴다.
- 소켓 종류: `SOCK_STREAM`(경계 없음), `SOCK_DGRAM`(경계 있음), `SOCK_SEQPACKET`(연결형 + 경계 있음, 리눅스만 — macOS `unix(4)`는 STREAM · DGRAM만). man-pages `unix(7)` 예제가 `read` 한 번 = 메시지 하나로 짤 수 있는 건 SEQPACKET이라서다. SSH 에이전트는 STREAM.

## 4. read와 버퍼 — 표현 정리
- 버퍼(그릇)는 크기 고정. `read(fd, buf, sizeof buf)`는 **버퍼 크기만큼** 받을 수 있고, 실제로 들어온 양은 반환값 `r`(그보다 작을 수 있음).
- man-pages 원문: "read() attempts to read **up to** count bytes … into the buffer starting at buf", "It is **not an error** if this number is smaller than the number of bytes requested". recv(2): "return any data available, up to the requested amount, rather than waiting for receipt of the full amount requested". 영어의 "up to"는 버퍼가 아니라 읽는 양에 붙는다.
- `r == 0` = 상대가 닫음(EOF), `-1` = 오류. 상대가 닫았는데 쓰면 `EPIPE`(Broken pipe).
- `read`는 내용을 보지 않는다. `'\0'` 같은 끝 문자는 응용 프로그램의 약속일 뿐.

## 5. 프레이밍 — 스트림에서 경계 만들기
- 보낸 횟수와 받는 횟수는 무관하다(두 번 쓴 게 한 번에, 한 번 쓴 게 나뉘어 올 수 있다).
- 방식 둘: **구분자**(`'\0'`, 줄바꿈 — HTTP 헤더, Redis) / **길이 접두사**(SSH 에이전트, TLS).
- 받는 쪽의 공통 뼈대: ① 받은 바이트를 쌓기 ② 경계마다 메시지 꺼내기(반복) ③ 경계 뒤 남은 조각 보존 ④ 길이 · 크기 상한.
- `unix(7)` 예제를 STREAM으로 바꾸면: 붙어 오면 `atoi`가 첫 `'\0'`에서 멈춰 뒤 메시지가 버려지고(교착), 끊겨 오면 `"EN"` / `"D"`로 `END`를 영영 못 알아본다. 해결 = 널에서 탈출하지 말고 경계로 쓰고 나머지를 보존.
- 경계를 한 번 잃으면 본문 바이트를 헤더로 착각한다(desync, `framing_demo.c` B: `_REQ`를 길이 1599227217로 읽음). 요청 스머글링 계열 공격의 원리.
- 링버퍼도 되지만 필요 없다: 메시지가 작고 드물다. 핵심은 쌓기 · 다시 읽기 · 보존이지 자료구조가 아니다. Java `ByteBuffer`의 `flip()` / `compact()`가 이 패턴을 위한 것.

## 6. 버퍼 오버플로와 이번 일
- `char buf[12]; read(fd, buf, 100)`처럼 요청량이 그릇보다 크면 쓰기 넘침 → 스택 덮어쓰기 공격. `read`에 항상 `sizeof(buf)`.
- 읽기 넘침 대비: 마지막 칸 `'\0'` 강제, `strncmp`의 n.
- `sprintf`는 크기를 모른다 → `snprintf(buf, sizeof buf, …)`: `'\0'` 포함 size바이트까지만 쓰고, 반환값은 공간이 충분했다면 썼을 글자 수(`>= size`면 잘림). man `sprintf(3)`: "Use snprintf() … instead".
- 이번 결함은 오버플로가 아니다: Swift `Data`는 범위 검사, 해석기는 `min(길이, 받은 양)`, 실패하면 서명 없이 닫음(fail-closed). 다만 고칠 때 길이 상한이 없으면 "길이 4GB" 하나로 메모리 고갈(서비스 거부) — OpenSSH `AGENT_MAX_LEN`.
- 진짜 보안 경계는 따로: 이 소켓에 접속하는 같은 사용자의 아무 프로세스나 Notify(AI) 키로 승인 없이 서명할 수 있다(TASK-19에서 알고 선택). 알림은 사후 기록으로 약하다(아래 9).

## 7. OpenSSH는 왜 길이와 본문을 따로 쓰나
- `authfd.c` `ssh_request_reply()` L147-L151. blame: 2000(942da039d) · 2015(141efe495)는 이동 · 정리일 뿐 이유 기록 없음.
- 1999년 최초 OpenSSH(`d4a8b7e34`, 원작 Tatu Ylönen 1995)를 보면: 길이를 미리 아는 고정 메시지(키 목록 요청)는 `write(fd, msg, 5)` **한 번에**, 버퍼에 쌓아 만든 가변 메시지는 다 쌓은 뒤에야 길이를 알고 버퍼 앞에 자리가 없어 **길이 · 본문 따로**. → 무게 · 프레임 때문이 아니라 복사를 피한 구현 편의로 읽힌다(작성자 설명은 없음).
- 유닉스 소켓엔 MTU · 프레임이 없고, TCP였어도 커널이 MSS로 자른다. 4바이트를 따로 쓰면 오히려 작은 세그먼트 · Nagle 지연. 네트워크 코드는 보통 `writev`.
- 같은 1995 코드의 받는 쪽은 처음부터 `while (len > 0)`로 끝까지 모은다.

## 8. Secretive 구조와 결함 위치 (v4.0.0, 커밋 54e0d00)
- 앱: Secretive.app(키 관리 UI), SecretAgent.app(로그인 항목, 소켓 서버), XPC 서비스(SecretAgentInputParser — 입력 해석 격리, HostsfileReader, CertificateParser, Updater). 키는 Secure Enclave(ECDSA P-256만) 또는 스마트카드. 정책: Touch ID 요구 / Notify.
- 경로: `SocketController`/`Session`(메인 액터, FileHandle 알림) → XPC 해석기 → `Agent.handle`(witness = 알림 · 인증) → Secure Enclave 서명 → `session.write`.
- 결함: `SocketController.swift` L92-L100 `availableData` 한 번 = 메시지 하나, 읽기 재예약은 `write()` L110에서만 → 쇼트 리드 · 남은 조각 미처리 · 두 메시지 중 둘째 유실. `AppDelegate.swift` L59-L66 해석 실패 시 응답 없이 close.
- 서명 요청이 특히 취약: 같은 연결의 두 번째 메시지라, 첫 응답 직후 이미 읽기가 예약돼 길이 4바이트 도착 즉시 깬다.
- 이력: #765(2025-11), #769(2025-12, "eliminate race condition" — 알림 놓침 순서 수정)로 근처를 고쳤지만 "덩어리 = 메시지" 전제는 그대로. #577(2024-12~), #579 열림, 메인테이너 무응답.
- 기여 정책: AI/LLM으로 생성한 코드 불가(CONTRIBUTING.md, #799 2026-05). 구현 전 `proposed` 이슈 권장.

## 9. 우리 서명 경로 (실측)
- `git commit -S` → git이 커밋 본문을 임시 파일로 → `ssh-keygen -Y sign -n git -f <공개키.pub> <임시파일>`(`GIT_TRACE`로 확인) → `SSH_AUTH_SOCK` 소켓 connect → ① REQUEST_IDENTITIES ② SIGN_REQUEST(파일 SHA-512를 SSHSIG로 포장, 길이 · 본문 두 번 write) → Secretive가 정책 확인(사람 키 Touch ID / AI 키 알림) → Secure Enclave 서명 → `.sig` → git이 커밋에 `gpgsig` 헤더로. 약 0.55초.
- `~/.ssh`엔 공개키만 있고 비밀키 파일 0개. 키는 Secretive 앱에서 만든 것.
- 검증은 반대 방향이고 에이전트를 안 쓴다: `ssh-keygen -Y find-principals` / `-Y verify` + `allowed_signers` → `%G?` `%GK` `%GS`. TASK-72가 `%GK` 지문 고정 + `allowedSignersFile` · `gpg.ssh.program` 등을 `-c`로 고정.
- 알림(usernoted 로그): `.alert .lockScreen .notificationCenter`로 전달되지만 같은 식별자 이전 알림을 지우고 3일 뒤 만료 → 감사 기록으로는 약함. `authorizationStatus: Denied`인데 전달되는 불안정한 상태.
- macOS 27 관련 열린 이슈: #839(다른 앱 컨테이너 접근 기본 거부 — 우리 소켓 · 공개키 경로가 그 컨테이너), #849(Notify 알림 안 뜸 — 이 Mac은 뜸), #852(tmp에 아이콘 사본 누적 — 이 Mac 해당 여부 미확인, 컨테이너 접근이 막혀 `du`가 조용히 비었음), #858(인증 취소 시 크래시).

## 10. 관측 도구
- macOS: `/usr/bin/log stream --level debug --predicate 'subsystem == "com.maxgoedjen.secretive.secretagent"'`(zsh에선 `log`가 내장 명령이라 절대 경로), `fs_usage`(sudo, 시스템 콜 바이트 수), DTrace(SIP로 시스템 바이너리 불가).
- 리눅스: eBPF(kray). macOS엔 eBPF가 없어 이번 문제엔 직접 못 씀. 아이디어: kray에 `AF_UNIX`/TCP 쇼트 리드 탐지 시나리오(Antigravity 작업 끝난 뒤 draft).

## 11. 선택지와 결정
- A 그대로 / B 서명 재시도 래퍼 / C Secretive 직접 빌드(키가 앱 신원에 묶여 기존 키를 못 쓸 가능성 — 미확인) / D 에이전트 교체 / E upstream 대기 / F 모아서 한 번에 보내는 중계(원인 회피, 대신 인증 경로에 상주 단일 고장점).
- 결정(2026-11-06): **#577에 원인 · 재현 · C 기법 예제를 이슈 코멘트로**(AI 사용 공개, Swift 패치 없음). PR은 Swift를 익혀 직접 쓸 때(장기 목표).
- 개발자 관점: AI 코드를 붙여 넣는 게 아니라 이해 · 판단 · 검증 · 책임이 개발. AI는 설명 · 리뷰 · 검증에.
