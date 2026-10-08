# 07 — New post (compose)

**Purpose:** create a photo, video or text post. Media is compressed, hashed and chunked so it can travel piece by piece.
**Route:** `/new` · **Backed by:** `JaalNode.post(text, media)`, `Chunker.manifestFor` (milestone 2: compression and encryption).
Caption max 2200 chars.

## PROMPT

```
Screen: create a new post for jaal, Off-Grid Zine style.

App bar: "x" close on the left, "new drop" title, and a lime "post" button (small, 3px border, hard 3px shadow) on the right.

Top half: the selected photo in a 4:5 frame with a 3px border, taped onto the page with two yellow tape strips at the top corners. Below it, a horizontal filmstrip of 4 thumbnails from the gallery (square, bordered), the first selected with a lime 3px outline, plus a square "camera" tile and a square "video" tile.

Under the media: a chip row in Space Mono showing what will travel: "photo · 1.8 mb → 412 kb · 7 chunks". Next to it a small toggle "crunch more (travels faster)" in Caveat.

Caption field: large square input, paperDeep fill, placeholder "say something offline…", a character counter "0/2200" in mono at the bottom-right.

"WHO GETS IT" card (tilted 1°, tape on the corner): radio options with square radio boxes:
- "followers (travels through the mesh)" (selected)
- "close friends (sealed)" — with a small lock icon and grey "soon" chip
Under it a hand-note in blue: "it leaves your phone when someone walks by. could be 1 minute, could be 2 days."

Bottom: a postmark preview stamp in red, faded: "0 hops · not sent yet".
```

## Iterate
- "show the photo being cut into puzzle-piece chunks in a small diagram"
