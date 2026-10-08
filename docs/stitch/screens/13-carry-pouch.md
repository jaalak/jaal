# 13 — Carry pouch + courier clout

**Purpose:** show the sealed letters your phone is carrying for strangers, and reward you for delivering them.
**Route:** `/pouch` · **Backed by:** `watchCarryPouch` (envelopes with `origin = carried`, not acked, not expired:
size, hops, expiry), `stats['courier.delivered']`, `stats['courier.carried']`, carry budget (`maxCarryBytes`, default 20 MB, TTL 14 days).

What a carrier actually knows about an envelope: its size, its expiry, how many hops it has taken, and a
2-byte recipient hint. **No sender, no recipient, no content.** The design must make that privacy obvious.

## PROMPT

```
Screen: "carry pouch" for jaal — sealed letters you're carrying for strangers — Off-Grid Zine style.

Header: "carry pouch" in Archivo Black with an ultra-blue #3D5AFE highlighter. Below it, a big COURIER CLOUT badge: a scalloped-edge stamp (like a postage stamp) in pink with "17" in Archivo Black 56px and "letters delivered by you" in mono. Next to it a smaller stamp "rank: night owl courier".

Pouch visual: a canvas messenger bag illustration (thick black outlines, flat kraft colour) with a stack of 6 sealed envelopes peeking out, each with a pink wax seal and a mono label strip: "#a91f · 2.1kb · 3 hops · 11d left". Envelopes have NO names on them, just "to: ?" and "from: ?" stamped in grey.

A storage meter: a horizontal bar made of 20 square cells with a 3px border, 6 filled blue: "using 3.1 / 20 mb for strangers" and a small "settings" link.

A "how it works" zine strip of 3 tiny panels with hand-drawn doodles: "1. someone seals a letter" → "2. your phone carries it (can't read it)" → "3. it reaches them, you get clout".

Bottom: a recently delivered list with lime stamps: "delivered · 4h ago · you were hop 2 of 3".
```

## Iterate
- "make the clout badge feel like a scout merit badge"
