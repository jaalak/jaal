# 15 — Settings: identity, devices, storage, privacy

**Purpose:** control panel for keys, devices, carrying budget and blocks.
**Route:** `/settings` · **Backed by:** `LocalIdentity` (root and device keys, recovery phrase), device certs and
`device.revoke` events, `maxCarryBytes`, `ReplicationPolicy.friendsOfFriends` and `maxFofRoots`, `blocks` (private,
synced encrypted to your own devices only), transports.

## PROMPT

```
Screen: settings for jaal, Off-Grid Zine style. A long scrolling page of stacked zine sections, each section a card with a 3px border, a hard shadow, and a lowercase Archivo Black heading with a highlighter swipe.

1. "you": the polaroid avatar and handle chip "@maya.offgrid·k7f2", a button "show recovery phrase" (red outline, lock icon), and a mono line "root key: A6EH…Mbg".
2. "devices": a list of device cards: "this pixel 8 · since 2 jan" (lime "this one" stamp), "old samsung · last seen 3w" with a red "revoke" button. A hand-note: "revoking stops that phone from posting as you."
3. "carrying for strangers": a stepper slider with square ticks "5 / 20 / 50 / 100 mb", and a toggle "carry letters for strangers: on".
4. "how far your feed reaches": a toggle "friends of friends: on", a stepper "up to 150 people".
5. "radios": toggles with square switches: "bluetooth", "wifi direct", "local wifi"; each shows a mono status chip ("ready", "soon").
6. "blocked": a list "2 people · private, only you know" with an unblock link.
7. "danger zone": a red-bordered card with "wipe this phone" (stamp-red button).
8. Footer: "jaal v0.1 · protocol v1 · no servers were harmed" in mono, and a small "network lab (dev)" link.
```

## Iterate
- "make each section look like a different torn page"
