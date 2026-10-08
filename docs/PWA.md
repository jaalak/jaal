# PWA client (iPhone) — design, milestone 2

iOS doesn't allow background Bluetooth mesh apps outside the App Store, and the Web
Bluetooth / Web NFC APIs aren't available in Safari. So the PWA joins the mesh **through
other transports** while speaking the same protocol byte for byte.

## Stack

- TypeScript + Vite + Preact (small bundle). Service worker (Workbox) for offline caching of the app shell and media.
- Storage: IndexedDB (Dexie). Same logical tables as Drift: `feeds`, `events`, projections, `envelopes`, `acks`, `messages`.
- Crypto: **WebCrypto** for SHA-256 and HKDF, and for Ed25519/X25519 where the engine supports them
  (feature-detect at startup); otherwise `@noble/curves`. XChaCha20-Poly1305 isn't in WebCrypto, so it uses `@noble/ciphers`.
- Keys: non-extractable where possible; the root seed is encrypted at rest with a passkey-derived key (WebAuthn PRF), or with a passphrase as fallback.
- `protocol/verify-vectors.mjs` already proves WebCrypto reproduces the Dart ids and signatures. It is the seed of the PWA's protocol tests.

## How an iPhone reaches the mesh

| Transport | How | Offline? |
|---|---|---|
| `lan` (WebSocket) | An Android Jaal phone runs a tiny local WebSocket server on a hotspot or shared Wi-Fi; the PWA connects to `ws://<android-ip>:7777` | yes, no internet needed |
| `webrtc` | Pairing by QR (SDP offer/answer in QR codes, no signalling server), then a data channel | yes, on the same LAN |
| `relay` (optional) | When internet *is* available, a dumb relay forwards frames; it only ever sees signed events and sealed envelopes | no |

Each is a `PeerTransport` implementation in TS with the same frame contract (≤256 KiB, reliable, ordered).
The Android app gains a `lan` transport so it can serve PWAs.

## Module map (mirrors jaal_core)

```
apps/pwa/src/
  core/canonical.ts  crypto.ts  identity.ts  event.ts  bodies.ts
  core/eventStore.ts projector.ts  carrier.ts  envelope.ts  sync/session.ts sync/engine.ts
  core/transport/{peerTransport,websocket,webrtc}.ts
  db/schema.ts (Dexie)
  ui/  (Stitch exports → components; same tokens.json)
  sw.ts (service worker)
```

## Offline behaviour

- The app shell, fonts and design assets are precached; everything else is local-first in IndexedDB.
- Background sync is limited on iOS, so syncing happens while the PWA is open. The UI says so honestly:
  "open jaal near a friend's phone to swap."
