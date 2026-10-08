# Roadmap

## M1: core + simulation ✅
See README "Status". Exit criteria met: 41 core tests, 4 simulator scenarios, 3 widget tests, protocol vectors cross-verified in WebCrypto.

## M1.1: moderation + anti-impersonation ✅
Genesis moderators, vouching, 2-vote bans, revocation, quarantine, newcomer limits, lookalike detection,
signed QR verification (53 core tests). **Before a public release:** run `tool/genesis.dart` offline and
hand the three phrases to three trusted people.

Follow-ups: user **reports** (sealed envelopes addressed to moderators), a moderation log screen,
appeal/pardon flow, schema-migration test fixtures.

## M1.5: social UI from Stitch ✅
Done: screens built from `docs/stitch/exports` (Stitch zip + API), photo pipeline (compress → chunk →
`media.req/chunk/miss` → resumable assembly), screenshot harness in `apps/mobile/test_goldens`.
Left over: drag-to-place stickers, dark-mode pass, golden diffs in CI, read receipts for letters.

### original plan
1. Run the Stitch pack (docs/stitch) and export to `docs/stitch/exports/`.
2. Build screens 04–15 in `apps/mobile/lib/features/{feed,post,stickers,compose,profile,meet,nearby,inbox,chat,pouch,explore,settings}`
   against existing `JaalNode` streams. Add a bottom-nav shell route; keep the Network Lab under settings → dev.
3. QR meet: `jaal:1:<root>:<dm>:<handle>` payload (`mobile_scanner`, `qr_flutter`).
4. Golden tests per screen, in light and void themes.

## M2: media + real radios
- Media pipeline: client-side compression (image: WebP/JPEG q≈75, max 1440px; video: H.264 720p via platform encoder),
  `media.have/req/chunk` sync messages, chunk store table, resumable assembly (`ChunkAssembler` already exists),
  per-file key encryption for private media.
- `packages/jaal_transport_android` (Kotlin plugin): Nearby Connections first (fastest path to real devices),
  then raw BLE + Wi-Fi Direct. Each implements `PeerTransport`.
- Noise XX session encryption; rotating BLE identifiers.
- Foreground service for background syncing, with battery-aware duty cycling.

## M3: PWA + groups
- `apps/pwa` per docs/PWA.md; `lan` WebSocket transport on Android to serve iPhones.
- Group messaging: sender keys sealed to each member through envelopes; membership as events.
- Multi-device: per-device DM subkeys, sent-message sync between own devices, device revocation UI.

## Later
Key rotation and forward secrecy, relay-when-online, body refetch after redaction, content
warnings and community moderation lists (shared block lists as signed opt-in feeds).
