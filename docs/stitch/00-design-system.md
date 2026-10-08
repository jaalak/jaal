# 00 — Design system (paste first)

Paste the PROMPT block as the **first message** of the Stitch project. It sets
the visual language every later screen inherits.

## PROMPT

```
Design system for "jaal", an Android social app (Instagram-like: posts, photos, videos, profiles, DMs) that works with NO internet: phones sync directly with nearby phones and carry each other's posts and sealed messages. Style name: OFF-GRID ZINE. Gen-Z, neo-brutalist, photocopied DIY zine. It must NOT look like a generic app: no rounded cards, no soft shadows, no gradients, no glassmorphism.

FIRST generate one "style tile" screen showing: colour swatches, type scale, buttons (primary/secondary/disabled/pressed), an input, a chip, a card, a sticker, a postmark stamp, a tape strip, and a polaroid avatar.

COLOURS (flat, no gradients):
- paper #F4F1E8 (light background), paperDeep #E9E3D3 (inputs, sunken areas)
- ink #0A0A0A (all text, ALL borders, ALL shadows)
- acid lime #C6FF00 (primary buttons, "synced", highlighter swipes behind headings)
- hot pink #FF3EA5 (stickers, DMs, notifications)
- ultra blue #3D5AFE (links, mesh lines, carry pouch)
- tape yellow #F9E27A at 85% opacity (masking tape strips with ragged ends)
- stamp red #D7263D (postmarks, destructive actions)
- xerox grey #8A857A (secondary text, timestamps)

TYPE:
- Display: Archivo Black, lowercase, tight leading (0.95), slight negative tracking. Sizes 56/36/26/20.
- UI/body: Space Grotesk 16/14/13, medium; buttons bold.
- Mono: Space Mono 11-13 for key fingerprints (@maya·k7f2), hop counts, timestamps, postmarks.
- Hand: Caveat 22, blue or red, for handwritten asides and polaroid captions.
- ALL copy lowercase except names and @handles. Voice: unbothered, warm, a bit smug about not needing internet ("no wifi? no problem.").

SHAPE & DEPTH:
- Corners: 0px everywhere (cards, buttons, inputs, sheets). Only stickers and status dots are round.
- Borders: 3px solid #0A0A0A on every card, button, input, avatar frame. Hairline dividers 1.5px.
- Shadows: hard offset 6px 6px, ZERO blur, #0A0A0A. Small elements 3px 3px. Pressed state: the shadow disappears and the element shifts 6px down-right.
- Cards sit slightly rotated (-2° to +2°), as if pasted by hand. Masking-tape strips pin some cards and photos.

TEXTURE: subtle xerox grain over every background (6% noise). Halftone dot pattern on empty states and image placeholders. Occasional cut-out/torn paper edges.

SIGNATURE COMPONENTS:
1. Postmark: circular red rubber stamp, rotated -12°, mono text "3 hops" over a line over "2d 4h", slightly faded like real ink.
2. Sticker: die-cut pill or blob with a thick white outline and a black 3px border, bold word or emoji ("fire", "real", "slay", "skull", "w", "peak"), stuck at an angle on photos.
3. Polaroid avatar: square photo in a white frame with a thicker bottom edge, handwritten name in Caveat, lime dot when the person is nearby/syncing.
4. Tape strip: yellow translucent masking tape with ragged ends and optional mono label ("syncing…").
5. Highlighter heading: lowercase Archivo Black word with a lime marker swipe behind its lower half.
6. Sealed envelope: kraft-paper envelope icon with a wax-seal dot (pink), for DMs.

ICONS: thick 2.5px outlined, slightly hand-drawn, square line caps. Never show "no signal"/"offline" icons; show people and hops instead.

MOTION NOTES (annotate): taps are steppy (shadow collapses in 80ms); cards slap down into place; stickers overshoot when stuck.

Android, 412x915, bottom navigation with 5 square tabs: home, explore, + (new), inbox, you. The active tab is an acid-lime block with a black border.
```

## Dark mode ("void") prompt — use per screen after the light set

```
Make a dark "void" version of this screen with the same layout: background #0A0A0A, raised surfaces #1A1A1A, text and all borders and hard shadows become paper #F4F1E8. Keep the acid lime #C6FF00, hot pink #FF3EA5 and ultra blue #3D5AFE pops unchanged. Headline highlighter swipes cover the full word so the black text on lime stays legible. Keep 0px corners and the zero-blur hard shadows. Grain stays at 6%.
```

## Accessibility guardrails (include if Stitch drifts)

```
Keep body text at least 14px with 4.5:1 contrast. Never put white text on lime or pink; use ink #0A0A0A on all pops. Tap targets at least 48x48. Tilted elements: max 2°, and never tilt text inputs or long body text.
```
