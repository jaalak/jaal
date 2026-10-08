// Signed feed events + body schemas (protocol/SPEC.md §4), mirroring
// jaal_core protocol/event.dart and protocol/bodies.dart.
import { b64, unb64 } from './bytes';
import { canonical, canonicalBytes } from './canonical';
import { SigningKey, sha256, verify } from './crypto';
import { FeedId, SigDomain, signedBytes } from './identity';

export const PROTOCOL_VERSION = 1;

export const EventType = {
  deviceCert: 'device.cert',
  deviceRevoke: 'device.revoke',
  profile: 'profile',
  post: 'post',
  postEdit: 'post.edit',
  delete: 'delete',
  reaction: 'reaction',
  comment: 'comment',
  follow: 'follow',
  selfPrivate: 'self.private',
  modVouch: 'mod.vouch',
  modRevoke: 'mod.revoke',
  modBan: 'mod.ban',
} as const;

export const isModeration = (t: string) => t.startsWith('mod.');

export type Body = Record<string, any>;

export interface SignedEvent {
  v: number;
  feed: FeedId;
  seq: number;
  prev: string | null;
  lamport: number;
  ts: number;
  type: string;
  bh: string;
  sig: string;
}

export const unsignedOf = (e: SignedEvent) => ({
  v: e.v,
  feed: e.feed,
  seq: e.seq,
  prev: e.prev,
  lamport: e.lamport,
  ts: e.ts,
  type: e.type,
  bh: e.bh,
});

export const eventId = (e: SignedEvent): string => b64(sha256(canonicalBytes(unsignedOf(e))));
export const hashBody = (b: Body): string => b64(sha256(canonicalBytes(b)));

export const verifyEvent = (e: SignedEvent): boolean =>
  verify(signedBytes(SigDomain.event, unsignedOf(e)), unb64(e.sig), unb64(e.feed));

export function createEvent(
  device: SigningKey,
  f: { seq: number; prev: string | null; lamport: number; ts: number; type: string; body: Body },
): SignedEvent {
  const e: SignedEvent = {
    v: PROTOCOL_VERSION,
    feed: b64(device.publicKey),
    seq: f.seq,
    prev: f.prev,
    lamport: f.lamport,
    ts: f.ts,
    type: f.type,
    bh: hashBody(f.body),
    sig: '',
  };
  e.sig = b64(device.sign(signedBytes(SigDomain.event, unsignedOf(e))));
  return e;
}

const EVENT_FIELDS = new Set(['v', 'feed', 'seq', 'prev', 'lamport', 'ts', 'type', 'bh', 'sig']);

/** Structural checks (throws on malformed). */
export function eventFromJson(j: any): SignedEvent {
  if (!j || typeof j !== 'object') throw new Error('event: not an object');
  for (const k of Object.keys(j)) if (!EVENT_FIELDS.has(k)) throw new Error(`unknown event field ${k}`);
  const int = (k: string) => {
    if (!Number.isSafeInteger(j[k])) throw new Error(`event.${k} must be int`);
    return j[k] as number;
  };
  const str = (k: string) => {
    if (typeof j[k] !== 'string') throw new Error(`event.${k} must be string`);
    return j[k] as string;
  };
  const e: SignedEvent = {
    v: int('v'),
    feed: str('feed'),
    seq: int('seq'),
    prev: j.prev === null ? null : str('prev'),
    lamport: int('lamport'),
    ts: int('ts'),
    type: str('type'),
    bh: str('bh'),
    sig: str('sig'),
  };
  if (e.v !== PROTOCOL_VERSION) throw new Error(`unsupported version ${e.v}`);
  if (e.seq < 1) throw new Error('seq must be >= 1');
  if ((e.seq === 1) !== (e.prev === null)) throw new Error('prev must be null iff seq == 1');
  if (e.lamport < 1) throw new Error('lamport must be >= 1');
  return e;
}

/** Wire item: `{e, b, h}` (body may be erased → null). */
export interface FeedItem {
  e: SignedEvent;
  b: Body | null;
  h: number;
}

