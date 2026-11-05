# Secretive 쇼트 리드: "communication with agent failed"

2026-11-06 확인. Secretive 4.0.0 에이전트가 SSH 에이전트 메시지를 길이 접두사(4바이트)만큼 모으지 않고, 한 번 읽은 덩어리를 메시지 하나로 처리한다. OpenSSH는 요청을 길이와 본문 두 번에 나눠 쓰므로, 두 쓰기 사이에 틈이 생기면 길이만 읽고 해석에 실패해 응답 없이 연결을 닫는다.

- 근거 코드(v4.0.0, 커밋 54e0d00): `SocketController.swift` L93-L100(`availableData`를 그대로 메시지로), `SSHAgentInputParser.swift` L24-L29, `AppDelegate.swift` L59-L66(해석 실패 → 응답 없이 close). OpenSSH `authfd.c` L147-L151(두 번 쓰기), `ssh-agent.c` L1831-L1841(올바른 받는 쪽 버퍼링)
- 대조 실험(같은 중계, 길이와 본문 사이 50ms): Secretive 0/5, OpenSSH ssh-agent 5/5. git commit에서는 upstream #577과 같은 출력(exit 128)
- 드러난 조건: 병렬 테스트의 CPU 부하, 에이전트 포워딩·VPN 지연. 부하가 높을 때 실제 커밋 서명도 실패할 수 있다
- upstream: https://github.com/maxgoedjen/secretive/issues/577 (#579). Secretive는 AI로 만든 코드를 받지 않는다(CONTRIBUTING.md). 코멘트 초안(`issue-577-comment.unsent.md`)은 유저 결정으로 올리지 않았다

## 재현
```sh
python3 secretive_short_read_repro.py <Secretive 공개키>.pub --runs 5 --delay 0.05 --control-ssh-agent
```
실행마다 Secretive 서명이 1번 일어난다(Notify 키면 알림이 쌓인다).
