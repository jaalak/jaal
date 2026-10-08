# 14 — Explore (friends-of-friends)

**Purpose:** discovery without algorithms or servers. You see posts your phone already holds from people
your follows follow, and from people you met nearby.
**Route:** `/explore` · **Backed by:** `watchAllPosts` minus `watchHomeFeed`, `ReplicationPolicy` (follows of follows, up to 150), `posts.hops`.

## PROMPT

```
Screen: explore / discover for jaal, Off-Grid Zine style, bottom nav with explore active.

Header: "explore" in Archivo Black with a lime swipe. A search input (square, 3px border): "search what's on your phone" with a grey mono hint "no cloud. only what's reached you."

Filter chips (square, bordered) as a horizontal row: "all", "1 hop away", "2 hops", "nearby today", "#zines", "#trek".

A distance ruler: a horizontal strip like a measuring tape (yellow tape with tick marks) labelled "closer ← → further (hops)".

Masonry grid of posts as pasted cutouts: 2 columns, varied heights, each tile with a 3px border and slight tilt, some with tape strips, each with a tiny red postmark corner showing hops ("2h", "3h"). Mixed content: photos, a text-only card on lime, a video tile with a chunk progress chip.

A "people around your people" row: horizontal polaroids with "followed by maya + 2" in Caveat and small "follow" buttons.
```

## Iterate
- "make it feel like flipping through a zine library shelf"