// ------------------------------------------------------------------ bodies

export const Limits = { postText: 2200, commentText: 1000, name: 50, bio: 300, modReason: 280 };
export const HANDLE = /^[a-z0-9_.]{2,24}$/;
export const STICKERS = ['heart', 'fire', 'lol', 'real', 'slay', 'mid', 'cry', 'peak', 'w', 'skull'];

export const Bodies = {
  profile: (name: string, handle: string, bio: string, dm: string, avatar: Body | null = null) => ({
    name,
    handle,
    bio,
    dm,
    avatar,
  }),
  post: (text: string, media: Body[] = []) => ({ text, media }),
  delete: (target: string) => ({ target }),
  reaction: (target: string, sticker: string | null, x = 500, y = 500, rot = 0) => ({ target, sticker, x, y, rot }),
  comment: (target: string, text: string, parent: string | null = null) => ({ target, text, parent }),
  follow: (target: string, on: boolean) => ({ target, on }),
};

/** Returns an error, or null if valid. Unknown types pass (forward compat). */
export function validateBody(type: string, b: Body): string | null {
  const str = (k: string, max?: number, optional = false) => {
    const v = b[k];
    if ((v === null || v === undefined) && optional) return null;
    if (typeof v !== 'string') return `${k} must be a string`;
    if (max != null && v.length > max) return `${k} longer than ${max}`;
    return null;
  };
  const int = (k: string, min: number, max: number) =>
    Number.isSafeInteger(b[k]) && b[k] >= min && b[k] <= max ? null : `${k} must be int in [${min},${max}]`;
  const first = (...c: (() => string | null)[]) => {
    for (const f of c) {
      const r = f();
      if (r) return r;
    }
    return null;
  };
  switch (type) {
    case EventType.deviceCert:
      return first(() => str('root'), () => str('device'), () => (Number.isSafeInteger(b.created) ? null : 'created'), () => str('sig'));
    case EventType.deviceRevoke:
      return first(() => str('device'), () => (Number.isSafeInteger(b.afterSeq) ? null : 'afterSeq'), () => str('rootSig'));
    case EventType.profile:
      return first(
        () => str('name', Limits.name),
        () => str('bio', Limits.bio),
        () => str('dm'),
        () => (typeof b.handle === 'string' && HANDLE.test(b.handle) ? null : 'handle'),
        () => (b.avatar == null || typeof b.avatar === 'object' ? null : 'avatar'),
      );
    case EventType.post:
      return first(() => str('text', Limits.postText), () => (Array.isArray(b.media) ? null : 'media must be a list'));
    case EventType.postEdit:
      return first(() => str('target'), () => str('text', Limits.postText));
    case EventType.delete:
      return str('target');
    case EventType.reaction:
      return first(() => str('target'), () => str('sticker', 32, true), () => int('x', 0, 1000), () => int('y', 0, 1000), () => int('rot', -45, 45));
    case EventType.comment:
      return first(() => str('target'), () => str('text', Limits.commentText), () => str('parent', undefined, true));
    case EventType.follow:
      return first(() => str('target'), () => (typeof b.on === 'boolean' ? null : 'on must be bool'));
    case EventType.selfPrivate:
      return first(() => str('nonce'), () => str('ct'));
    case EventType.modVouch:
      return first(() => str('candidate'), () => (b.consent && typeof b.consent === 'object' ? null : 'consent'));
    case EventType.modRevoke:
      return first(() => str('target'), () => (b.cutoff && typeof b.cutoff === 'object' ? null : 'cutoff'));
    case EventType.modBan:
      return first(() => str('target'), () => (typeof b.on === 'boolean' ? null : 'on'), () => str('reason', Limits.modReason));
    default:
      return null;
  }
}

/** LWW: higher lamport wins, tie → greater id. */
export const lwwNewer = (l: number, id: string, ol: number, oid: string) => l > ol || (l === ol && id > oid);

export const canonicalOf = canonical;
