# 18 — Moderation desk (removing toxic people)

**Purpose:** a moderator's tools. **1 vote flags** someone (their content is hidden, reversible).
**A 2nd moderator's vote removes them** (purged from every phone, can't post again). Moderators can also
retract their vote, and revoke a rogue moderator (3 moderators, or any genesis moderator).
**Backed by:** `banVote(target, reason)`, `retractBanVote`, `revokeModerator`, `mod_status` (state, votes, reason),
`moderators` (role: genesis / vouched).

## PROMPT

```
Screen: "moderation desk" for jaal, Off-Grid Zine style, for moderators only. Show 2 artboards.

ARTBOARD 1, the desk: header "the desk" in Archivo Black with a stamp-red #D7263D highlighter, and a blue "★ mod" badge beside it. Three square tabs: "needs a 2nd vote (3)", "removed (12)", "mods (9)".
List of case cards (paper, 3px border, hard shadow, tilt alternating ±1°):
- polaroid with a halftone overlay, "@ragebait99·q0zt", reason chip in mono "harassment", a vote tally drawn as two stamp slots: one filled red stamp "mod1 · flagged", one empty dashed slot "2nd vote".
- a preview strip of 3 of their recent posts, blurred behind diagonal hazard tape (yellow/black) with "tap to view".
- buttons: a stamp-red "remove ✕" button and a paper "not toxic" button. A small grey link "retract my vote".
A hand-note in blue at the top: "1 vote hides them. 2 votes remove them for good."

ARTBOARD 2, confirm removal (bottom sheet with a 3px top border): title "remove @ragebait99?" in Archivo Black. A reason picker of square chips: "harassment", "hate", "spam", "impersonation", "threats", "other". An optional text input "note for other mods (≤280)". A summary box in mono:
"✕ their posts vanish from every phone that syncs
 ✕ they can't post, comment or stick again
 ✕ their DMs are dropped
 ✓ any moderator can retract"
A big stamp-red button "stamp it: removed" with a rubber-stamp icon. Annotate: "the stamp thumps down and the card gets shredded."
```

## Iterate
- "make removed profiles look like a torn-up flyer in a bin"
