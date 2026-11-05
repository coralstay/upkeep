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
