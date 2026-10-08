# 06 — Sticker slap (reaction interaction)

**Purpose:** the like replacement. Long-press or tap "stick", pick a sticker, drag it onto the photo, and let go to slap it.
**Backed by:** `JaalNode.react(postId, sticker, x, y, rot)`. Position is stored per-mille
(0–1000) and rotation in whole degrees (−45..45). One sticker per person per post (last one wins). Dragging
it off removes it (`sticker: null`).
**Built-in set:** `heart fire lol real slay mid cry peak w skull`.

## PROMPT

```
Screen: sticker reaction picker for jaal, Off-Grid Zine style. Show 3 frames side by side as a storyboard.

FRAME 1 "pick": the post photo is dimmed slightly. A bottom sheet with a 3px top border slides up, titled "stick something" (Archivo Black). A grid of 10 die-cut stickers, each with a thick white outline plus a 3px black border and slight rotation: "heart" (pink), "fire" (orange-red), "lol" (yellow), "real" (lime), "slay" (pink), "mid" (grey), "cry" (blue), "peak" (lime), "w" (blue), "skull" (white). Above the grid, a "your stickers" row with a dashed "+ make one (soon)" slot.

FRAME 2 "drag": the user's finger drags a lime "real" sticker over the photo. The sticker is enlarged 1.1x with a hard drop shadow offset (lifted). Ghost outlines show where other people's stickers are. A small mono hint at the bottom: "let go to slap it".

FRAME 3 "slapped": the sticker lands at an angle with a tiny comic "thwack" burst (3 short ink lines). A lime toast at the bottom with a 3px border: "stuck. it'll spread as phones meet." The sticker count chip "real 8" ticks up.

Annotate motion: overshoot 220ms cubic-bezier(.2,1.6,.4,1); drag off the photo to peel off.
```

## Iterate
- "make the stickers look like vinyl laptop stickers with slight glossy highlights"
