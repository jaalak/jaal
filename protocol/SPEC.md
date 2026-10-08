# Jaal Protocol v1

Status: **draft, implemented** by `packages/jaal_core` (Dart). Test vectors are in
`test-vectors/v1.json` and are verified independently with WebCrypto by `verify-vectors.mjs`.
Every client (Android, the PWA, future desktop) MUST reproduce these bytes exactly.

## 1. Model

- A **person** is a root Ed25519 key. `RootId = base64url(rootPublicKey)`.
- Each **device** has its own Ed25519 key and writes one append-only **feed**. `FeedId = base64url(devicePublicKey)`.
- A feed is a hash-chained list of **signed events**. The first event (seq 1) is a
  **device certificate** in which the root key vouches for the device key.
- Peers **sync** by telling each other the latest `seq` they hold per feed and
  pulling what they're missing. Events verify themselves, so **any** peer can carry
  anyone's events (store-and-forward).
- **Private messages** never enter feeds. They travel as **sealed envelopes** through
  a separate carry layer (§6).

## 2. Canonical JSON

Every hashed or signed structure is encoded as canonical JSON, a strict subset of RFC 8785:

- object keys are sorted by UTF-16 code units, with no duplicates
- no insignificant whitespace
- numbers MUST be integers in ±(2^53−1); floats are forbidden
- strings: escape `"` `\` and control characters (`\b \f \n \r \t`, others as lowercase `\u00xx`).
  Everything else, including non-ASCII, is emitted raw. Output is UTF-8.
- strings MUST be well-formed Unicode (no lone surrogates)
- binary values are **unpadded base64url**

`JSON.stringify` on a key-sorted object satisfies this in JavaScript.

## 3. Primitives

| Use | Primitive |
|---|---|
| identity, device, event, DM-inner, auth signatures | Ed25519 |
| content addressing, event ids, body hashes, ack hashes | SHA-256 |
| sealed-envelope key agreement | X25519 |
| key derivation | HKDF-SHA256 |
| authenticated encryption | XChaCha20-Poly1305 (24-byte nonce, 16-byte tag appended) |

Signature domain prefixes (prepended as ASCII bytes to the canonical message):

| Domain | Prefix |
|---|---|
| device certificate | `jaal-devcert-v1:` |
| feed event | `jaal-event-v1:` |
| DM inner payload | `jaal-dm-v1:` |
| sync handshake | `jaal-auth-v1:` |
| device revocation | `jaal-revoke-v1:` |
| QR meet / moderator consent | `jaal-meet-v1:` |

### 3.1 Key derivation from the root seed

The root seed is 32 bytes, and it **is** the BIP39 entropy, so the 24-word English phrase restores everything.

```
rootSigningKey = Ed25519.fromSeed(seed)
dmSeed         = HKDF(ikm=seed, salt="jaal", info="jaal-dm-x25519-v1", L=32)
dmKey          = X25519.fromSeed(dmSeed)               # long-term DM key
selfKey        = HKDF(ikm=seed, salt="jaal", info="jaal-self-aead-v1", L=32)
fingerprint    = Crockford-base32(SHA-256(rootPublicKey))[0:4]   # "@maya·k7f2"
dmHint         = base64url(SHA-256(dmPublicKey)[0:2])
```

v1 limitation: every device restored from the phrase holds the root seed. Per-device DM keys
and root-key-offline setups come in v2.

## 4. Feed events

### 4.1 Shape

```json
{
  "v": 1,
  "feed": "<FeedId>",
  "seq": 2,
  "prev": "<id of seq-1 event | null when seq = 1>",
  "lamport": 17,
  "ts": 1767225601000,
  "type": "post",
  "bh": "<base64url SHA-256(canonical(body))>",
  "sig": "<base64url Ed25519(feed key, 'jaal-event-v1:' ‖ canonical(event without sig))>"
}
```

- `id = base64url(SHA-256(canonical(event without sig)))`
- `lamport` = 1 + the max lamport the author has seen anywhere. It is used for last-writer-wins.
- `ts` is the author's wall clock. It is informational only and never trusted for ordering.
- Unknown top-level fields are rejected.

### 4.2 Validation (receiver)

An event for feed F is accepted iff **all** of these hold:

1. it is structurally valid and `v == 1`
2. if a body is present, `SHA-256(canonical(body)) == bh`, and the body validates for `type` (§4.4)
3. `seq == localLatestSeq(F) + 1` and `prev == localLatestId(F)` (otherwise: *gap* or *fork*)
4. `lamport > previous event's lamport` in F
5. F has not been revoked at or before `seq`
6. the signature verifies under F's key
7. if `seq == 1`: `type == "device.cert"`, `body.device == F`, and the cert's root signature verifies.
   This binds F to `body.root`.
