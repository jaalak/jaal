# 05 — Post detail + comments

**Purpose:** one post up close: full sticker pile, travel history, comments.
**Route:** `/post/:id` · **Backed by:** `posts`, `reactions` (per-author LWW), `comments` (threaded via `parent`),
`tombstones` (deleted state), `post.edit` (edited stamp).

## PROMPT

```
Screen: post detail for jaal, Off-Grid Zine style.

App bar: back arrow, "post" title, ⋯ menu.

Top: the post card at full width (no tilt here, for readability): author row "zoe @zoe.zine·m3qa · 5h", a big 4:5 photo (zine stall at a night market) with ~8 stickers slapped on it at random angles and positions ("fire", "slay", "peak", "skull", emoji stickers). The postmark stamp is in the corner: "2 hops · 5h".

Below the photo: caption, and a small "edited" stamp chip (red outline, mono) next to it.

"TRAVEL LOG" strip: a horizontal ticket-stub card with a dashed perforation, Space Mono text: "left zoe · 14:02 → 1 phone → you · 19:10" plus a small hand-drawn route line with 2 dots. Caption in grey: "carriers stay anonymous."

STICKER SHELF: a horizontal scroll of sticker chips with counts: "fire 12", "real 7", "skull 3", "slay 2", and the user's own sticker highlighted with a lime outline "yours".

COMMENTS: a list on paperDeep, each comment a mini card with a 1.5px border: avatar square, "@arjun_rn·x91c", text, a "2h" mono time. One reply is indented with a hand-drawn blue curved arrow. One comment shows the deleted state: a shredded-paper strip graphic with "deleted by author" in mono.

Bottom: a fixed composer: square input "add a comment (it'll travel with the post)" with a 3px border and a lime square send button.
```

## Iterate
- "make the travel log look like a train ticket"
