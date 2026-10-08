// Sync sessions (SPEC §7) — wire-compatible with jaal_core sync_session.dart.
import { b64, concat, randomBytes, unb64, utf8 } from './bytes';
import { canonical, canonicalBytes, parseBytes } from './canonical';
import { verify } from './crypto';
import { EnvelopeOrigin, EventRow, FeedPurpose, FeedRow, JaalDB } from './db';
import { FeedItem, PROTOCOL_VERSION } from './event';
import { LocalIdentity, RootId, SigDomain, certFromJson, certJson, verifyCert } from './identity';
import { Carrier, Envelope } from './carrier';
import { MediaStore } from './media';
import { EventStore, Mutex } from './store';

/** Reliable, ordered frames ≤ 256 KiB (WebRTC data channel, WebSocket, memory). */
export interface PeerConnection {
  readonly label: string;
  send(frame: Uint8Array): void;
  onFrame(cb: (f: Uint8Array) => void): void;
  onClose(cb: () => void): void;
  close(): void;
  readonly open: boolean;
}

export const MAX_FRAME = 256 * 1024;
const PAGE = 1000;

export interface SyncContext {
  me: LocalIdentity;
  db: JaalDB;
  store: EventStore;
  carrier: Carrier;
  media: MediaStore;
  now: () => number;
  directPeers: () => RootId[];
}

export class SyncSession {
  state: 'handshaking' | 'live' | 'closed' = 'handshaking';
  quarantined = false;
  peerFeed?: string;
  peerRoot?: RootId;
  readonly stats = { eventsIn: 0, eventsOut: 0, chunksIn: 0, envelopesIn: 0 };
  private nonce = b64(randomBytes(16));
  private peerNonce?: string;
  private peerHave = new Map<string, [RootId, number, boolean]>();
  private pending = new Map<string, number>();
  private mediaInflight = new Set<string>();
  private peerLacks = new Set<string>();
  private queue = Promise.resolve();
  private wantLock = new Mutex();
  private onLive: (() => void)[] = [];

  constructor(readonly conn: PeerConnection, readonly ctx: SyncContext, readonly onEnd: () => void) {
    conn.onFrame((f) => {
      this.queue = this.queue.then(() => this.handle(f)).catch((e) => console.warn('[jaal] frame error', e));
    });
    conn.onClose(() => {
      this.state = 'closed';
      onEnd();
    });
    this.send({ t: 'hello', v: PROTOCOL_VERSION, feed: ctx.me.feedId, root: ctx.me.rootId, nonce: this.nonce, cert: certJson(ctx.me.cert) });
  }

  whenLive(cb: () => void) {
    if (this.state === 'live') cb();
    else this.onLive.push(cb);
  }

  private send(msg: Record<string, unknown>) {
    if (!this.conn.open) return;
    const bytes = canonicalBytes(msg);
    if (bytes.length > MAX_FRAME) throw new Error(`frame too large (${bytes.length})`);
    this.conn.send(bytes);
  }

  private sendPaged(base: Record<string, unknown>, key: string, items: unknown[]) {
    for (let i = 0; i < items.length; i += PAGE) this.send({ ...base, [key]: items.slice(i, i + PAGE) });
  }

  private async handle(frame: Uint8Array) {
    const m = parseBytes<Record<string, any>>(frame);
    if (this.state === 'handshaking') {
      if (m.t === 'hello') return this.onHello(m);
      if (m.t === 'auth') return this.onAuth(m);
      this.conn.close();
      return;
    }
    if (this.quarantined && m.t !== 'req') return;
    switch (m.t) {
      case 'have': return this.onHave(m);
      case 'req': void this.serveReq(m); return;
      case 'events': return this.onEvents(m);
      case 'env.inv': return this.onEnvInv(m);
      case 'env.req': void this.serveEnvReq(m); return;
      case 'env.push': return this.onEnvPush(m);
      case 'acks': for (const [s, exp] of m.items) await this.ctx.carrier.acceptAck(s, exp); return;
      case 'media.req': void this.serveMedia(m); return;
      case 'media.chunk': return this.onChunk(m);
      case 'media.miss':
        for (const [h, idx] of m.items) for (const i of idx) { this.mediaInflight.delete(`${h}:${i}`); this.peerLacks.add(`${h}:${i}`); }
        if (!this.mediaInflight.size) await this.requestMedia();
        return;
    }
  }

