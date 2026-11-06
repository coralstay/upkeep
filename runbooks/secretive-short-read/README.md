# Secretive 쇼트 리드: "communication with agent failed"

2026-11-06 확인. Secretive 4.0.0 에이전트가 SSH 에이전트 메시지를 길이 접두사(4바이트)만큼 모으지 않고, 한 번 읽은 덩어리를 메시지 하나로 처리한다. OpenSSH는 요청을 길이와 본문 두 번에 나눠 쓰므로, 두 쓰기 사이에 틈이 생기면 길이만 읽고 해석에 실패해 응답 없이 연결을 닫는다.

- 근거 코드(v4.0.0, 커밋 54e0d00): `SocketController.swift` L93-L100(`availableData`를 그대로 메시지로), `SSHAgentInputParser.swift` L24-L29, `AppDelegate.swift` L59-L66(해석 실패 → 응답 없이 close). OpenSSH `authfd.c` L147-L151(두 번 쓰기), `ssh-agent.c` L1831-L1841(올바른 받는 쪽 버퍼링)
- 대조 실험(같은 중계, 길이와 본문 사이 50ms): Secretive 0/5, OpenSSH ssh-agent 5/5. git commit에서는 upstream #577과 같은 출력(exit 128)
- 드러난 조건: 병렬 테스트의 CPU 부하, 에이전트 포워딩·VPN 지연. 부하가 높을 때 실제 커밋 서명도 실패할 수 있다
- upstream: https://github.com/maxgoedjen/secretive/issues/577 (#579). Secretive는 AI로 만든 코드를 받지 않는다(CONTRIBUTING.md). 원인 · 재현 · C 기법 예제를 정리한 코멘트 `issue-577-comment.md`를 #577에 올린다(2026-11-06 유저 결정, 3번안). 처음 초안은 올리지 않았다

## 재현
```sh
python3 secretive_short_read_repro.py <Secretive 공개키>.pub --runs 5 --delay 0.05 --control-ssh-agent
```
실행마다 Secretive 서명이 1번 일어난다(Notify 키면 알림이 쌓인다).

## 이 폴더
- `NOTES.md`: 소켓 기초 · read와 버퍼 · 프레이밍 · 오버플로 · OpenSSH 두 번 쓰기의 이유 · Secretive 구조 · 우리 서명 경로 · 선택지와 결정
- `framing_demo.c`: 같은 바이트 패턴을 'read 한 번 = 메시지'와 '쌓기 · 꺼내기 · 보존' 서버에 보내 비교(`cc -Wall -Wextra -O2 -o framing_demo framing_demo.c && ./framing_demo`)
- `secretive_short_read_repro.py`: 실제 ssh-keygen · Secretive 사이 중계로 재현
- `issue-577-comment.md`: #577 코멘트
