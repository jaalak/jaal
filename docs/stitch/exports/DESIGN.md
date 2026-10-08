---
name: Off-Grid Zine
colors:
  surface: '#fcf9f0'
  surface-dim: '#dddad1'
  surface-bright: '#fcf9f0'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#f6f3ea'
  surface-container: '#f1eee5'
  surface-container-high: '#ebe8df'
  surface-container-highest: '#e5e2da'
  on-surface: '#1c1c17'
  on-surface-variant: '#434933'
  inverse-surface: '#31312b'
  inverse-on-surface: '#f4f1e8'
  outline: '#747a60'
  outline-variant: '#c3caac'
  surface-tint: '#4e6700'
  primary: '#4e6700'
  on-primary: '#ffffff'
  primary-container: '#c6ff00'
  on-primary-container: '#587300'
  inverse-primary: '#a6d700'
  secondary: '#b3006e'
  on-secondary: '#ffffff'
  secondary-container: '#db1989'
  on-secondary-container: '#fffbff'
  tertiary: '#2848ee'
  on-tertiary: '#ffffff'
  tertiary-container: '#eaeaff'
  on-tertiary-container: '#3856fa'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#bef500'
  primary-fixed-dim: '#a6d700'
  on-primary-fixed: '#151f00'
  on-primary-fixed-variant: '#3a4d00'
  secondary-fixed: '#ffd9e5'
  secondary-fixed-dim: '#ffb0ce'
  on-secondary-fixed: '#3d0022'
  on-secondary-fixed-variant: '#8c0055'
  tertiary-fixed: '#dee0ff'
  tertiary-fixed-dim: '#bbc3ff'
  on-tertiary-fixed: '#000f5d'
  on-tertiary-fixed-variant: '#002ccd'
  background: '#fcf9f0'
  on-background: '#1c1c17'
  surface-variant: '#e5e2da'
typography:
  display-xl:
    fontFamily: Space Grotesk
    fontSize: 56px
    fontWeight: '700'
    lineHeight: 54px
    letterSpacing: -0.04em
  display-xl-mobile:
    fontFamily: Space Grotesk
    fontSize: 40px
    fontWeight: '700'
    lineHeight: 40px
    letterSpacing: -0.04em
  headline-lg:
    fontFamily: Space Grotesk
    fontSize: 36px
    fontWeight: '700'
    lineHeight: 36px
    letterSpacing: -0.03em
  headline-md:
    fontFamily: Space Grotesk
    fontSize: 26px
    fontWeight: '700'
    lineHeight: 28px
    letterSpacing: -0.02em
  headline-sm:
    fontFamily: Space Grotesk
    fontSize: 20px
    fontWeight: '700'
    lineHeight: 22px
    letterSpacing: -0.02em
  body-lg:
    fontFamily: Space Grotesk
    fontSize: 16px
    fontWeight: '500'
    lineHeight: 22px
  body-md:
    fontFamily: Space Grotesk
    fontSize: 14px
    fontWeight: '500'
    lineHeight: 20px
  body-sm:
    fontFamily: Space Grotesk
    fontSize: 13px
    fontWeight: '500'
    lineHeight: 18px
  label-code-lg:
    fontFamily: Space Mono
    fontSize: 13px
    fontWeight: '700'
    lineHeight: 16px
    letterSpacing: 0.02em
  label-code-sm:
    fontFamily: Space Mono
    fontSize: 11px
    fontWeight: '400'
    lineHeight: 14px
    letterSpacing: 0.04em
  hand-note:
    fontFamily: Caveat
    fontSize: 22px
    fontWeight: '600'
    lineHeight: 24px
spacing:
  gutter: 0.75rem
  margin: 1rem
  space-xs: 0.25rem
  space-sm: 0.5rem
  space-md: 0.75rem
  space-lg: 1.25rem
  space-xl: 2rem
---

## Brand & Style

This design system delivers a tactile, neo-brutalist peer-to-peer aesthetic rooted in physical DIY culture, photocopied punk zines, and resilient off-grid communication. Built for an Android mesh networking social client, the visual direction deliberately rejects corporate softness, glossy depth, frosted glass, and seamless tech tropes.