  private static authMsg = (by: string, forFeed: string, nonce: string) =>
    concat(utf8(SigDomain.auth), canonicalBytes({ by, for: forFeed, nonce }));

  private onHello(m: Record<string, any>) {
    const cert = certFromJson(m.cert);
    if (m.v !== PROTOCOL_VERSION || cert.device !== m.feed || cert.root !== m.root || !verifyCert(cert) || m.feed === this.ctx.me.feedId) {
      this.conn.close();
      return;
    }
    this.peerFeed = m.feed;
    this.peerRoot = cert.root;
    this.peerNonce = m.nonce;
    const sig = this.ctx.me.device.sign(SyncSession.authMsg(this.ctx.me.feedId, m.feed, m.nonce));
    this.send({ t: 'auth', sig: b64(sig) });
  }

  private async onAuth(m: Record<string, any>) {
    if (!this.peerFeed || !verify(SyncSession.authMsg(this.peerFeed, this.ctx.me.feedId, this.nonce), unb64(m.sig), unb64(this.peerFeed))) {
      this.conn.close();
      return;
    }
    if (await this.ctx.db.get('blocks', this.peerRoot!)) {
      this.conn.close();
      return;
    }
    this.quarantined = this.ctx.store.moderation.isBanned(this.peerRoot!);
    this.state = 'live';
    const seen = await this.ctx.db.get('peersSeen', this.peerFeed);
    await this.ctx.db.put('peersSeen', { feedId: this.peerFeed, rootId: this.peerRoot, lastSeen: this.ctx.now(), encounters: (seen?.encounters ?? 0) + 1 });
    for (const cb of this.onLive.splice(0)) cb();
    await this.sendInventory();
  }

  private async sendInventory() {
    const mods = this.ctx.store.moderation.moderators;
    const feeds = (await this.ctx.db.getAll('feeds')) as FeedRow[];
    const isMod = (f: FeedRow) => f.purpose === FeedPurpose.moderation;
    this.sendPaged({ t: 'have' }, 'feeds', feeds
      .filter((f) => f.latestSeq > 0 && (!this.quarantined || (isMod(f) && mods.has(f.rootId))))
      .map((f) => (isMod(f) ? [f.feedId, f.rootId, f.latestSeq, 1] : [f.feedId, f.rootId, f.latestSeq])));
    if (this.quarantined) return;
    const now = this.ctx.now();
    const envs = (await this.ctx.db.getAll('envelopes')).filter((e: any) => e.exp > now && !e.acked && e.origin !== EnvelopeOrigin.received);
    this.sendPaged({ t: 'env.inv' }, 'ids', envs.map((e: any) => [e.id, e.exp]));
    const acks = (await this.ctx.db.getAll('acks')).filter((a: any) => a.exp > now);
    this.sendPaged({ t: 'acks' }, 'items', acks.map((a: any) => [a.secret, a.exp]));
    await this.requestMedia();
  }

  /** Incremental update after a local change (called by the engine). */
  notifyFeed(feed: string, root: RootId, seq: number, modFeed: boolean) {
    if (this.state !== 'live' || (this.quarantined && !modFeed)) return;
    this.send({ t: 'have', feeds: [modFeed ? [feed, root, seq, 1] : [feed, root, seq]] });
  }
  notifyEnvelope(id: string, exp: number) {
    if (this.state === 'live' && !this.quarantined) this.send({ t: 'env.inv', ids: [[id, exp]] });
  }
  notifyAck(secret: string, exp: number) {
    if (this.state === 'live' && !this.quarantined) this.send({ t: 'acks', items: [[secret, exp]] });
  }

  private async onHave(m: Record<string, any>) {
    for (const f of m.feeds) {
      const prev = this.peerHave.get(f[0]);
      if (!prev || prev[1] < f[2]) this.peerHave.set(f[0], [f[1], f[2], f.length > 3 && f[3] === 1]);
    }
    await this.requestWanted();
  }

  requestWanted() {
    return this.wantLock.run(async () => {
      const wanted = await wantedSet(this.ctx);
      const req: [string, number][] = [];
      for (const [feed, [root, seq, mod]] of [...this.peerHave]) {
        if (!wanted(root, mod)) continue;
        const local = ((await this.ctx.db.get('feeds', feed)) as FeedRow | undefined)?.latestSeq ?? 0;
        if (local >= seq) {
          this.pending.delete(feed);
          continue;
        }
        if ((this.pending.get(feed) ?? 0) >= seq) continue;
        this.pending.set(feed, seq);
        req.push([feed, local + 1]);
      }
      this.sendPaged({ t: 'req' }, 'feeds', req);
    });
  }

