# Jaal architecture

## Layers

```
┌──────────────────────────────────────────────────────────────────────┐
│ apps/mobile (Flutter, Android)          apps/pwa (TS, milestone 2)   │
│  features/*  ── Riverpod providers ──▶  JaalNode API                  │
│  design/  (Off-Grid Zine tokens + widgets, mirrors docs/stitch)      │
├──────────────────────────────────────────────────────────────────────┤
│ packages/jaal_sim   NetworkLab · scenarios · CLI                      │
├──────────────────────────────────────────────────────────────────────┤
│ packages/jaal_core  (pure Dart, no Flutter)                           │
│                                                                      │
│  node/       JaalNode — the only API the UI uses                      │
│  sync/       SyncEngine (connections) · SyncSession (protocol §7)     │
│              ReplicationPolicy (follows, FoF, nearby)                 │
│  events/     EventStore (append/validate/ingest) · Projector (views)  │
│  messaging/  Sealer (sealed envelopes) · Carrier (store-and-forward)  │
│  moderation/ ModerationEngine (vouch/revoke/ban → status) · genesis   │
│  media/      MediaManifest · Chunker · ChunkAssembler                 │
│  protocol/   SignedEvent · FeedItem · Bodies (schemas)                │
│  identity/   RootIdentity · DeviceCert · LocalIdentity · KeyStore     │
│              MeetCode (signed QR) · Lookalikes (impersonation)        │
│  crypto/     JaalCrypto (Ed25519, X25519, HKDF, XChaCha20, SHA-256)   │
│  db/         Drift schema + queries (SQLite)                          │
│  transport/  PeerTransport / PeerConnection · SimulatedTransport      │
│  util/ logging/  canonical JSON, base64url, clocks, LogBuffer         │
└──────────────────────────────────────────────────────────────────────┘
```

Dependencies only point downward. `transport/` knows nothing about events, and
`sync/` knows nothing about radios. The UI never touches the database schema directly:
it calls `JaalNode` and watches Drift streams through providers.

## Data flow

**Local action**: the UI calls `node.post(text)`. `EventStore.append` validates the body, picks
`seq`, `prev` and `lamport`, then signs and stores the event and projects it into `posts`, all in one
transaction. It then emits `StoredEvent`, `SyncEngine` pushes an incremental `have` to every live session,
and Drift streams update the UI.

**Remote event**: `SyncSession` receives `events` and calls `EventStore.ingest`, which runs the
§4.2 checks. The event is stored with `hops + 1` and projected. The `StoredEvent` fans out to
*other* sessions; that fan-out is the store-and-forward step.

**DM**: `node.sendDm` → `Carrier.sendDm` seals the message to the recipient's profile DM key and stores the envelope
(`origin = sent`). Sessions advertise it in `env.inv`. A peer that isn't the recipient stores it as carried, within its
budget. The recipient opens it, stores the message, and reveals the ack secret. `acks` spread outward; carriers
drop the ciphertext and gain clout, and the sender marks the message delivered.

## Local-first storage

| Table | Role |
|---|---|
| `feeds`, `events` | **source of truth**: the replicated signed log |
| `profiles`, `posts`, `reactions`, `comments`, `follows`, `tombstones` | projections, rebuildable from `events` |
| `envelopes`, `acks` | carry layer (store-and-forward) |
| `messages` | decrypted DMs, local only |
| `blocks`, `peers_seen`, `stats` | local state (blocks also sync privately via `self.private`) |
| `mod_actions` | every `mod.*` event, validated at ingest (consent signature, skew) |
| `moderators`, `mod_status`, `mod_revocations` | derived by `ModerationEngine.recompute()` after each `mod.*` event |
| `verified`, `petnames` | local trust: people met in person, private nicknames |

Secrets (root seed, device seed) live in the platform `KeyStore` (Android Keystore through
flutter_secure_storage), never in SQLite.

## Transport abstraction

```dart
abstract interface class PeerTransport {
  String get id;                          // sim | ble | wifi-direct | lan
  Stream<PeerAdvert> get discovered;      // peer came into range
  Stream<String> get lost;                // peer left
  Stream<PeerConnection> get incoming;
  Future<void> start(Map<String, String> meta);
  Future<void> stop();
  Future<PeerConnection> connect(PeerAdvert peer);
}
abstract interface class PeerConnection {  // reliable, ordered frames ≤ 256 KiB
  Stream<Uint8List> get frames;
  Future<void> send(Uint8List frame);
  Future<void> close();
  Future<void> get closed;
}
```

To add a real radio, implement these two interfaces and pass the instance to `JaalNode.open(transports: [...])`.
`SyncEngine` already handles several transports at once, a dial tie-break (the lower feed id dials), duplicate-session
drops, and reconnect-with-retry. Planned implementations:

| Transport | Android API | Notes |
|---|---|---|
| `ble` | BLE advertising (service UUID + rotating id), GATT or L2CAP CoC for data | discovery everywhere, ~100 KB/s |
| `wifi-direct` | `WifiP2pManager` + sockets | bulk media, ~10+ MB/s |
| `nearby` | Google Nearby Connections (`P2P_CLUSTER`) | simplest real-world option; BLE + Wi-Fi upgrade handled for us |
| `lan` | mDNS/NSD + TCP | same Wi-Fi without internet (hostel, campus) |

Platform code goes in a Flutter plugin (`packages/jaal_transport_android`, Kotlin) that exposes exactly
these interfaces over method and event channels.

## Simulation-first development

`SimNetwork` models a radio environment in memory: per-link range, latency and break probability.
`NetworkLab` (in jaal_sim) adds peer management, topology presets (mesh, chain, shuffle), random
"chatter", and snapshots. The same engine powers:

- `packages/jaal_core/test`: protocol, crypto, sync and store-and-forward tests (41 tests)
- `packages/jaal_sim`: `dart run jaal_sim [mesh|courier|market|flaky]` scenarios (also run as tests)
- the in-app **Network Lab**, where you spawn peers, toggle "near you", tune links, and watch the wire log

## Moderation flow

A `mod.*` event is appended or ingested → `Projector` passes it to `ModerationEngine.record` (validating
the consent QR signature and skew) → after commit, `recompute()` derives moderators, revocations and ban
states (protocol §10.3) → newly banned roots are purged → `SyncEngine` closes sessions with newly banned
peers, which reconnect in **quarantine** → `ReplicationPolicy` always wants moderator feeds and never wants
banned ones → `EventStore` rejects their events, and their own client throws `BannedException` on publish.

## Security notes (v1)

- Every event and DM is signed. Sync sessions are mutually authenticated (`auth`), but frames are **not yet
  encrypted on the wire**. Content privacy comes from sealing (DMs) or is intentionally public (posts).
  v2 adds a Noise XX handshake per session so passive radio listeners can't see feed inventories.
- Hop counts and carrier-provided fields are unsigned and cosmetic.
- A malicious relayer can strip bodies (they arrive redacted). v2 will refetch bodies from other peers.
- Sealed DMs have sender-anonymity toward carriers, but no forward secrecy against later compromise of the
  recipient's long-term DM key. v2: key rotation through profile updates, and possibly a ratchet.
- BLE advertisements must use rotating identifiers, never the feed id (the `meta['feed']` dial hint is sim-only).
