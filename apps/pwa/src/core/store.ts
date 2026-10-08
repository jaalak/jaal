// Event store + projector + moderation engine (mirrors jaal_core
// events/event_store.dart, events/projector.dart, moderation/*).
import { b64, unb64 } from './bytes';
import { canonical, parse } from './canonical';
import { SigningKey, verify } from './crypto';
import {
  EventRow, FeedPurpose, FeedRow, JaalDB, ModActionRow, ModState, PostRow,
} from './db';
import {
  Body, EventType, FeedItem, SignedEvent, createEvent, eventFromJson, eventId, hashBody,
  isModeration, lwwNewer, validateBody, verifyEvent,
} from './event';
import {
  DeviceCert, LocalIdentity, MOD_PURPOSE, RootId, SigDomain, certFromJson, certJson,
  decodeMeetCode, signedBytes, verifyCert, verifyMeetCode,
} from './identity';
import { skeleton } from './lookalike';
import { MediaStore } from './media';

export class Mutex {
  private last: Promise<unknown> = Promise.resolve();
  run<T>(f: () => Promise<T>): Promise<T> {
    const p = this.last.then(f, f);
    this.last = p.catch(() => {});
    return p;
  }
}

export type IngestResult = { ok: true; event: SignedEvent } | { ok: false; dup?: true; reason?: string };

export interface StoredEvent { event: SignedEvent; root: RootId; local: boolean; modFeed: boolean }

export class BannedError extends Error {
  constructor() {
    super('removed by moderators: this identity can no longer post');
  }
}

export interface ModerationConfig {
  genesis: Set<RootId>;
  vouchesRequired: number;
  banQuorum: number;
  revokeQuorum: number;
  consentMaxSkewMs: number;
  liveCodeMaxAgeMs: number;
}

export const defaultModeration = (genesis: Iterable<RootId> = []): ModerationConfig => ({
  genesis: new Set(genesis),
  vouchesRequired: 3,
  banQuorum: 2,
  revokeQuorum: 3,
  consentMaxSkewMs: 24 * 3600_000,
  liveCodeMaxAgeMs: 10 * 60_000,
});

type Listener = (s: StoredEvent) => void;

export class EventStore {
  private lock = new Mutex();
  private listeners = new Set<Listener>();
  readonly moderation: ModerationEngine;

  constructor(
    readonly db: JaalDB,
    readonly me: LocalIdentity,
    readonly now: () => number,
    readonly media: MediaStore,
    modConfig: ModerationConfig,
  ) {
    this.moderation = new ModerationEngine(db, modConfig, me.rootId);
  }

  onStored(l: Listener): () => void {
    this.listeners.add(l);
    return () => this.listeners.delete(l);
  }
  private emit(s: StoredEvent) {
    for (const l of this.listeners) l(s);
  }

  async init(): Promise<void> {
    await this.moderation.recompute();
    const f = (await this.db.get('feeds', this.me.feedId)) as FeedRow | undefined;
    if (!f || f.latestSeq === 0) await this.append(EventType.deviceCert, certJson(this.me.cert));
  }

  async append(type: string, body: Body): Promise<SignedEvent> {
    const err = validateBody(type, body);
    if (err) throw new Error(`invalid ${type} body: ${err}`);
    if (this.moderation.isBanned(this.me.rootId)) throw new BannedError();
    return this.lock.run(async () => {
      const mod = isModeration(type);
      let key: SigningKey = this.me.device;
      if (mod) {
        const mf = this.me.moderationFeed();
        key = mf.key;
        const row = (await this.db.get('feeds', b64(key.publicKey))) as FeedRow | undefined;
        if (!row || row.latestSeq === 0) {
          const c = await this.write(key, EventType.deviceCert, certJson(mf.cert));
          this.emit({ event: c, root: this.me.rootId, local: true, modFeed: true });
        }
      }
      const e = await this.write(key, type, body);
      if (mod) await this.moderation.recompute();
      this.emit({ event: e, root: this.me.rootId, local: true, modFeed: mod });
      return e;
    });
  }