  private async serveReq(m: Record<string, any>) {
    const budget = MAX_FRAME - 8 * 1024;
    const mods = this.ctx.store.moderation.moderators;
    for (const [feed, fromSeq] of m.feeds as [string, number][]) {
      if (this.quarantined) {
        const f = (await this.ctx.db.get('feeds', feed)) as FeedRow | undefined;
        if (!f || f.purpose !== FeedPurpose.moderation || !mods.has(f.rootId)) continue;
      }
      let from = fromSeq;
      while (this.conn.open) {
        const items = await this.ctx.store.readFeed(feed, from, 32);
        if (!items.length) break;
        let batch: FeedItem[] = [];
        let size = 64;
        for (const it of items) {
          const s = canonical(it).length + 1;
          if (batch.length && size + s > budget) {
            this.send({ t: 'events', items: batch });
            batch = [];
            size = 64;
          }
          batch.push(it);
          size += s;
        }
        this.send({ t: 'events', items: batch });
        this.stats.eventsOut += items.length;
        from = items[items.length - 1].e.seq + 1;
        if (items.length < 32) break;
      }
    }
  }

  private async onEvents(m: Record<string, any>) {
    const halted = new Set<string>();
    let accepted = 0;
    for (const raw of m.items as FeedItem[]) {
      const feed = raw?.e?.feed;
      if (!feed || halted.has(feed) || !this.pending.has(feed)) continue;
      const r = await this.ctx.store.ingest({ e: raw.e, b: raw.b ?? null, h: Number.isSafeInteger(raw.h) && raw.h >= 0 ? raw.h : 0 });
      const target = this.pending.get(feed);
      if (r.ok || r.dup) {
        if (r.ok) {
          accepted++;
          this.stats.eventsIn++;
        }
        if (target != null && raw.e.seq >= target) this.pending.delete(feed);
      } else {
        halted.add(feed);
        this.pending.delete(feed);
      }
    }
    if (accepted) {
      await this.requestWanted();
      await this.requestMedia();
    }
  }

  private async onEnvInv(m: Record<string, any>) {
    const now = this.ctx.now();
    const want: string[] = [];
    for (const [id, exp] of m.ids as [string, number][]) if (exp > now && !(await this.ctx.carrier.knows(id))) want.push(id);
    this.sendPaged({ t: 'env.req' }, 'ids', want);
  }

  private async serveEnvReq(m: Record<string, any>) {
    let batch: unknown[] = [];
    let size = 64;
    for (const id of m.ids as string[]) {
      const env = await this.ctx.carrier.read(id);
      if (!env) continue;
      const row = await this.ctx.db.get('envelopes', id);
      const j = { env, h: row?.hops ?? 0 };
      const s = canonical(j).length + 1;
      if (batch.length && size + s > MAX_FRAME - 8192) {
        this.send({ t: 'env.push', items: batch });
        batch = [];
        size = 64;
      }
      batch.push(j);
      size += s;
    }
    if (batch.length) this.send({ t: 'env.push', items: batch });
  }

  private async onEnvPush(m: Record<string, any>) {
    for (const it of m.items as { env: Envelope; h: number }[]) {
      if (await this.ctx.carrier.accept(it.env, Number.isSafeInteger(it.h) ? it.h : 0)) this.stats.envelopesIn++;
    }
  }

  async requestMedia() {
    if (this.state !== 'live' || this.quarantined || this.mediaInflight.size) return;
    const wanted = await this.ctx.media.wanted(8, this.peerLacks);
    if (!wanted.length) return;
    for (const [h, idx] of wanted) for (const i of idx) this.mediaInflight.add(`${h}:${i}`);
    this.send({ t: 'media.req', items: wanted });
  }

  private async serveMedia(m: Record<string, any>) {
    const miss: [string, number[]][] = [];
    for (const [hash, idx] of m.items as [string, number[]][]) {
      const lacking: number[] = [];
      for (const i of idx.slice(0, 32)) {
        const data = await this.ctx.media.chunk(hash, i);
        if (!data) lacking.push(i);
        else this.send({ t: 'media.chunk', h: hash, i, d: b64(data) });
      }
      if (lacking.length) miss.push([hash, lacking]);
    }
    if (miss.length) this.send({ t: 'media.miss', items: miss });
  }

