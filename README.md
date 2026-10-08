# jaal

**no wifi? no problem.** Jaal (*net, mesh*) is a local-first, peer-to-peer social app:
posts, stickers, comments, follows and sealed DMs that travel phone to phone, with no
internet, no cell signal and no servers.

```
apps/mobile/          Flutter Android app (onboarding + Network Lab; social screens follow the Stitch designs)
packages/jaal_core/   pure-Dart core: identity, crypto, protocol, events, sync, messaging, media, db, transport
packages/jaal_sim/    simulated peer network: NetworkLab engine + CLI scenarios
protocol/             SPEC.md, test vectors, WebCrypto cross-check
docs/                 ARCHITECTURE, DECISIONS, PWA plan, roadmap, stitch/ (Google Stitch prompt pack)
```

## Status: milestone 1

| | |
|---|---|
| ✅ identity | root and device Ed25519 keys, 24-word BIP39 recovery, device certs, fingerprints |
| ✅ protocol | canonical JSON, signed hash-chained feeds, body-hash signatures (erasable), test vectors verified with WebCrypto |
| ✅ storage | Drift/SQLite: replicated log + projections (profiles, posts, stickers, comments, follows, tombstones) |
| ✅ sync | authenticated sessions, seq-vector exchange, policy-driven pulls, live push, resumable |
| ✅ store-and-forward | sealed DM envelopes, carry inbox with TTL and budget, unforgeable anonymous receipts, courier clout |
| ✅ moderation | 3 genesis moderators; 3 in-person QR vouches promote a moderator; 2 votes remove a toxic user everywhere (purged, refused, can't post); rogue-moderator revocation; newcomer limits against ban evasion |
| ✅ anti-impersonation | signed everything (forgery impossible), key fingerprints, lookalike detection, signed in-person QR verification, petnames |
| ✅ user controls | delete tombstones that erase content on replicas, LWW edits, private encrypted block list |
| ✅ photos | compressed (+ optional xerox filter), content-hashed, chunked, synced chunk by chunk from any phone that has them, resumable, deleted with the post |
| ✅ social UI | all Stitch screens in Flutter: home + radar wall, post detail, sticker slap, compose, profile, meet (QR), nearby, letters, chat, carry pouch, explore, settings, become moderator, moderation desk, safety states |
| ✅ simulation | `SimNetwork` (range, latency, flaky links), `NetworkLab`, CLI scenarios, in-app Network Lab |
| ✅ design system | Off-Grid Zine tokens + Flutter widgets; Stitch prompt pack + exports for 19 screens |
| ⏳ next | real radios (Nearby/BLE/Wi-Fi Direct), video, private media, PWA |

## Run it

Requires Flutter 3.47+ (Dart 3.13+) and JDK 17 for Android builds.

```sh
dart pub get                                   # resolves the whole workspace

# core: protocol, crypto, sync, store-and-forward tests
cd packages/jaal_core && dart test
dart run build_runner build                    # after changing Drift tables
dart run tool/gen_vectors.dart                 # regenerate protocol test vectors
node ../../protocol/verify-vectors.mjs         # cross-check them with WebCrypto

dart run tool/genesis.dart                     # ONCE, offline: create the 3 genesis moderator keys

# simulator scenarios
cd packages/jaal_sim && dart run jaal_sim --list
dart run jaal_sim courier -t                   # with the lab timeline
dart run jaal_sim market -v                    # with sync-engine logs

# Android app
cd apps/mobile && flutter test && flutter run
flutter test test_goldens --update-goldens     # render every screen to test_goldens/goldens/*.png
```

In the app: create a node, then open the **network lab**. Tap *spawn* a few times,
flip *near you*, try *chain* plus *follow-web* plus *chatter*, and watch posts arrive with
hop postmarks and sealed DMs get carried by strangers. Tap *mods* to spawn the lab's three
genesis moderators, then open any peer to vouch them in, vote to remove them, or spawn an impostor.

## Design: Google Stitch

Start at [`docs/stitch/README.md`](docs/stitch/README.md). Paste `00-design-system.md` first,
then the screens in order. Bring the exports back and the Flutter screens get built to match.
