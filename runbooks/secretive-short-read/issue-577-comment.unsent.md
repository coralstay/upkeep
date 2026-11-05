I think I've found a deterministic way to reproduce this, and some tests that narrow down where it happens.

> **Notice:** I used an AI assistant (Claude) for this. It read the source at `v4.0.0`, wrote the test relay below, and ran the tests on my machine. I reviewed the claims and edited the text before posting. This comment includes no code for Secretive. The relay is a test harness only, and the Swift and C references are links to the upstream source.

**Environment:** Secretive 4.0.0, macOS 27.0.1 (arm64), Apple's OpenSSH_10.3p1. The key is a Secure Enclave key with notify-only access, so no authentication prompt is involved.

### What the source suggests

OpenSSH sends each agent request as **two writes**: the 4-byte length first, then the body ([`authfd.c` L147-L151](https://github.com/openssh/openssh-portable/blob/2d98db98331803cbb820211b2fb0d31a6e71e58e/authfd.c#L147-L151)).

The agent treats whatever a single read returns as one complete message. It does not buffer until the length prefix is satisfied:

- [`SocketController.swift` L93-L100](https://github.com/maxgoedjen/secretive/blob/54e0d00d87e207377101b0ea6ddfa624cd1a1c16/Sources/Packages/Sources/SecretAgentKit/SocketController.swift#L93-L100): `availableData` is yielded as a message as-is.
- [`SSHAgentInputParser.swift` L24-L29](https://github.com/maxgoedjen/secretive/blob/54e0d00d87e207377101b0ea6ddfa624cd1a1c16/Sources/Packages/Sources/SSHProtocolKit/SSHAgentInputParser.swift#L24-L29): a 4-byte chunk throws `invalidData`. A chunk shorter than the declared length is parsed truncated.
- [`AppDelegate.swift` L59-L66](https://github.com/maxgoedjen/secretive/blob/54e0d00d87e207377101b0ea6ddfa624cd1a1c16/Sources/SecretAgent/AppDelegate.swift#L59-L66): on a parse error, the session is closed without a response. The client then reports `communication with agent failed`.

Usually the two writes arrive together and nothing goes wrong. When the client gets descheduled between them, the agent reads only the length and drops the connection. This can happen on a loaded machine. Higher latency, such as a forwarded agent or a VPN, widens the same gap, which would fit the observations earlier in this thread. It is a short read on a stream socket, so retries or load only change how often it shows up.

### Reproduction (single Python 3 script, stdlib only, plus stock OpenSSH)

The script runs a relay between `ssh-keygen` and the agent. The relay forwards bytes unchanged, except that it sends each client→agent message as two writes: the 4-byte length, then the body after `--delay` seconds. It compares that against a direct connection and a relay with no gap. With `--control-ssh-agent`, it runs the same relay against OpenSSH's own `ssh-agent` with a throwaway ed25519 key.

<details>
<summary><code>secretive_short_read_repro.py</code></summary>

```python
#!/usr/bin/env python3
"""Reproduce "communication with agent failed" from Secretive with the stock OpenSSH client.

A relay sits between ssh-keygen and the agent. It forwards bytes unchanged, except that
each client->agent message is sent as two writes: the 4-byte length, then the body after
--delay seconds. Results are compared against a relay with no gap and a direct connection.
With --control-ssh-agent the same relay is also run against OpenSSH's own ssh-agent.

Usage:
    python3 secretive_short_read_repro.py <secretive-public-key.pub> [--runs 5] [--delay 0.05]
                                          [--control-ssh-agent]

Python 3.8+ standard library only. Each run asks Secretive for one signature, so a
notification may appear per run.
"""
import argparse
import os
import platform
import socket
import struct
import subprocess
import tempfile
import threading
import time

DEFAULT_AGENT = os.path.expanduser(
    "~/Library/Containers/com.maxgoedjen.Secretive.SecretAgent/Data/socket.ssh"
)


def recv_exact(sock, n):
    buf = b""
    while len(buf) < n:
        chunk = sock.recv(n - len(buf))
        if not chunk:
            return None
        buf += chunk
    return buf


def shutdown(*socks):
    for s in socks:
        try:
            s.shutdown(socket.SHUT_RDWR)
        except OSError:
            pass


def client_to_agent(client, agent, delay):
    """Forward whole messages, writing the length and the body separately."""
    try:
        while True:
            header = recv_exact(client, 4)
            if header is None:
                break
            body = recv_exact(client, struct.unpack(">I", header)[0])
            if body is None:
                break
            agent.sendall(header)
            time.sleep(delay)
            agent.sendall(body)
    except OSError:
        pass
    finally:
        shutdown(client, agent)


def agent_to_client(agent, client):
    try:
        while True:
            data = agent.recv(65536)
            if not data:
                break
            client.sendall(data)
    except OSError:
        pass
    finally:
        shutdown(client)


def start_relay(listen_path, agent_path, delay):
    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(listen_path)
    server.listen(16)

    def serve():
        while True:
            client, _ = server.accept()
            agent = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
            agent.connect(agent_path)
            threading.Thread(target=client_to_agent, args=(client, agent, delay), daemon=True).start()
            threading.Thread(target=agent_to_client, args=(agent, client), daemon=True).start()

    threading.Thread(target=serve, daemon=True).start()
    return listen_path


def trial(label, sock_path, pubkey, msg, runs):
    ok, last_error = 0, ""
    env = dict(os.environ, SSH_AUTH_SOCK=sock_path)
    for _ in range(runs):
        sig = msg + ".sig"
        if os.path.exists(sig):
            os.unlink(sig)
        p = subprocess.run(
            ["ssh-keygen", "-Y", "sign", "-n", "file", "-f", pubkey, msg],
            env=env, capture_output=True, text=True,
        )
        if p.returncode == 0:
            ok += 1
        else:
            lines = [l for l in p.stderr.splitlines() if "agent" in l] or p.stderr.splitlines()
            last_error = lines[0] if lines else f"exit {p.returncode}"
    suffix = f"   last error: {last_error}" if last_error else ""
    print(f"{label:<46} {ok}/{runs} ok{suffix}")


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("pubkey", help="public key of a Secretive key (.pub)")
    ap.add_argument("--runs", type=int, default=5)
    ap.add_argument("--delay", type=float, default=0.05, help="gap between length and body, seconds")
    ap.add_argument("--agent", default=DEFAULT_AGENT, help="Secretive agent socket")
    ap.add_argument("--control-ssh-agent", action="store_true", help="also test OpenSSH's ssh-agent")
    args = ap.parse_args()

    ssh_version = subprocess.run(["ssh", "-V"], capture_output=True, text=True).stderr.strip()
    print(f"ssh: {ssh_version}")
    print(f"macOS: {platform.mac_ver()[0]} {platform.machine()}\n")

    with tempfile.TemporaryDirectory(prefix="secretive-repro-", dir="/tmp") as tmp:
        msg = os.path.join(tmp, "msg")
        with open(msg, "w") as f:
            f.write("test\n")
        control = start_relay(os.path.join(tmp, "control.sock"), args.agent, 0)
        split = start_relay(os.path.join(tmp, "split.sock"), args.agent, args.delay)
        trial("Secretive, direct", args.agent, args.pubkey, msg, args.runs)
        trial("Secretive, relay without gap", control, args.pubkey, msg, args.runs)
        trial(f"Secretive, relay with {args.delay}s gap", split, args.pubkey, msg, args.runs)

        if args.control_ssh_agent:
            agent_sock = os.path.join(tmp, "ssh-agent.sock")
            agent = subprocess.Popen(["ssh-agent", "-D", "-a", agent_sock], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            try:
                for _ in range(50):
                    if os.path.exists(agent_sock):
                        break
                    time.sleep(0.1)
                key = os.path.join(tmp, "control_key")
                subprocess.run(["ssh-keygen", "-q", "-t", "ed25519", "-N", "", "-f", key], check=True)
                subprocess.run(["ssh-add", "-q", key], env=dict(os.environ, SSH_AUTH_SOCK=agent_sock), check=True)
                relay = start_relay(os.path.join(tmp, "split-ssh-agent.sock"), agent_sock, args.delay)
                trial(f"OpenSSH ssh-agent, relay with {args.delay}s gap", relay, key + ".pub", msg, args.runs)
            finally:
                agent.terminate()


if __name__ == "__main__":
    main()
```

</details>

```sh
python3 secretive_short_read_repro.py <path-to-secretive-key>.pub --runs 5 --delay 0.05 --control-ssh-agent
```

Output on my machine:

```
ssh: OpenSSH_10.3p1, LibreSSL 3.3.6
macOS: 27.0.1 arm64

Secretive, direct                              5/5 ok
Secretive, relay without gap                   5/5 ok
Secretive, relay with 0.05s gap                0/5 ok   last error: Couldn't sign message (signer): communication with agent failed
OpenSSH ssh-agent, relay with 0.05s gap        5/5 ok
```

The same relay works against `ssh-agent`, so the split write pattern itself is valid. `ssh-agent` buffers until the whole message is in ([`ssh-agent.c` L1831-L1841](https://github.com/openssh/openssh-portable/blob/2d98db98331803cbb820211b2fb0d31a6e71e58e/ssh-agent.c#L1831-L1841)).

Other observations:

- `git commit -S` with `gpg.format=ssh` through the 0.05 s relay fails with the exact output from the original report (`... communication with agent failed?` / `fatal: failed to write commit object`, exit 128). It succeeds directly.
- `ssh-add -L` through the 0.05 s relay succeeds 10/10.
- With `--delay 0.2`, signing still fails 0/5, but the error becomes `No private key found for public key ...`. At that gap, the first request (request-identities) is already dropped, so `ssh-keygen` falls back to looking for a private key file.

Two details I can't fully explain from the code:

- A split **first** request on a fresh connection sometimes survives. It depends on when the pieces arrive after `connect()`. With the length at 0–20 ms and the body 50 ms later, 10/10 ok. With the length at 0 ms and the body 200 ms later, dropped. With the length at 100 ms or 300 ms and the body 50 ms later, 10/10 dropped. I'm guessing the agent is still setting up the session for the first tens of milliseconds and reads later, but I haven't verified that.
- A split **second** request on the same connection fails 10/10 with a 50 ms gap. I only tested that gap. `ssh-keygen -Y sign` sends request-identities first and then the sign request, so the sign request is always the vulnerable one. That's why `ssh-add -L` alone doesn't reproduce it.

The agent's debug log agrees. For 64 concurrent sign requests with 4 failures, I see 64 `accepted connection`, 128 `yielded data`, 60 `received request of type SSH_AGENTC_SIGN_REQUEST`, and exactly 4 `Session closed.` I never see a signing or Secure Enclave error.

Happy to rerun these tests against a build if that's useful.