8. the root is not locally blocked

### 4.3 Body erasure

The signature covers `bh`, not the body itself. So after a `delete`, peers drop the
body and keep forwarding the event with `b: null`. The chain stays verifiable
while the content disappears from every phone that has synced the tombstone. Receivers
accept body-less events, and those are never projected.

### 4.4 Event types and bodies

| type | body | semantics |
|---|---|---|
| `device.cert` | `{root, device, created, sig}` | seq 1 of every feed |
| `device.revoke` | `{device, afterSeq, rootSig}` | rootSig over `jaal-revoke-v1:` ‖ canonical({device, afterSeq}); later events from that device are refused |
| `profile` | `{name ≤50, handle ^[a-z0-9_.]{2,24}$, bio ≤300, dm: X25519 pk, avatar: media \| null}` | LWW per root |
| `post` | `{text ≤2200, media: [MediaManifest]}` | id = event id |
| `post.edit` | `{target, text}` | LWW per target; author must match |
| `delete` | `{target}` | tombstone; author must match target's author; may arrive before target |
| `reaction` | `{target, sticker \| null, x 0..1000, y 0..1000, rot −45..45}` | sticker reaction; LWW per (root, target); null removes it |
| `comment` | `{target, text ≤1000, parent \| null}` | threaded |
| `follow` | `{target: RootId, on: bool}` | LWW per (root, target) |
| `self.private` | `{nonce, ct}` | XChaCha20-Poly1305(selfKey, aad = FeedId). v1 payload: `{kind:"blocks", roots:[…]}`, LWW |
| `mod.vouch` / `mod.revoke` / `mod.ban` | see §10 | inert unless the author is a moderator |

LWW order: higher `lamport` wins; ties are broken by the lexicographically greater event id.

Unknown types MUST be stored and forwarded, but not projected (forward compatibility).

## 5. Replication

### 5.1 Wire item

Events travel as `{"e": event, "b": body | null, "h": hops}`. `h` is an **unsigned**
hop counter: the receiver stores `h + 1`. It powers postmarks only and MUST NOT be used for trust.

### 5.2 Policy (what a node asks for)

A node requests feeds whose root is: itself, a root it follows, a root **currently connected**
(so you can discover people around you), **any moderator**, or an *established* follow of a follow
(up to `maxFofRoots`, default 150; see §10.5). Blocked and banned roots are excluded.

## 6. Sealed envelopes (DMs)

```json
{ "v":1, "kind":"dm", "hint":"<2B>", "epk":"<X25519 ephemeral pk>",
  "ack":"<base64url SHA-256(ackSecret)>", "exp": <ms>, "nonce":"<24B>", "ct":"<…>" }
```

```
shared = X25519(ephemeralPriv, recipientDmPub)
key    = HKDF(ikm=shared, salt=epk ‖ recipientDmPub, info="jaal-seal-v1", L=32)
ct     = XChaCha20-Poly1305(key, nonce, plaintext=canonical(inner), aad=canonical(header))
header = {v, kind, hint, epk, ack, exp}
inner  = {to, from, cert, sentAt, text, ackSecret, sig}
sig    = Ed25519(sender device, "jaal-dm-v1:" ‖ canonical(inner without sig))
envelopeId = base64url(SHA-256(canonical(envelope)))
```

- **A carrier sees:** the hint (16 bits), the size, the expiry and the hop count. It never sees the sender, recipient or content.
- **The recipient** trial-opens envelopes whose `hint` matches its own, then verifies: the MAC; `inner.to == self`
  (this stops re-sealing attacks); that `cert` is valid with `cert.root == inner.from`; the inner signature
  under `cert.device`; and `SHA-256(ackSecret) == ack`.