  private async write(key: SigningKey, type: string, body: Body): Promise<SignedEvent> {
    const f = (await this.db.get('feeds', b64(key.publicKey))) as FeedRow | undefined;
    const lamport = ((await this.db.get('meta', 'lamport')) as number | undefined ?? 0) + 1;
    const e = createEvent(key, { seq: (f?.latestSeq ?? 0) + 1, prev: f?.latestId ?? null, lamport, ts: this.now(), type, body });
    await this.storeEvent(e, body, this.me.rootId, 0);
    return e;
  }

  ingest(item: FeedItem): Promise<IngestResult> {
    return this.lock.run(() => this.ingestLocked(item));
  }

  private async ingestLocked(item: FeedItem): Promise<IngestResult> {
    let e: SignedEvent;
    try {
      e = eventFromJson(item.e);
    } catch (x) {
      return { ok: false, reason: `malformed: ${x}` };
    }
    const id = eventId(e);
    if (await this.db.get('events', id)) return { ok: false, dup: true };
    const body = item.b;
    if (body) {
      if (hashBody(body) !== e.bh) return { ok: false, reason: 'badBodyHash' };
      const err = validateBody(e.type, body);
      if (err) return { ok: false, reason: `invalidBody: ${err}` };
    }
    const f = (await this.db.get('feeds', e.feed)) as FeedRow | undefined;
    const latest = f?.latestSeq ?? 0;
    if (e.seq <= latest) return { ok: false, reason: 'forkedChain' };
    if (e.seq !== latest + 1) return { ok: false, reason: 'gap' };
    if (e.prev !== (f?.latestId ?? null)) return { ok: false, reason: 'forkedChain' };
    if (f && f.latestSeq > 0 && e.lamport <= f.latestLamport) return { ok: false, reason: 'lamport' };
    if (f?.revokedAfterSeq != null && e.seq > f.revokedAfterSeq) return { ok: false, reason: 'revoked' };
    if (!verifyEvent(e)) return { ok: false, reason: 'badSignature' };

    let root: RootId;
    let modFeed = f?.purpose === FeedPurpose.moderation;
    if (e.seq === 1) {
      if (e.type !== EventType.deviceCert || !body) return { ok: false, reason: 'badDeviceCert' };
      const cert = certFromJson(body);
      if (cert.device !== e.feed || !verifyCert(cert)) return { ok: false, reason: 'badDeviceCert' };
      if (f && f.rootId !== cert.root) return { ok: false, reason: 'rootMismatch' };
      root = cert.root;
      modFeed = cert.purpose === MOD_PURPOSE;
    } else {
      root = f!.rootId;
      if (modFeed && !isModeration(e.type)) return { ok: false, reason: 'moderation feed may only hold mod.*' };
    }
    if (await this.db.get('blocks', root)) return { ok: false, reason: 'blocked' };
    if (this.moderation.isBanned(root)) return { ok: false, reason: 'banned' };

    await this.storeEvent(e, body, root, item.h + 1);
    if (isModeration(e.type)) await this.moderation.recompute();
    this.emit({ event: e, root, local: false, modFeed });
    return { ok: true, event: e };
  }

  private async storeEvent(e: SignedEvent, body: Body | null, root: RootId, hops: number): Promise<void> {
    const now = this.now();
    const id = eventId(e);
    const row: EventRow = {
      id, feedId: e.feed, seq: e.seq, rootId: root, lamport: e.lamport, ts: e.ts, type: e.type,
      raw: canonical(e), body: body ? canonical(body) : null, hops, firstSeenAt: now,
    };
    await this.db.put('events', row);
    const existing = (await this.db.get('feeds', e.feed)) as FeedRow | undefined;
    const purpose = e.seq === 1 && body?.purpose === MOD_PURPOSE ? FeedPurpose.moderation : existing?.purpose ?? FeedPurpose.normal;
    await this.db.put('feeds', {
      feedId: e.feed, rootId: root, latestSeq: e.seq, latestId: id, latestLamport: e.lamport,
      revokedAfterSeq: existing?.revokedAfterSeq, purpose,
    } satisfies FeedRow);
    const lam = (await this.db.get('meta', 'lamport')) as number | undefined ?? 0;
    if (e.lamport > lam) await this.db.put('meta', e.lamport, 'lamport');
    if (body) await new Projector(this.db, this.me, this.moderation, this.media).apply(e, id, body, root, hops, now);
  }

