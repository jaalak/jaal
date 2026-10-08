# 03 — Your 24 words (recovery phrase)

**Purpose:** back up the root key. With no server, losing it means losing your identity.
**Route:** `/welcome/phrase` · **Backed by:** `RootIdentity.recoveryPhrase` (BIP39, 24 English words).

## PROMPT

```
Screen: recovery phrase backup for jaal, Off-Grid Zine style.

App bar: "your 24 words".

Headline in Archivo Black 26px: "write these down." and on the next line "like, on paper." Under it, a red #D7263D Caveat hand-note: "lose the phone + lose these = lose you. no reset button out here."

A 3-column grid of 24 numbered word tiles. Each tile: small square card, 3px black border, hard 3px shadow, alternating paper/paperDeep fill, each slightly rotated (-1°, 0°, 1°). The number is grey Space Mono ("01"…"24"), the word bold Space Mono ("abandon", "amount", "liar"…). The grid looks like a sheet of labels peeled from a label maker.

A "hide words" eye toggle in the top-right of the grid. A big dashed "cut here ✂" line under the grid.

Below: a checkbox (square, 3px border, lime check) "i wrote them down somewhere safe". A full-width lime button "enter jaal", disabled (45% opacity) until checked. A small grey text link: "skip for now (risky — we'll nag you)".

Add a second state: the words blurred behind frosted halftone with "tap to reveal (make sure nobody's watching)".
```

## States
- Hidden (default on screenshot or screen share) / revealed.
- Optional quiz step (later): "tap word #7, #13, #22".

## Iterate
- "make the tiles look like label-maker tape (embossed letters)"
