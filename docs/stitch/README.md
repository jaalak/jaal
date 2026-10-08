# Jaal × Google Stitch — UI/UX prompt pack

This folder is everything Google Stitch needs to design Jaal's front end in the
**Off-Grid Zine** style. The Flutter app's backend, protocol and Network Lab are
already built. The social screens are built **after** Stitch, to match what you
generate here.

```
docs/stitch/
  README.md               ← you are here (workflow)
  00-design-system.md     ← paste FIRST in every Stitch project
  tokens.json             ← exact values; shared with apps/mobile/lib/design/tokens.dart
  screens/01…19-*.md      ← one prompt per screen, in build order
  flows.md                ← how screens connect (for prototyping / Figma)
  exports/                ← what Stitch produced: NN-*/screen.png (+ screen.html), DESIGN.md
```

The Flutter implementation of every export lives in `apps/mobile/lib/features/`. Render it with
`flutter test test_goldens --update-goldens` and compare `apps/mobile/test_goldens/goldens/*.png`
against `exports/*/screen.png`.

## Workflow

1. **New Stitch project** → choose *Mobile* (it designs at about 412×915 for Android).
2. **Paste `00-design-system.md`** (the block inside "PROMPT") as the first message.
   Ask Stitch to generate the *style tile* screen it describes. Check it before moving on:
   paper background, 3px black borders, hard 6px unblurred shadows, square corners,
   lime/pink/blue pops, lowercase copy. If anything comes back soft, rounded or blurred, reply:
   *"redo with square corners, 3px solid #0A0A0A borders and hard 6px offset shadows with zero blur."*
3. **Screens:** paste each `screens/NN-*.md` prompt **in the same project**, in order,
   so Stitch keeps the style consistent. Generate 2–3 variants and keep the best one.
4. **Refine** using the *"Iterate"* lines at the bottom of each screen file.
5. **Dark mode ("void"):** once the light set is done, use the prompt in
   `00-design-system.md § dark mode` on each screen.
6. **Export:** *Copy to Figma* (preferred) or *Export code* (HTML/Tailwind). Put exports in
   `docs/stitch/exports/NN-name/` (PNG + HTML) and tell Claude. The Flutter screens are then
   built to match, using the same tokens.

## Rules Stitch tends to break (watch for these)

| Stitch default | Jaal rule |
|---|---|
| Rounded cards (12–24px) | **0px corners.** Only stickers and status dots are round. |
| Soft, blurred shadows | **Hard offset shadow, 0 blur**, black (#0A0A0A). |
| Title Case Buttons | **lowercase everything** except @handles and names. |
| Gradient / glassmorphism | **Flat paper + ink.** Texture comes from xerox grain and halftone, never gradients. |
| Perfect alignment | Cards **tilt 1–2°**, tape strips hold things down, and stamps are rotated. |
| Generic heart for like | **Stickers** you slap onto the photo (see screen 06). |
| Wi-Fi / signal icons | Never show connectivity as missing. Show **people nearby** and **hops**. |

## Product context (give this to anyone designing)

Jaal (Hindi/Sanskrit for *net*, *mesh*) is an Instagram-like social app that works
**without internet or cell signal**. Phones sync directly with phones nearby
(Bluetooth or Wi-Fi Direct). A post can travel phone → phone → phone to reach
you. That is **store-and-forward**: strangers' phones carry sealed, encrypted
messages for you without being able to read them. The design should make this
feel **magical and a bit rebellious**, not broken or "offline-degraded".

Four signature moments, which must be visible in the designs:

1. **Hop postmarks.** Every post wears a red rubber-stamp postmark showing how many
   phones it passed through and how long it travelled: `3 hops · 2d 4h`.
2. **Sticker reactions.** Instead of a heart, you drag a sticker and slap it onto
   the photo at an angle. Other people's stickers pile up on the post.
3. **Nearby radar wall.** The top of the home feed is a corkboard of polaroid
   cut-outs of people *physically near you right now*, with a masking-tape strip
   reading `syncing…` while phones swap.
4. **Carry pouch.** A stack of sealed envelopes you are carrying for strangers.
   When one is delivered you earn **courier clout**.

Safety, which must feel on-brand rather than corporate:

- **Moderators** are invite-only. You need **3 moderators to scan your QR in person** (screen 17).
  One moderator's vote hides a toxic person; a **second** removes them from every phone (screen 18).
- **No impersonation.** Nobody can post as you without your key. Lookalike accounts get a hazard-tape
  warning, people you've met show a "met irl ✓" stamp, and every handle carries its key fingerprint (screen 19).
