I think one cause of this is a short read in the agent's socket handling. Below are the code path, a deterministic reproduction, and a control against OpenSSH's own `ssh-agent`.

> **Notice:** I worked through this with an AI assistant (Claude). It read the source and ran the tests on my machine. I reviewed every claim before posting. There is no patch for Secretive here. The C snippet at the end only illustrates the framing technique; it is not proposed code.

**Environment:** Secretive 4.0.0, macOS 27.0.1 (arm64), Apple's OpenSSH_10.3p1. The key is a Secure Enclave key with notify-only access, so no authentication prompt is involved.

### 1. What the client sends

OpenSSH writes every agent request in **two `write()` calls**: first the 4-byte length, then the body ([`authfd.c` L147-L151](https://github.com/openssh/openssh-portable/blob/2d98db98331803cbb820211b2fb0d31a6e71e58e/authfd.c#L147-L151)):

```c
/* Send the length and then the packet to the agent. */
if (atomicio(vwrite, sock, buf, 4) != 4 ||
    atomicio(vwrite, sock, sshbuf_mutable_ptr(request),
    sshbuf_len(request)) != sshbuf_len(request))
        return SSH_ERR_AGENT_COMMUNICATION;
```

The pattern has been there since at least the first OpenSSH import in 1999. That version wrote fixed-size messages in one `write()` and only split messages whose length was known after they were built. The split is legal on a stream socket. The receiver is expected to reassemble.

### 2. What a stream socket guarantees

The agent socket is `SOCK_STREAM` ([`SocketController.swift` L143](https://github.com/maxgoedjen/secretive/blob/54e0d00d87e207377101b0ea6ddfa624cd1a1c16/Sources/Packages/Sources/SecretAgentKit/SocketController.swift#L143)). A stream socket has no message boundaries.
- [`read(2)`](https://man7.org/linux/man-pages/man2/read.2.html): "attempts to read *up to* count bytes … It is not an error if this number is smaller than the number of bytes requested."
- [`recv(2)`](https://man7.org/linux/man-pages/man2/recv.2.html): "normally return any data available, up to the requested amount, rather than waiting for receipt of the full amount requested."
- The [`unix(7)`](https://man7.org/linux/man-pages/man7/unix.7.html) example server *can* treat one `read()` as one message only because it uses `SOCK_SEQPACKET`, which preserves boundaries. macOS `unix(4)` (`man 4 unix`) says "The UNIX-domain family supports the SOCK_STREAM and SOCK_DGRAM socket types", with no `SOCK_SEQPACKET`.

OpenSSH's `ssh-agent` reassembles accordingly ([`ssh-agent.c` L1831-L1841](https://github.com/openssh/openssh-portable/blob/2d98db98331803cbb820211b2fb0d31a6e71e58e/ssh-agent.c#L1831-L1841)):

```c
if (sshbuf_len(e->input) < 5)
        return 0;               /* Incomplete message header. */
msg_len = PEEK_U32(cp);
if (msg_len > AGENT_MAX_LEN) { ... return -1; }
if (sshbuf_len(e->input) < msg_len + 4)
        return 0;               /* Incomplete message body. */
```

### 3. What Secretive does

- [`SocketController.swift` L85-L111](https://github.com/maxgoedjen/secretive/blob/54e0d00d87e207377101b0ea6ddfa624cd1a1c16/Sources/Packages/Sources/SecretAgentKit/SocketController.swift#L85-L111):
  - Each `NSFileHandleDataAvailable` notification does one `availableData` read (L93) and yields that chunk as a complete message (L100).
  - The read is re-armed only in `write(_:)` (L110), i.e. after a response has been sent. So there is exactly one read per request, and a partial read is never completed.
- [`SSHAgentInputParser.swift` L24-L29](https://github.com/maxgoedjen/secretive/blob/54e0d00d87e207377101b0ea6ddfa624cd1a1c16/Sources/Packages/Sources/SSHProtocolKit/SSHAgentInputParser.swift#L24-L29): a 4-byte chunk throws `invalidData`. A chunk shorter than the declared length is parsed truncated.
- [`AppDelegate.swift` L59-L66](https://github.com/maxgoedjen/secretive/blob/54e0d00d87e207377101b0ea6ddfa624cd1a1c16/Sources/SecretAgent/AppDelegate.swift#L59-L66): on a parse error, the session is closed without a response. The client's read of the reply fails with `SSH_ERR_AGENT_COMMUNICATION`, which is what produces `communication with agent failed`.

The sign request is the second message on its connection: `ssh-keygen -Y sign` asks for the identities first. By the time the sign request arrives, the read was re-armed right after the identities answer. The notification therefore fires as soon as the 4 length bytes land. If the client is descheduled before its second `write()`, the agent sees only the length. That happens on a loaded machine. Agent forwarding or a VPN widens the same gap, which matches earlier reports in this thread. Load only changes how often this shows up; the cause is the missing reassembly.

### 4. Reproduction

A relay between the client and the agent forwards bytes unchanged. Its only change is a 50 ms gap between the 4-byte length and the body of each client→agent message. It uses Python 3 stdlib only, and anyone can rebuild it from that description. I compared it against a direct connection and a relay with no gap:

| client → agent | direct | relay, no gap | relay, 50 ms gap |
|---|---|---|---|
| `ssh-keygen -Y sign` → Secretive | 5/5 ok | 5/5 ok | **0/5**, `Couldn't sign message (signer): communication with agent failed` |
| `git commit -S` (`gpg.format=ssh`) → Secretive | ok | — | **fails** with the exact output from the original report (`… communication with agent failed?` / `fatal: failed to write commit object`, exit 128) |
| `ssh-keygen -Y sign` → OpenSSH `ssh-agent` (ed25519 file key) | — | — | **5/5 ok** (also 5/5 with a 200 ms gap) |
| `ssh-add -L` → Secretive | — | 10/10 ok | 10/10 ok |

`ssh-add -L` sends a single first request on a fresh connection, and that request survived when it arrived within roughly the first 20 ms after `connect()`. It was dropped 10/10 when the length arrived at 100 ms or later. I'm guessing the session is still being set up during that window, but I haven't verified it.

The agent's debug log agrees. For 64 concurrent sign requests with 4 failures, I see 64 `accepted connection`, 128 `yielded data`, 60 `received request of type SSH_AGENTC_SIGN_REQUEST`, and exactly 4 `Session closed.` There is no signing or Secure Enclave error.

### 5. The technique, illustrated in C

This is the same accumulate / extract / keep-remainder loop that `ssh-agent` uses, written as a standalone C server. It is not a Swift patch. In Secretive the equivalent would also need the read to be re-armed after a partial read, not only after a response, and that has to be ordered carefully given #769.

```c
static unsigned char acc[4 + MAX_LEN];   /* room for one maximum-size message */
size_t used = 0;

for (;;) {
    ssize_t r = read(fd, acc + used, sizeof(acc) - used);   /* 1) append */
    if (r == 0) return;                                     /* EOF: drop an incomplete message */
    if (r < 0) { if (errno == EINTR) continue; return; }
    used += (size_t)r;

    size_t off = 0;
    while (used - off >= 4) {                               /* 2) extract complete messages */
        uint32_t len;
        memcpy(&len, acc + off, 4);
        len = ntohl(len);
        if (len > MAX_LEN) return;                          /*    cap absurd lengths */
        if (used - off < 4 + (size_t)len) break;            /*    incomplete: read more */
        handle_message(acc + off + 4, len);
        off += 4 + len;
    }
    memmove(acc, acc + off, used - off);                    /* 3) keep the remainder */
    used -= off;
}
```

I built this and a one-`read()`-per-message variant on the same `AF_UNIX` `SOCK_STREAM` socket and fed both the same byte patterns:

| client writes | one read = one message | accumulate |
|---|---|---|
| length, 100 ms, body | parse fails on 4 bytes, connection closed | `SIGN_REQUEST` |
| length + 4 body bytes, 100 ms, rest | `SIGN` (truncated), then the rest misread as a new frame | `SIGN_REQUEST` |
| two messages in one write | first handled, second dropped | both handled |
| length `0x7fffffff`, no body | fails by accident | rejected by the cap |

Happy to rerun the relay tests against a build if that helps.
