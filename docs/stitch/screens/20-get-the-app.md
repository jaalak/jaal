# 20 — Get the app (web)

**Purpose:** in the iPhone/web app, a page that sells the Android app and lets people download it.
Says plainly that the app is **android only for now**. On an iPhone, the web app is still the way in.
**Route:** web `#/app` (linked from settings → about, and a small banner on home) · **Backed by:** the APK on GitHub Releases.

Design it at iPhone width (about 390×844). It's a web page inside the PWA, so keep the bottom tab bar.

## PROMPT

```
Screen: "get the app" page inside the jaal web app (Off-Grid Zine style from the design system). Mobile, 390px wide, bottom tab bar visible (home · meet · + · letters · you).

Top: yellow masking-tape strip "android only · for now" in Space Mono, rotated -2°. Below, Archivo Black 44px lowercase headline over two lines: "jaal hits different" / "on android." with a lime #C6FF00 highlighter swipe under "android." A blue Caveat handwritten note with a curly arrow: "the web app is the lite version. this is the full net ↓".

Hero: a tilted (-2°) phone-shaped paper cutout with 3px ink border and hard 6px shadow, showing a tiny version of the home feed (corkboard of polaroids, red postmark stamp "3 hops · 2d"). A big round red rubber stamp overlapping its corner reads "APK · v0.1 · free". Two small stickers slapped on it: "real" (lime) and "w" (blue).

Primary button, full width: "⬇ download for android" (lime fill, 3px black border, hard 6px offset shadow, square corners). Under it in xerox-grey Space Mono 12px: "jaal-0.1.0.apk · android 7+ · not on play store yet".

Section "only on android" as an ink label (black bar, paper text, Space Mono). Then a stack of 4 slightly tilted (alternating -1° / 1°) paper cards, each with a hand-drawn doodle icon on the left, an Archivo Black lowercase title and one line of Space Grotesk body:
1. carry pouch — "carry sealed letters for strangers. earn courier clout when they land." (pink envelope doodle with a stamp)
2. nearby radar wall — "see who's physically around you, pinned like polaroids." (polaroid doodle with a lime dot)
3. become a moderator — "get vouched in by 3 mods, irl. keep your mesh clean." (QR + three thumbs doodle)
4. network lab — "spin up a fake crowd and watch posts hop phone to phone." (beaker with a mesh inside)

Section "coming soon" as a dashed-border box (no shadow), rotated 1°, with a "soon" sticker in hot pink #FF3EA5 slapped on its corner. Three short bullet lines in Space Mono: "bluetooth + wi-fi direct mesh. no hotspot needed", "syncs in your pocket, even when the app's closed", "your android becomes a hub iphones can join".

Section "install in 3 steps" as a numbered list of three small boxes with big Archivo Black numerals in a lime square: "01 tap download", "02 allow 'install unknown apps' for your browser", "03 open jaal → type your 24 words → same you". A blue Caveat note beside step 03: "your posts + follows come with you".

Bottom: hazard-free, calm "on an iphone?" box in paper-deep #E9E3D3 with a 3px border: headline "on an iphone? stay here." and body "ios doesn't allow mesh apps outside the app store. the web app works offline: safari → share → add to home screen." A secondary paper button "← back to the feed".
```

## States
- **Visitor on iPhone/iPad:** the "on an iphone? stay here." box moves to the top, right under the headline. The download button turns into a paper-fill "send the link to an android friend" (share sheet), and the APK line reads "android phones only".
- **Visitor on Android:** as above; the download button is the hero.
- **Desktop:** the download button is replaced by a QR code (white box, 3px ink border, hard shadow) with a Caveat note: "scan with your android".

## Iterate
- "make the 'only on android' cards feel like a zine back page. more tape, less alignment"
- "the hero phone should look photocopied: xerox grain and slight ink bleed on the border"
- "the 'coming soon' box should feel like a sticky note on the page, not a warning"
