# 16 — Network Lab (developer tool, optional restyle)

**Purpose:** already built in Flutter (`apps/mobile/lib/features/lab/`). Spawn virtual peers, move them
in and out of range, tune latency and flakiness, run chatter, and watch the wire log. Use this prompt if you want
Stitch to restyle it. It is a dev tool, so it can be denser than the social screens.
**Backed by:** `NetworkLab` (`packages/jaal_sim`): `addPeer`, `setLink(LinkConfig(up, latency, dropChance))`,
`fullMesh`, `chain`, `shuffleProximity`, `startChatter`, `snapshot()`, `LogBuffer`.

## PROMPT

```
Screen: "network lab" developer tool for jaal, Off-Grid Zine style but denser, like a hacker zine.

App bar: "network lab" plus square tabs "peers | you | wire" with the lime active tab.

"you" card in lime: "you ·as3n" with mono chips "2 live links", "14 feeds", "320 events", "carrying 3", "clout 5" (pink).

Control row of small square buttons: "spawn", "mesh", "chain", "shuffle", "apart", "follow-web", "chatter ▶".

Peer cards (paper, 3px border, hard shadow, slight tilt): polaroid initial avatar, name "maya", mono "·k7f2 41 posts 2 carried", Caveat status "syncing with you" (blue) or "out of range" (grey), and a square switch "near you".

A peer detail sheet: per-link rows "⇄ arjun" with a switch, a latency slider "0–2000ms" and a flaky slider "0–50%".

Wire tab: a dense terminal-like list in Space Mono 11px on paper, colour-coded: blue [post], pink [dm], black [link], grey sync logs, red warnings.
```
