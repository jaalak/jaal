# 09 — Meet in person (QR swap / verify)

**Purpose:** the trust anchor. Scan someone's QR to learn their root key (and DM key) offline, verify their fingerprint, and follow them.
**Backed by:** QR payload = `jaal:1:<rootId>:<dmKey>:<handle>` (milestone 2). Followed by `follow(root)`, and a session that starts once they're in range.

## PROMPT

```
Screen: "meet" — exchange identities in person by QR, for jaal, Off-Grid Zine style. Show two states side by side.

STATE A "my code": a large QR code printed in black on a paper card with a 3px border and a hard shadow, taped at the top with two yellow tape strips. Above it in Archivo Black: "scan me". Below it in Space Mono: "@maya.offgrid·k7f2", and a 4x4 grid of the fingerprint as emoji/word chips ("k7f2 · lime · fox · 42") for reading aloud. A blue Caveat hand-note: "compare the 4 letters out loud. that's how you know it's really them." A toggle tab at the top: "my code | scan".

STATE B "scan": a full-width camera viewfinder framed by thick black corner brackets (zine crop marks). A lime scanning line. After the scan, a card slaps in from the bottom (tilted 2°): polaroid "arjun", "@arjun_rn·x91c", a match check "fingerprint matches what they said? ✓ yes / ✗ no", and buttons "follow + verify" (lime) and "just follow" (paper). A small stamp "met irl · 14 oct" in red.
```

## Iterate
- "make the qr look like a sticker you could print and stick on a laptop"