- **Delivery receipt:** the recipient broadcasts `ackSecret`. Anyone can check it against the envelope's
  `ack` hash, so receipts can't be forged. Carriers drop the ciphertext and count *courier clout*;
  the sender marks the message delivered. Receipts reveal *that* an envelope was delivered, not to whom.
- Default TTL is 14 days. Carriers enforce a byte budget (default 20 MiB) and evict the oldest first.

## 7. Sync session

### 7.1 Framing

A transport delivers reliable, ordered **frames** of up to 256 KiB. Each frame is one canonical JSON object `{"t": type, …}`.

### 7.2 Messages

| t | fields | |
|---|---|---|
| `hello` | `v, feed, root, nonce(16B), cert` | first frame, both sides |
| `auth` | `sig` = Ed25519(device, `jaal-auth-v1:` ‖ canonical({by: me, for: peerFeed, nonce: peerNonce})) | proves possession of the device key |
| `have` | `feeds: [[feedId, rootId, latestSeq], …]` | full inventory once, then incremental |
| `req` | `feeds: [[feedId, fromSeq], …]` | only for feeds the policy wants |
| `events` | `items: [wire item, …]` | in seq order per feed; unsolicited feeds are ignored |
| `env.inv` | `ids: [[envelopeId, exp], …]` | envelope inventory |
| `env.req` | `ids: [envelopeId, …]` | |
| `env.push` | `items: [{env, h}, …]` | |
| `acks` | `items: [[ackSecret, exp], …]` | delivery receipts |

Both sides run the same state machine: `hello → auth → live`. While live, every local change
(a new event or envelope, a learned ack) is pushed as an incremental `have` / `env.inv` / `acks`.
That gives **real-time** delivery when peers are in range and **store-and-forward** when they are not.
Interrupted transfers resume naturally, because the next `req` starts from the receiver's latest seq.

## 8. Media (photos)

```json
{ "hash": "<SHA-256 of whole file>", "mime": "image/jpeg", "size": 412000,
  "chunkSize": 65536, "chunks": ["<SHA-256 of chunk 0>", …], "w": 1080, "h": 1350, "dur": null }
```

- **Compression** (client side, before posting): long edge ≤ 1440 px (1080 when "crunch more"), JPEG quality
  stepped down until the file is ≤ 450 KB (≤ 220 KB with crunch). The optional "xerox" filter applies grayscale,
  contrast and grain.
- A post's `media` list holds manifests. When a post (or a profile `avatar`) is projected, its blobs are
  **expected** locally.
- **Sync** (sessions, §7.2):

| t | fields | |
|---|---|---|
| `media.req` | `items: [[hash, [chunkIdx…]], …]` | ≤ 8 chunks in flight per session, newest posts first |
| `media.chunk` | `h, i, d` (base64url chunk) | one chunk per frame |
| `media.miss` | `items: [[hash, [chunkIdx…]], …]` | "I don't have these". The requester won't ask this peer again this session |

- Each chunk is checked against `manifest.chunks[i]`, and the assembled file against `manifest.hash`. If the whole
  file fails its hash, every chunk is dropped and refetched.
- Any phone that holds chunks serves them, so photos travel store-and-forward just like events. An interrupted
  transfer resumes from whatever chunks are missing.
- Deleting a post (tombstone) or banning its author drops the blobs on every phone that syncs.
- Not yet built: video, and per-file encryption for private media.

## 9. Versioning

`v` appears in events, envelopes and `hello`. A breaking change increments it. Unknown event
types and unknown sync messages are ignored (events are still stored and forwarded), so the
protocol can grow without splitting the mesh.

## 10. Moderation

Moderation is **computed by every client from signed events**, not granted by a server.
Two honest clients holding the same `mod.*` events reach the same answer.

### 10.1 Roles

- **Genesis moderators**: three root keys compiled into the official client
  (`GenesisKeys.roots`, generated offline by `tool/genesis.dart`). They are moderators by
  definition, can't be revoked or banned, and only change with an app update.
- **Moderators**: any root that ≥ 3 distinct (current or pre-revocation) moderators vouched for.

### 10.2 Events