  async readFeed(feedId: string, fromSeq: number, limit = 32): Promise<FeedItem[]> {
    const rows = (await this.db.getAllFromIndex(
      'events', 'feedSeq', IDBKeyRange.bound([feedId, fromSeq], [feedId, Number.MAX_SAFE_INTEGER]), limit,
    )) as EventRow[];
    return rows.map((r) => ({ e: parse(r.raw), b: r.body ? parse(r.body) : null, h: r.hops }));
  }
}

class Projector {
  constructor(readonly db: JaalDB, readonly me: LocalIdentity, readonly moderation: ModerationEngine, readonly media: MediaStore) {}

  async apply(e: SignedEvent, id: string, b: Body, author: RootId, hops: number, firstSeenAt: number) {
    switch (e.type) {
      case EventType.profile: {
        const cur = await this.db.get('profiles', author);
        if (cur && !lwwNewer(e.lamport, id, cur.lamport, cur.eventId)) return;
        await this.db.put('profiles', {
          rootId: author, name: b.name, handle: b.handle, bio: b.bio ?? '', dmKey: b.dm,
          avatar: b.avatar ? canonical(b.avatar) : null, lamport: e.lamport, eventId: id,
          handleSkel: skeleton(b.handle), nameSkel: skeleton(b.name),
        });
        await this.media.expect(b.avatar, author, e.ts);
        return;
      }
      case EventType.post: {
        const tomb = await this.db.get('tombstones', id);
        const dead = tomb && tomb.byRoot === author;
        await this.db.put('posts', {
          id, rootId: author, feedId: e.feed, body: dead ? '' : b.text, media: dead ? '[]' : canonical(b.media ?? []),
          ts: e.ts, lamport: e.lamport, editLamport: 0, editId: null, hops, firstSeenAt, deleted: !!dead,
        } satisfies PostRow);
        if (dead) await this.erase(id);
        else for (const m of b.media ?? []) await this.media.expect(m, author, firstSeenAt);
        return;
      }
      case EventType.postEdit: {
        const p = (await this.db.get('posts', b.target)) as PostRow | undefined;
        if (!p || p.rootId !== author || p.deleted) return;
        if (!lwwNewer(e.lamport, id, p.editLamport, p.editId ?? '')) return;
        await this.db.put('posts', { ...p, body: b.text, editLamport: e.lamport, editId: id });
        return;
      }
      case EventType.delete: {
        if (!(await this.db.get('tombstones', b.target))) {
          await this.db.put('tombstones', { target: b.target, byRoot: author, lamport: e.lamport, eventId: id });
        }
        const p = (await this.db.get('posts', b.target)) as PostRow | undefined;
        if (p && p.rootId === author && !p.deleted) {
          for (const m of parse<any[]>(p.media)) if (m?.hash) await this.media.drop(m.hash);
          await this.db.put('posts', { ...p, body: '', media: '[]', deleted: true });
          await this.erase(b.target);
        }
        const c = await this.db.get('comments', b.target);
        if (c && c.rootId === author && !c.deleted) {
          await this.db.put('comments', { ...c, body: '', deleted: true });
          await this.erase(b.target);
        }
        return;
      }
      case EventType.reaction: {
        const cur = await this.db.get('reactions', [author, b.target]);
        if (cur && !lwwNewer(e.lamport, id, cur.lamport, cur.eventId)) return;
        await this.db.put('reactions', { rootId: author, target: b.target, sticker: b.sticker ?? null, x: b.x, y: b.y, rot: b.rot, lamport: e.lamport, eventId: id });
        return;
      }
      case EventType.comment: {
        const tomb = await this.db.get('tombstones', id);
        const dead = tomb && tomb.byRoot === author;
        await this.db.put('comments', { id, target: b.target, rootId: author, body: dead ? '' : b.text, parent: b.parent ?? null, ts: e.ts, lamport: e.lamport, deleted: !!dead });
        return;
      }
      case EventType.follow: {
        const cur = await this.db.get('follows', [author, b.target]);
        if (cur && !lwwNewer(e.lamport, id, cur.lamport, cur.eventId)) return;
        await this.db.put('follows', { rootId: author, target: b.target, isOn: b.on, lamport: e.lamport, eventId: id });
        return;
      }
      case EventType.modVouch:
      case EventType.modRevoke:
      case EventType.modBan:
        await this.moderation.record(e, id, b, author);
        return;
      default:
        return;
    }
  }

