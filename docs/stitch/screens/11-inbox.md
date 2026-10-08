# 11 — Inbox (DMs as letters)

**Purpose:** conversation list. Every DM is a sealed letter that may be travelling.
**Route:** `/inbox` · **Backed by:** `JaalDatabase.watchInbox()` (latest message per peer), `messages.delivered`, `messages.outgoing`.

Delivery states (from the protocol):
- `sealed` = queued on your phone, not yet handed to anyone
- `in a stranger's pocket` = a carrier took the envelope (you can't know who)
- `delivered` = a receipt (ack secret) came back
- `received` = incoming

## PROMPT

```
Screen: inbox / direct messages list for jaal, Off-Grid Zine style, bottom nav with inbox active.

Header: "letters" in Archivo Black 36px with a pink #FF3EA5 highlighter swipe. Right: a square "new letter" button (pencil + envelope icon).

A filter row of square chips: "all", "unread", "in transit" (blue), "delivered".

List: each conversation is an ENVELOPE-shaped card (kraft-paper tint #E9E3D3, 3px border, flap line drawn across the top, hard shadow), slightly tilted alternately:
- polaroid avatar, "zoe", "@zoe.zine·m3qa" in mono, last message preview "bring the stickers", time "4m".
- A delivery status stamp on the right side of each envelope:
  - pink wax-seal dot + "new" (unread)
  - blue mono stamp "in a stranger's pocket · 1d" with a small walking-person icon
  - red postmark "delivered · 2 hops"
  - grey "sealed · waiting for someone to walk by"
One envelope is shown opened (flap up) to indicate read.

An empty-state variant at the bottom of the artboard: a halftone mailbox drawing: "no letters. send one; it'll find a way."
```

## Iterate
- "add tiny stamps (postage) with hand-drawn icons on each envelope"