  private async onChunk(m: Record<string, any>) {
    this.mediaInflight.delete(`${m.h}:${m.i}`);
    if (await this.ctx.media.addChunk(m.h, m.i, unb64(m.d))) this.stats.chunksIn++;
    if (!this.mediaInflight.size) await this.requestMedia();
  }
}

/** Replication policy (SPEC §5.2): self, follows, direct peers, FoF, moderators' moderation feeds. */
async function wantedSet(ctx: SyncContext): Promise<(root: RootId, modFeed: boolean) => boolean> {
  const me = ctx.me.rootId;
  const blocked = new Set((await ctx.db.getAllKeys('blocks')) as string[]);
  const banned = new Set(((await ctx.db.getAll('modStatus')) as any[]).filter((s) => s.state === 2).map((s) => s.rootId));
  const follows = ((await ctx.db.getAllFromIndex('follows', 'rootId', me)) as any[]).filter((f) => f.isOn).map((f) => f.target as string);
  const roots = new Set<RootId>([me, ...follows, ...ctx.directPeers()]);
  const cutoff = ctx.now() - 7 * 24 * 3600_000;
  for (const f of follows) {
    for (const edge of (await ctx.db.getAllFromIndex('follows', 'rootId', f)) as any[]) {
      if (!edge.isOn) continue;
      const ev = (await ctx.db.get('events', edge.eventId)) as EventRow | undefined;
      if (ev && ev.ts <= cutoff) roots.add(edge.target);
    }
  }
  const mods = ctx.store.moderation.moderators;
  return (root, modFeed) => !blocked.has(root) && !banned.has(root) && (roots.has(root) || (modFeed && mods.has(root)));
}

/** Runs sessions over whatever connections the transports hand it. */
export class SyncEngine {
  readonly sessions = new Set<SyncSession>();
  private listeners = new Set<() => void>();

  constructor(readonly ctx: SyncContext) {
    ctx.store.onStored((s) => {
      for (const x of this.sessions) {
        if (s.event.type.startsWith('mod.') && !x.quarantined && x.peerRoot && ctx.store.moderation.isBanned(x.peerRoot)) {
          x.conn.close();
          continue;
        }
        x.notifyFeed(s.event.feed, s.root, s.event.seq, s.modFeed);
        if (s.event.type === 'follow' || s.event.type.startsWith('mod.')) void x.requestWanted();
      }
    });
    ctx.carrier.onChange((e) => {
      for (const x of this.sessions) {
        if (e.kind === 'envelope') x.notifyEnvelope(e.id, e.exp);
        if (e.kind === 'ack') x.notifyAck(e.secret, e.exp);
      }
    });
    ctx.media.onChange(() => {
      for (const x of this.sessions) void x.requestMedia();
    });
  }

  onChange(l: () => void) {
    this.listeners.add(l);
    return () => this.listeners.delete(l);
  }

  add(conn: PeerConnection): SyncSession {
    const s = new SyncSession(conn, this.ctx, () => {
      this.sessions.delete(s);
      this.listeners.forEach((l) => l());
    });
    this.sessions.add(s);
    s.whenLive(() => this.listeners.forEach((l) => l()));
    return s;
  }

  get connectedRoots(): RootId[] {
    return [...this.sessions].filter((s) => s.state === 'live' && s.peerRoot).map((s) => s.peerRoot!);
  }
}

/** In-memory pair for tests. */
export function memoryPair(): [PeerConnection, PeerConnection] {
  const mk = (label: string) => {
    let frameCb: (f: Uint8Array) => void = () => {};
    let closeCb: () => void = () => {};
    const c = {
      label,
      open: true,
      peer: null as any,
      send(f: Uint8Array) {
        if (!c.open) return;
        const copy = f.slice();
        queueMicrotask(() => c.peer.open && c.peer.deliver(copy));
      },
      deliver: (f: Uint8Array) => frameCb(f),
      onFrame(cb: (f: Uint8Array) => void) {
        frameCb = cb;
      },
      onClose(cb: () => void) {
        closeCb = cb;
      },
      close() {
        if (!c.open) return;
        c.open = false;
        closeCb();
        c.peer.close();
      },
    };
    return c;
  };
  const a = mk('a');
  const b = mk('b');
  a.peer = b;
  b.peer = a;
  return [a, b];
}
