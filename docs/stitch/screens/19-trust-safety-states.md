# 19 — Trust & safety states (impersonation, verified, flagged, removed)

**Purpose:** reusable states that appear on profiles, posts, chats and the radar wall.
**Backed by:** `Lookalikes.check` / `JaalNode.lookalikesOf` (lookalike warning), `verified` (met in person),
`petnames` (private nicknames), `mod_status` (flagged / removed), `JaalNode.isBanned` plus `BannedException` (your
own removed state). Moderator badge from `moderators`.

Key truth for the copy: **nobody can post as someone else.** It would need their key. Impostors can only
*look* similar, with a different key, which is exactly what the fingerprint and the warning show.

## PROMPT

```
Design sheet: trust & safety states for jaal, Off-Grid Zine style. One artboard with 6 labelled components.

1. LOOKALIKE WARNING (on a profile header): a stamp-red #D7263D hazard-tape banner across the top of the profile, tilted 1°, Space Mono: "⚠ looks like @maya.offgrid·k7f2 (you follow them) — different key". Below it, two fingerprint luggage-tags side by side for comparison: "real: ·k7f2" with a lime check and "this one: ·p0rt" crossed out in red. Buttons: "block" (stamp red), "it's fine" (paper).

2. VERIFIED IN PERSON badge: a small lime rubber-stamp "met irl ✓" next to a handle, plus a variant on a polaroid corner.

3. PETNAME: a profile name shown as a handwritten Caveat label on masking tape "my cousin maya" over the real "@maya.offgrid·k7f2" in grey mono, with a pencil edit icon.

4. MODERATOR BADGE: a blue scalloped "★ mod" badge, and a smaller version for genesis moderators "★ og mod".

5. FLAGGED (seen by others): a post card covered in diagonal yellow/black hazard tape with "hidden by a moderator · tap to view anyway" in mono. Faded content behind halftone.

6. REMOVED: (a) another person's profile as a torn-up flyer with a big red stamp "REMOVED BY MODERATORS" and grey text "their posts no longer travel the mesh"; (b) YOUR OWN app when you've been removed: a full-screen xerox-grey page with "you've been removed." in Archivo Black, a calm explanation "2 moderators removed this identity. you can't post, comment, stick or send letters, and phones stop sharing the mesh with you.", and a link "why? (reason: harassment)".
```

## Iterate
- "the hazard tape should look like real vinyl tape with slight wrinkles"
