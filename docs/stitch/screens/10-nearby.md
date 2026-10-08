# 10 — Nearby (full radar wall)

**Purpose:** who's physically around right now, what's swapping, and how fast.
**Route:** `/nearby` · **Backed by:** `SyncEngine.visiblePeers` (in range), `sessions` (live, with `SessionStats`:
events in/out, envelopes), `peers_seen` (encounters, last seen).

## PROMPT

```
Screen: "nearby" — the full radar wall of people physically around you, for jaal, Off-Grid Zine style.

Header: "nearby" in Archivo Black with a lime highlighter, and a mono status strip on tape: "3 in range · bluetooth + wifi direct".

Main: a large corkboard area (kraft-paper texture, 3px border) with polaroids pinned at different angles and distances. Closer = bigger polaroid. Each polaroid has a handwritten name, a lime "syncing" dot or a grey "just passed by" dot, and a mono mini-label like "↓12 ↑3". Thin blue hand-drawn string lines connect the polaroids to a center polaroid labelled "you" (like string lights or a detective board).

One polaroid of a stranger (not followed) is shown with a halftone silhouette and "someone · @??·p0rt" — "carrying 2 of your letters" in blue Caveat.

Bottom sheet (peek): "swapping with arjun" with a segmented progress bar of blue chunks, rows in Space Mono: "posts ↓ 12", "stickers ↓ 30", "sealed letters ↑ 2", "receipts ↓ 1", and a lime "done ✓" stamp when finished.

Bottom: a pill toggle "be discoverable: on" with a lime switch (square thumb), and grey text "your phone advertises a random id, not your name".
```

## States
- **Alone:** an empty corkboard with only "you" in the center: "nobody around. go touch grass (and people)."

## Iterate
- "more like a conspiracy board with red string"
