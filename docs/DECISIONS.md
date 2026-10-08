# Decision log

These were settled in the kickoff grilling session on 2026-10-08. Change them deliberately: add a new entry
rather than editing an old one.

| # | Decision | Why | Alternatives rejected |
|---|---|---|---|
| D1 | **Milestone 1** = core (Drift DB, identity, signed events, sync engine, 1:1 E2EE DMs) + simulated peers + Network Lab + Stitch brief | The protocol and sync are the risky parts. Prove them before radios and the PWA | core + media; core + PWA; plan only |
| D2 | **Per-device signed hash-chained feeds**, certified by the root key; sync by comparing seq per feed | Self-verifying, so any peer can carry; gaps are trivially detectable; resumable (SSB lineage) | content-addressed DAG + set reconciliation; Automerge-style CRDT |
| D3 | **Replication = follows + friends-of-friends (budgeted) + directly connected peers**; DMs in a separate carry inbox (14d TTL, byte budget) | Bounded storage, spam-resistant, and DMs still reach strangers | flood everything; follows only |
| D4 | **Sealed envelopes**: per-message ephemeral X25519 → HKDF → XChaCha20-Poly1305, sender inside, 2-byte recipient hint | No handshake, works with any order and any delay; carriers learn almost nothing | Double Ratchet (needs handshakes and order); visible recipient |
| D5 | **Canonical JSON + SHA-256** | Debuggable, trivial to match in the browser with WebCrypto | CBOR; protobuf; BLAKE2b (no WebCrypto support) |
| D6 | **Monorepo with a pure-Dart core** (pub workspace) | Fast `dart test` for protocol and sync, reusable by the simulator | single Flutter app |
| D7 | **Riverpod, no codegen**; Drift streams drive the UI | Local-first reactivity for free | Bloc |
| D8 | **In-app Network Lab + CLI simulator** sharing one engine | Develop decentralized behaviour before radios | CLI/tests only |
| D9 | **Root + device keys, BIP39 24 words**, handle + 4-char fingerprint, QR verification in person | No server means the user owns recovery; no global namespace offline | single key with or without backup |
| D10 | **Visual identity: Off-Grid Zine** (neo-brutalist, acid pops, stickers, xerox grain, lowercase voice) | Gen-Z, distinctive, *not* the generic soft-card look | Y2K Signal, Night Market Glitch, Soft Chaos Scrapbook, Woven Dusk |
| D11 | **Signature moments**: hop postmarks, sticker reactions, nearby radar wall, carry pouch | Turn the offline mechanics into the aesthetic | — |
| D12 | **Postmarks are anonymous** (unsigned hop count + transit time) | Named carriers would leak who was near whom | signed named stamps |
| D13 | **Delivery receipts by hash preimage** (`ack = SHA-256(secret)`, secret inside the ciphertext) | Unforgeable, anonymous, lets carriers drop delivered mail | signed acks; no acks |
| D14 | **Delete = tombstone + body erasure** (signature covers the body hash); edits LWW; **blocks private** (local, synced to own devices encrypted to self) | Real erasure on every phone that syncs, without breaking the chain | public block events; no deletion |
| D15 | **Stitch first**: the social screens are built after Stitch designs; only onboarding + Network Lab exist in Flutter now | Avoid building UI twice | build both in parallel |

## Moderation & impersonation (2026-10-08, second session)

| # | Decision | Why | Alternatives rejected |
|---|---|---|---|
| D16 | **Three genesis moderator keys** compiled into the official app, generated offline (`tool/genesis.dart`) | A root of trust for "invite-only" without a server, and no single founder key | one founder key bootstrapping; user-chosen moderation domains |
| D17 | **Moderator = 3 distinct moderator vouches**, each embedding the candidate's signed, fresh `purpose: mod` QR (scanned in person) | Matches "3 invites, by QR scan"; consent can't be forged | — |
| D18 | **Ban quorum 2**: 1 vote flags (hidden, reversible), 2 votes ban (purged, refused, can't post) | Fast response, but one rogue or hacked moderator can't silence anyone | 1 vote; 3 votes |
| D19 | **Revoking a moderator**: any genesis key alone, or 3 moderators; their actions after the cutoff are void, earlier ones stand | Mirrors promotion; recovers from rogue moderators without rewriting history | genesis only; permanent |
| D20 | **Newcomer limits**: no friend-of-friend reach until a key is established for ≥7 days, measured with timestamps the newcomer doesn't control | Makes ban evasion with fresh keys costly without closing the network | vouch-to-post; per-key only |
| D21 | **Quarantined sessions** with banned peers (serve moderator feeds only, accept nothing) | Their honest client learns of the ban and stops posting | hard disconnect |
| D22 | **Anti-impersonation** = signatures (forgery impossible) + fingerprints + lookalike detection + in-person QR verification + petnames. **No app attestation** | Decompiling yields code, not keys; attestation is theater in open-source P2P | Play Integrity / signed-build checks |

## Front end (2026-10-08, third session)

| # | Decision | Why | Alternatives rejected |
|---|---|---|---|
| D23 | **Build photo transfer before the screens** | The designs are photo-first; placeholders would have hidden the main feature | screens text-only first; photos + video together |
| D24 | **Follow Stitch's DESIGN.md**: Space Grotesk 700 headlines (Archivo Black only for the wordmark), skewed highlighters, double-ring postmarks, 12/28 polaroid frames | It's what you approved in Stitch | keep the original tokens |
| D25 | **Keep the lowercase rule** even where the generated inbox/explore screens drifted to UPPERCASE | Brand voice (D10) | copy Stitch verbatim |