### Personality & Tone
- **Atmosphere:** Scrappy, decentralized, analogue, tactile, underground.
- **Voice:** Unbothered, warm, and subtly smug about sidestepping telecommunications monopolies ("no wifi? no problem.", "passed through 4 pockets to reach you.").
- **Grammar & Casing:** Strict lowercase across all UI copy, actions, and system prompts. Only real personal names and `@handles` retain proper capitalization.
- **Visual Mechanics:** Raw photocopy noise, halftone dot distributions on empty canvases, heavy black technical borders, mechanical stamp impressions, masking tape attachments, and hard offset ink drop shadows.

## Colors

The palette is derived from physical paper stocks, Xerox carbon toner, fluorescent stationery, and stamp inks. High-contrast layering is mandatory: every colored element is bounded by solid black ink borders.

### Palette Tokens
- **Paper Background (`#F4F1E8`):** The primary light canvas; mimics pulpy newsprint and uncoated zine paper. Overlaid globally with a 6% monochromatic Xerox grit texture.
- **Paper Deep (`#E9E3D3`):** Recessed canvas tone for input fields, textareas, sunken container wells, and inactive panel surfaces.
- **Ink (`#0A0A0A`):** The structural absolute. Used for all core text, borders (standard 3px, hairline 1.5px), hard drop shadows, and technical linework.
- **Acid Lime (`#C6FF00`):** High-voltage signal color for primary action buttons, active navigation blocks, mesh sync confirmations, and highlighter marker swipes behind titles.
- **Hot Pink (`#FF3EA5`):** Expressive accent reserved for direct messaging badges, unread indicators, die-cut stickers, and digital wax seals.
- **Ultra Blue (`#3D5AFE`):** Network infrastructure color; applied to interactive links, mesh topology lines, signal range meters, and technical packet pathways.
- **Tape Yellow (`rgba(249, 226, 122, 0.85)`): Translucent masking tape strips with jagged CSS clip-paths used to visually fasten cards and photos.
- **Stamp Red (`#D7263D`):** Archival rubber stamp pigment for destructive actions, hops counters, delivery status stamps, and urgent relays.
- **Xerox Grey (`#8A857A`):** Muted toner for metadata, packet timestamps, secondary body labels, and structural guidelines.

## Typography

Typography balances raw industrial monospaced telemetry with punchy grotesk display weights and informal script marginalia.

### Typographic Hierarchy & Rules
- **Display Weights:** Headlines must render strictly in lowercase with tight leading (line-height around 0.95 to 1.0) and negative tracking to simulate compact rubdown letraset or woodtype blocks.
- **Handwritten Annotations:** Caveat at 22px is reserved for marginalia, author side-notes, Polaroid footer captions, and playful contextual nudges. Color must always be Ultra Blue (`#3D5AFE`) or Stamp Red (`#D7263D`).
- **Telemetry & Identity:** Space Mono is mandatory for cryptographic key fingerprints (e.g. `@maya·k7f2`), hop metrics, battery voltage, byte counters, and postmark data blocks.

## Layout & Spacing

Designed for Android standard viewport dimensions (412x915 dp), the grid is compact, rigid, and dense.

### Layout Mechanics
- **Grid Structure:** 4-column fluid layout on mobile viewports with tight 12px (`0.75rem`) gutters and 16px (`1rem`) exterior canvas margins.
- **Rhythm:** Spacing follows a 4px/8px industrial baseline. Layout elements prioritize visible density; excessive luxury whitespace contradicts the compact DIY zine format.
- **Safe Zones:** Bottom navigation bar maintains a fixed height of 68px, pinned above the Android system navigation bar with zero curved cutouts or floating margins.

## Elevation & Depth

No soft ambient blurs, directional gradient simulations, or translucent glass layers are permitted. Physical separation is established solely via hard black offset drop shadows and overlapping cut-and-paste layering.