  private async erase(eventId: string) {
    const r = await this.db.get('events', eventId);
    if (r) await this.db.put('events', { ...r, body: null });
  }
}

// ------------------------------------------------------------ moderation

export class ModerationEngine {
  private mods = new Set<RootId>();
  private banned = new Set<RootId>();
  private flagged = new Set<RootId>();
  private vouchedBy = new Map<RootId, Set<RootId>>();

  constructor(readonly db: JaalDB, readonly config: ModerationConfig, readonly me: RootId) {}

  isModerator = (r: RootId) => this.mods.has(r);
  isBanned = (r: RootId) => this.banned.has(r);
  isFlagged = (r: RootId) => this.flagged.has(r);
  get moderators() {
    return new Set(this.mods);
  }
  vouchesFor = (r: RootId) => new Set(this.vouchedBy.get(r) ?? []);

  async record(e: SignedEvent, id: string, b: Body, author: RootId) {
    let target: string;
    let valid = true;
    let on = true;
    if (e.type === EventType.modVouch) {
      target = b.candidate;
      try {
        const code = b.consent;
        valid = code.purpose === 'mod' && code.root === b.candidate &&
          Math.abs(e.ts - code.ts) <= this.config.consentMaxSkewMs && verifyMeetCode(code);
      } catch {
        valid = false;
      }
    } else if (e.type === EventType.modRevoke) {
      target = b.target;
    } else {
      target = b.target;
      on = b.on;
    }
    if (target === author) valid = false;
    const row: ModActionRow = { eventId: id, author, feedId: e.feed, seq: e.seq, type: e.type, target, isOn: on, lamport: e.lamport, ts: e.ts, body: canonical(b), valid };
    await this.db.put('modActions', row);
  }

