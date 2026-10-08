# Flows (for prototyping in Stitch / Figma)

```
first launch
  01 welcome ──"make me a node"──▶ 02 forge keys ──▶ 03 recovery phrase ──▶ 04 home
            └─"i have a phrase"──▶ (restore: phrase + name/handle) ──────────▶ 04 home

bottom nav: 04 home · 14 explore · 07 new · 11 inbox · 08 you (own profile)

04 home
  radar wall polaroid ──▶ 08 profile (other)
  radar wall "+ meet" ──▶ 09 qr meet
  radar wall (tap strip) ──▶ 10 nearby
  post photo (long-press / "stick") ──▶ 06 sticker slap
  post ──▶ 05 post detail
  top-right envelope ──▶ 11 inbox
  top-right pouch ──▶ 13 carry pouch

08 profile ──"seal a note"──▶ 12 chat thread
08 profile ──"qr"──▶ 09 qr meet
08 profile (own) ──⚙──▶ 15 settings ──"network lab (dev)"──▶ 16 network lab
11 inbox ──▶ 12 chat thread

08 profile (own) ──"become a moderator"──▶ 17 become moderator (collect 3 vouches)
08 profile (other, as mod) ──⋯ "moderate"──▶ 18 moderation desk (confirm sheet)
15 settings ──"moderation desk" (mods only)──▶ 18
any profile/post/chat ──▶ 19 states: lookalike warning · met irl ✓ · petname · ★ mod · flagged · removed
```

## Cross-screen states to design once and reuse

| State | Treatment |
|---|---|
| nobody nearby | dashed empty corkboard + "your posts are waiting in your pocket" |
| media arriving | halftone placeholder + "chunks 3/9 · resuming" segmented bar |
| deleted content | shredded-paper strip + "deleted by author" |
| in transit (DM) | blue mono stamp "in a stranger's pocket · 1d" |
| delivered | red postmark "delivered · 2 hops" |
| blocked person | xerox-washed grey page |
| new from mesh | lime tape "↓ 7 new from the mesh" |
| lookalike | red hazard-tape banner "looks like @maya·k7f2 — different key" |
| flagged by a mod | hazard-taped card "hidden by a moderator · tap to view anyway" |
| removed | torn flyer + "REMOVED BY MODERATORS" stamp; own app: grey "you've been removed." page |