### Depth Mechanics
- **Standard Card / Container Elevation:** `box-shadow: 6px 6px 0px 0px #0A0A0A;`
- **Compact UI / Chips / Small Buttons:** `box-shadow: 3px 3px 0px 0px #0A0A0A;`
- **Active / Pressed State Collision:** On press or active touch, the shadow collapses entirely (`box-shadow: 0px 0px 0px 0px #0A0A0A;`) while the element physically translates down and right (`transform: translate(6px, 6px);` or `3px, 3px` for compact controls), giving the instant sensation of clicking down a physical microswitch.
- **Zine Paste Angling:** Surface cards in scroll feeds must feature subtle randomized angular offsets between `-2deg` and `+2deg` using CSS transforms. Adjacent cards must alternate slight negative and positive rotation to mimic hand-pasted collages.

## Shapes

The geometric rule across the design system is hard zero: `border-radius: 0px` on all structural interfaces, buttons, modals, input containers, bottom sheets, and view containers.

### Shape Exceptions
- **Die-cut Stickers:** Freeform pill or scalloped organic blobs with heavy 3px black strokes and 2px inner white bleed lines.
- **Hardware Status Dots:** Strict circular forms (e.g., 8px × 8px sync status indicators, peer proximity beacons).
- **Postmark Stamps:** Geometric 56px–72px circular borders stamped over rectangular paper edges.

## Components

### Buttons
- **Primary:** Acid Lime (`#C6FF00`) background, 3px solid `#0A0A0A` border, bold Space Grotesk lowercase text, 6px 6px hard black shadow. Collapses down-right on active tap.
- **Secondary:** Paper (`#F4F1E8`) background, 3px solid `#0A0A0A` border, 3px 3px hard black shadow.
- **Destructive:** Stamp Red (`#D7263D`) background with white Space Grotesk text, 3px solid `#0A0A0A` border.

### Inputs & Text Areas
- Background: Paper Deep (`#E9E3D3`), 3px solid `#0A0A0A` border. Zero radius.
- Inset feeling: `box-shadow: inset 3px 3px 0px 0px rgba(10, 10, 10, 0.15)`.
- Placeholder text: Xerox Grey (`#8A857A`), Space Mono lowercase. Focus state swaps border to 4px `#0A0A0A` with Acid Lime label tag.

### Cards & Feed Items
- Background: Paper (`#F4F1E8`), 3px solid `#0A0A0A` perimeter border, 6px 6px hard shadow.
- Rotated slightly between `-1.5deg` and `+1.5deg`.
- Fastened at top or corners by simulated Tape Strips: translucent yellow (`#F9E27A` at 85% opacity), 18px height, ragged ends rendered with polygonal CSS clip-path masks.

### Polaroid Avatar
- Square user photograph held within an off-white photo frame with an exaggerated bottom border (12px on sides/top, 28px bottom).
- Handwritten username or handle inscribed on the bottom lip in Caveat (`#3D5AFE`).
- An 8px Acid Lime dot anchored to the upper-right corner indicates active mesh connectivity.

### Postmark Rubber Stamp
- Circular 64px diameter vector stamp rotated at `-12deg`.
- Double-ring border in faded Stamp Red (`#D7263D`) with semi-transparent distress mask.
- Space Mono metadata centered inside: `"3 hops"` above a dividing line, `"2d 4h"` below.

### Highlighter Heading
- Lowercase Space Grotesk headline accompanied by an asymmetrical, slightly rotated Acid Lime rectangular background fill block (`transform: skewX(-6deg); z-index: -1`) that mimics an analog felt-tip marker sweep across the text.

### Sealed Envelope (P2P Direct Message)
- Kraft paper rectangular envelope icon with 3px black stroke.
- Center flap sealed with an irregular Hot Pink (`#FF3EA5`) wax stamp element with a miniature embossed mesh glyph.

### Android Navigation Bar
- Fixed 5-column bottom bar on `#F4F1E8` with a 3px top black border.
- 5 equal square blocks: `home`, `explore`, `+`, `inbox`, `you`.
- Active tab state transforms into a solid Acid Lime (`#C6FF00`) block with 3px inner black border and inverted black iconography.