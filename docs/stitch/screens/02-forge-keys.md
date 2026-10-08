# 02 — Forge your keys (create identity)

**Purpose:** create a cryptographic identity plus a first profile.
**Route:** `/welcome/create` · **Backed by:** `SessionNotifier.create(name, handle)` → `LocalIdentity.createAndSave` + `JaalNode.setProfile`.

**Data rules (from the protocol):** display name is 1–50 chars. The handle matches `^[a-z0-9_.]{2,24}$`
and is **not globally unique**, because there's no server. The app always shows it with a 4-char key
fingerprint: `@maya·k7f2`.

## PROMPT

```
Screen: "new node" (create account) for jaal, Off-Grid Zine style.

Top app bar: back arrow, title "new node" in Archivo Black 26px, a 3px black rule under the bar.

Content on paper with grain:
- A handwritten blue Caveat note, slightly rotated: "your keys are made on this phone. no server ever sees them."
- A polaroid avatar placeholder (dashed 2px border, halftone fill, "+ add a face" in Caveat) taped at -3°.
- Input "display name" (paperDeep fill, 3px black border, 0 radius, bold small label above).
- Input "handle" with an "@" prefix. Below it, a live preview chip in Space Mono showing "@maya·k7f2" in a 1.5px-bordered box, and helper text: "not unique worldwide — the 4 letters after the dot are your key's fingerprint."
- A small ZINE NOTE card (tilted 1°, tape on the top corner) explaining in 2 lines: "a handle is a nickname. your key is your id. people verify you by scanning your qr in person."

Bottom: a full-width lime button "forge my keys" with a key icon, hard 6px shadow.

Also show the loading state next to it: the button reads "forging keys…" and a small stamping animation annotation ("stamp thumps 3x").
```

## States
- Validation error: input border turns stamp red #D7263D, and a red hand-note appears: "2–24 chars: a-z 0-9 _ ."
- Loading: "forging keys…"

## Iterate
- "make the fingerprint preview feel like a laundry tag / luggage tag"