  async recompute(): Promise<void> {
    const actions = ((await this.db.getAll('modActions')) as ModActionRow[]).filter((a) => a.valid);
    const genesis = this.config.genesis;
    let revoked = new Map<RootId, Record<string, number>>();
    let qualified = new Set<RootId>();
    const vouchedBy = new Map<RootId, Set<RootId>>();
    const voided = (a: ModActionRow, rev: Map<RootId, Record<string, number>>) => {
      const cut = rev.get(a.author);
      if (!cut) return false;
      const last = cut[a.feedId];
      return last == null || a.seq > last;
    };
    const authorized = (a: ModActionRow, q: Set<RootId>, rev: Map<RootId, Record<string, number>>) =>
      (genesis.has(a.author) || q.has(a.author)) && !voided(a, rev);

    for (let iter = 0; iter < 32; iter++) {
      const nextRevoked = new Map<RootId, Record<string, number>>();
      const byTarget = new Map<RootId, ModActionRow[]>();
      for (const a of actions) {
        if (a.type !== EventType.modRevoke || genesis.has(a.target) || !authorized(a, qualified, revoked)) continue;
        byTarget.set(a.target, [...(byTarget.get(a.target) ?? []), a]);
      }
      for (const [target, votes] of byTarget) {
        const fromGenesis = votes.filter((v) => genesis.has(v.author));
        const distinct = new Map(votes.map((v) => [v.author, v]));
        const effective = fromGenesis.length ? fromGenesis : distinct.size >= this.config.revokeQuorum ? [...distinct.values()] : null;
        if (!effective) continue;
        const maps = effective.map((r) => parse<any>(r.body).cutoff as Record<string, number>);
        const feeds = new Set(maps.flatMap((m) => Object.keys(m)));
        const merged: Record<string, number> = {};
        for (const f of feeds) merged[f] = Math.min(...maps.map((m) => m[f] ?? 0));
        nextRevoked.set(target, merged);
      }
      const nextQualified = new Set<RootId>();
      vouchedBy.clear();
      for (const a of actions) {
        if (a.type !== EventType.modVouch || !authorized(a, qualified, nextRevoked)) continue;
        if (!vouchedBy.has(a.target)) vouchedBy.set(a.target, new Set());
        vouchedBy.get(a.target)!.add(a.author);
      }
      for (const [c, by] of vouchedBy) if (!genesis.has(c) && by.size >= this.config.vouchesRequired) nextQualified.add(c);
      const same = (x: Set<string>, y: Set<string>) => x.size === y.size && [...x].every((v) => y.has(v));
      const stable = same(nextQualified, qualified) && same(new Set(nextRevoked.keys()), new Set(revoked.keys()));
      qualified = nextQualified;
      revoked = nextRevoked;
      if (stable) break;
    }
    const mods = new Set<RootId>([...genesis, ...[...qualified].filter((q) => !revoked.has(q))]);

    const latest = new Map<string, ModActionRow>();
    for (const a of actions) {
      if (a.type !== EventType.modBan || !authorized(a, qualified, revoked)) continue;
      const k = `${a.author}|${a.target}`;
      const cur = latest.get(k);
      if (!cur || lwwNewer(a.lamport, a.eventId, cur.lamport, cur.eventId)) latest.set(k, a);
    }
    const votes = new Map<RootId, ModActionRow[]>();
    for (const a of latest.values()) if (a.isOn) votes.set(a.target, [...(votes.get(a.target) ?? []), a]);
    const banned = new Set<RootId>();
    const flagged = new Set<RootId>();
    await this.db.clear('modStatus');
    for (const [t, vs] of votes) {
      if (mods.has(t)) continue;
      const state = vs.length >= this.config.banQuorum ? ModState.banned : ModState.flagged;
      (state === ModState.banned ? banned : flagged).add(t);
      vs.sort((a, b) => (lwwNewer(a.lamport, a.eventId, b.lamport, b.eventId) ? -1 : 1));
      await this.db.put('modStatus', { rootId: t, state, votes: vs.length, reason: parse<any>(vs[0].body).reason ?? '' });
    }
    await this.db.clear('moderators');
    for (const m of mods) await this.db.put('moderators', { rootId: m, genesis: genesis.has(m) });
    const newlyBanned = [...banned].filter((b) => !this.banned.has(b));
    this.mods = mods;
    this.banned = banned;
    this.flagged = flagged;
    this.vouchedBy = vouchedBy;
    for (const r of newlyBanned) if (r !== this.me) await this.purge(r);
  }

  private async purge(root: RootId) {
    const tx = this.db.transaction(['posts', 'comments', 'reactions', 'follows', 'events', 'feeds', 'mediaBlobs'], 'readwrite');
    for (const store of ['posts', 'comments', 'reactions', 'follows'] as const) {
      let cur = await tx.objectStore(store).openCursor();
      while (cur) {
        if ((cur.value as any).rootId === root) await cur.delete();
        cur = await cur.continue();
      }
    }
    for (const k of await tx.objectStore('events').index('rootId').getAllKeys(root)) await tx.objectStore('events').delete(k);
    for (const k of await tx.objectStore('feeds').index('rootId').getAllKeys(root)) await tx.objectStore('feeds').delete(k);
    await tx.done;
  }
}

// Re-exports for callers.
export { SigDomain, signedBytes, verify, unb64, decodeMeetCode, type DeviceCert };