| type | body | rule |
|---|---|---|
| `mod.vouch` | `{candidate, consent: MeetCode}` | `consent.purpose == "mod"`, `consent.root == candidate`, the consent signature is valid, `abs(event.ts − consent.ts) ≤ 24h`, author ≠ candidate. The scanning client also requires the QR to be ≤ 10 min old. |
| `mod.revoke` | `{target, cutoff: {feedId: seq}}` | `cutoff` = the last seq of each of the target's feeds that the voter had seen |
| `mod.ban` | `{target, on: bool, reason ≤ 280}` | LWW per (moderator, target); `on: false` retracts |

### 10.3 Derivation

```
authorized(a) = (a.author ∈ genesis ∪ qualified) ∧ ¬voided(a)
voided(a)     = a.author is revoked ∧ (a.feed ∉ cutoff ∨ a.seq > cutoff[a.feed])
qualified     = { c ∉ genesis : |{authorized vouches for c, distinct authors}| ≥ 3 }
revoked(t)    = t ∉ genesis ∧ ( ∃ authorized revoke of t by a genesis key
                              ∨ ≥ 3 distinct authorized revokes of t )
                cutoff(t) = per-feed minimum over the effective revokes (missing feed ⇒ 0)
moderators    = genesis ∪ (qualified − revoked)
```

These are iterated to a fixpoint (capped at 32 rounds). Actions a moderator signed **before** their revocation
cutoff keep counting. Anything after it is void.

Bans: take each authorized moderator's latest `mod.ban` vote per target, and count `on` votes:

| votes | state | effect on honest clients |
|---|---|---|
| 0 | none | — |
| 1 | **flagged** | content hidden from feeds, comments and explore; still stored and replicated (reversible) |
| ≥ 2 | **banned** | events refused at ingest (`RejectReason.banned`), all their content purged, never requested, DMs from them dropped, their own client refuses to publish (`BannedException`) |

Moderators and genesis keys can't be flagged or banned: revoke them first.

### 10.4 Propagation

- Every node replicates **every moderator's feed** (§5.2), so votes and vouches reach everyone, store-and-forward.
- A session with a banned peer is **quarantined**: we advertise and serve only moderator feeds and
  accept nothing. Their honest client can then learn it was removed.

### 10.5 Newcomer limits (ban evasion)

A banned person can create a new key, so friend-of-friend replication (§5.2) only includes roots that are
**established** from the replicator's own point of view: either this node first saw the root ≥ 7 days ago, or
someone this node follows has followed it (by that follower's event ts) for ≥ 7 days. Followers and physically
nearby peers get a newcomer's posts immediately; the wider mesh doesn't.

### 10.6 What moderation can't do

A banned person can still create events on their own phone with a modified client. Moderation guarantees that
**no honest phone stores, forwards or displays them**. Forks of the client can ship different genesis keys.
That forms a separate moderation domain, which doesn't affect clients running the official keys.

## 11. Identity guardrails (anti-impersonation)

- **Forgery is cryptographically impossible.** Every event, DM and handshake is signed. Publishing as Maya
  requires Maya's private key, which never leaves her devices. Decompiling or modifying the client doesn't help.
  Covered by tests: bad signatures, forged device certs, forked chains, re-sealed DMs, tampered QR codes.
- **Lookalikes are detected.** `Lookalikes.skeleton()` folds case, separators, trailing digits and confusables
  (`0→o 1/i→l 3→e 4→a 5→s 7→t 8→b rn→m vv→w`). A profile whose handle or name skeleton matches someone
  *established for you* (yourself, someone you follow or verified, or a key you saw earlier) gets a warning:
  "looks like @maya·k7f2 (you follow them) — different key".
- **Fingerprints everywhere.** Handles always render with the 4-char key fingerprint: `@maya·k7f2`.
- **Verified in person.** `MeetCode` (QR) = `jaal:1:` + base64url(canonical JSON
  `{purpose, root, dm, handle, nonce, ts, sig}`), with sig = Ed25519(root key, `jaal-meet-v1:` ‖ canonical(unsigned)).
  Scanning checks the signature and that the code is ≤ 10 min old, then stores the person as verified (local).
- **Petnames.** Private local nicknames that override handles for you.
- **Not done on purpose:** "official app only" attestation. In open-source, serverless software it can be
  stripped or spoofed, so it would be theater.
