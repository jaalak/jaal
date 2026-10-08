# 04 — Home feed + nearby radar wall

**Purpose:** the main screen. Posts from you and the people you follow, with the
**nearby radar wall** and **hop postmarks** front and centre.
**Route:** `/home` · **Backed by:** `JaalNode.watchHomeFeed()`, `SyncEngine.connectedRoots` / `PeersSeen` (radar wall),
`posts.hops` and `firstSeenAt − ts` (postmark), `reactions` (stickers).

## PROMPT

```
Screen: home feed for jaal (Instagram-like feed), Off-Grid Zine style, Android 412x915 with the bottom nav (home active).

TOP BAR: lowercase "jaal" wordmark (Archivo Black 28px, lime highlighter swipe) on the left; on the right, two square icon buttons with 3px borders: a sealed-envelope icon with a pink badge "2" (inbox) and a pouch icon with a blue badge "4" (carry pouch).

NEARBY RADAR WALL (below the top bar, ~150px tall): a corkboard/kraft-paper strip with a 3px border. On it, 4 polaroid cut-outs of people physically nearby, taped at different angles, each with a handwritten Caveat name ("maya", "arjun", "zoe") and a lime dot for "syncing now". Over the strip runs a yellow masking-tape label in Space Mono: "syncing… 3 nearby · 41 new". At the far right is a dashed empty polaroid: "+ meet someone (qr)".

FEED: vertical list of post cards, each card slightly tilted (alternate -1°, 1°), 3px black border, hard 6px shadow, paper fill:
- Header row: small square polaroid avatar, "maya" bold, then "@maya·k7f2" in grey Space Mono, and "· 2d" timestamp. A ⋯ menu on the right.
- Square photo (mountain summit at sunrise) with a 3px border. Stickers are slapped onto the photo at angles: a pink "fire" sticker, a lime "real" sticker, a blue "w" sticker, plus a "+3" sticker pile.
- Overlapping the photo's top-right corner: a red circular rubber-stamp POSTMARK rotated -12°, Space Mono, reading "3 hops" / "2d 4h".
- Caption in Space Grotesk 15px: "summit selfie (no signal up here)".
- Action row: a sticker-slot icon "stick", a speech-bubble "12", a sealed-envelope "send" icon, all thick outlined icons; on the right, small grey mono text "via arjun's phone".

A second card below with only text (no photo), on paperDeep with a tape strip at its top, and a postmark "1 hop · live".

A third card showing a VIDEO: thumbnail with a square play button and a progress chip "chunks 18/24 · resuming" in Space Mono with a mini segmented progress bar (blue segments), because media arrive piece by piece.

Bottom nav: 5 square tabs (home, explore, +, inbox, you). The active tab is a lime block with a 3px border; the "+" tab is a pink square, raised with a hard shadow.
```

## States
- **Nobody nearby:** the radar wall shows a dashed empty corkboard: "nobody around. your posts are waiting in your pocket. they'll leave when someone walks by." with a small hand-drawn person icon.
- **Empty feed:** halftone poster: "follow people you meet. scan their qr." and a button "show my qr".
- **New posts arrived:** a lime tape strip at the top: "↓ 7 new from the mesh".

## Iterate
- "make postmarks look like real faded ink, slightly cut off by the photo edge"
- "make the radar wall more like a corkboard with pushpins"
