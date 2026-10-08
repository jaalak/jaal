# 12 — Chat thread

**Purpose:** a 1:1 conversation. Real-time when you're in range; store-and-forward otherwise.
**Route:** `/inbox/:rootId` · **Backed by:** `watchConversation(peer)`, `JaalNode.sendDm`, `Carrier` (sealed
envelopes: XChaCha20-Poly1305, sender hidden inside), ack receipts.

## PROMPT

```
Screen: 1:1 chat thread for jaal, Off-Grid Zine style.

App bar: back arrow, polaroid avatar "zoe", "@zoe.zine·m3qa" in mono, and a live status under the name: a lime dot "nearby — instant" (alternate: grey "far — letters travel by people").

A "sealed" banner at the top on tape: "end-to-end sealed. carriers see an envelope, not you."

Messages:
- Incoming: paper cards with a 3px border and hard 3px shadow, left aligned, tilted -1°, Space Grotesk text, mono time "14:02".
- Outgoing: lime #C6FF00 cards, right aligned, tilted 1°.
- Under each outgoing message, a tiny status in Space Mono with an icon:
  "sealed ✉" → "handed to a stranger 🚶 1h" → "delivered · 3 hops ✓✓". Show one of each across three messages.
- A date divider as a torn-paper strip: "tuesday · came through the mesh".
- One message has a blue Caveat margin note: "this one took 2 days. worth it."

Composer at the bottom: square input "write a letter…" with a 3px border, a sticker button, and a pink square "seal" send button with a wax-seal icon. When pressed, annotate the animation: "the envelope folds and a wax seal stamps it."
```

## Iterate
- "make outgoing in-transit messages look like paper airplanes flying away"
