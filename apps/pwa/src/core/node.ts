// JaalNode: the app-facing API (mirrors jaal_core node/jaal_node.dart).
import { b64, unb64 } from './bytes';
import { parse } from './canonical';
import { Carrier } from './carrier';
import { CommentRow, JaalDB, MessageRow, PostRow, ProfileRow, ReactionRow, openJaalDB } from './db';
import { Bodies, EventType, HANDLE } from './event';
import {
  LocalIdentity, MeetCode, RootId, RootIdentity, certFromJson, createMeetCode, decodeMeetCode,
  fingerprintOf, verifyMeetCode,
} from './identity';
import { skeleton } from './lookalike';
import { Manifest, MediaStore } from './media';
import { EventStore, ModerationConfig, defaultModeration } from './store';
import { PeerConnection, SyncEngine } from './sync';

export interface Clock { now(): number }

export class JaalNode {
  readonly store: EventStore;
  readonly carrier: Carrier;
  readonly media: MediaStore;
  readonly engine: SyncEngine;
  private listeners = new Set<() => void>();
  private pending = false;

  private constructor(readonly db: JaalDB, readonly me: LocalIdentity, readonly now: () => number, mod: ModerationConfig) {
    this.media = new MediaStore(db, now);
    this.store = new EventStore(db, me, now, this.media, mod);
    this.carrier = new Carrier(db, me, now);
    this.engine = new SyncEngine({
      me, db, store: this.store, carrier: this.carrier, media: this.media, now,
      directPeers: () => this.engine.connectedRoots,
    });
    const ping = () => this.changed();
    this.store.onStored(ping);
    this.carrier.onChange(ping);
    this.media.onChange(ping);
    this.engine.onChange(ping);
  }

  /** Coalesced "something changed" for the UI. */
  onChange(l: () => void) {
    this.listeners.add(l);
    return () => this.listeners.delete(l);
  }
  private changed() {
    if (this.pending) return;
    this.pending = true;
    queueMicrotask(() => {
      this.pending = false;
      this.listeners.forEach((l) => l());
    });
  }

  static async open(db: JaalDB, me: LocalIdentity, opts: { now?: () => number; moderation?: ModerationConfig } = {}) {
    const n = new JaalNode(db, me, opts.now ?? Date.now, opts.moderation ?? defaultModeration(GENESIS));
    await n.store.init();
    return n;
  }

  get rootId() {
    return this.me.rootId;
  }

  connect(conn: PeerConnection) {
    return this.engine.add(conn);
  }

  // ---------------------------------------------------------------- writes

  setProfile(name: string, handle: string, bio = '', avatar: Manifest | null = null) {
    if (!HANDLE.test(handle)) throw new Error('handle: 2–24 chars a-z 0-9 _ .');
    return this.store.append(EventType.profile, Bodies.profile(name, handle, bio, this.me.dmPublicKey, avatar as any));
  }
  post = (text: string, media: Manifest[] = []) => this.store.append(EventType.post, Bodies.post(text, media as any));
  async postPhoto(text: string, photo: { bytes: Uint8Array; mime: string; w: number; h: number }) {
    const m = await this.media.putLocal(photo.bytes, photo.mime, this.rootId, photo.w, photo.h);
    return this.post(text, [m]);
  }
  react = (postId: string, sticker: string | null) =>
    this.store.append(EventType.reaction, Bodies.reaction(postId, sticker, 120 + Math.floor(Math.random() * 760), 120 + Math.floor(Math.random() * 760), Math.floor(Math.random() * 31) - 15));
  comment = (postId: string, text: string) => this.store.append(EventType.comment, Bodies.comment(postId, text));
  follow = (root: RootId) => this.store.append(EventType.follow, Bodies.follow(root, true));
  unfollow = (root: RootId) => this.store.append(EventType.follow, Bodies.follow(root, false));
  delete = (id: string) => this.store.append(EventType.delete, Bodies.delete(id));
  sendDm = (to: RootId, text: string) => this.carrier.sendDm(to, text);
  async block(root: RootId) {
    await this.db.put('blocks', { rootId: root, since: this.now() });
    for (const s of this.engine.sessions) if (s.peerRoot === root) s.conn.close();
    this.changed();
  }

  async meetCode(): Promise<MeetCode> {
    const p = await this.profile(this.rootId);
    return createMeetCode(this.me, p?.handle ?? 'anon', this.now());
  }

  async verifyInPerson(scanned: string): Promise<MeetCode> {
    const c = decodeMeetCode(scanned);
    if (c.purpose !== 'meet' || !verifyMeetCode(c)) throw new Error('that code doesn\'t check out');
    if (this.now() - c.ts > 10 * 60_000) throw new Error('code expired — ask them to refresh it');
    if (c.root === this.rootId) throw new Error('that\'s your own code');
    await this.db.put('verified', { rootId: c.root, at: this.now() });
    if (!(await this.following()).has(c.root)) await this.follow(c.root);
    return c;
  }

  // ----------------------------------------------------------------- reads

  profile = (root: RootId) => this.db.get('profiles', root) as Promise<ProfileRow | undefined>;
  profiles = () => this.db.getAll('profiles') as Promise<ProfileRow[]>;

  async following(root = this.rootId): Promise<Set<RootId>> {
    const rows = (await this.db.getAllFromIndex('follows', 'rootId', root)) as any[];
    return new Set(rows.filter((r) => r.isOn).map((r) => r.target));
  }

  private async hidden(): Promise<Set<RootId>> {
    const blocked = (await this.db.getAllKeys('blocks')) as string[];
    const mod = ((await this.db.getAll('modStatus')) as any[]).map((s) => s.rootId);
    return new Set([...blocked, ...mod]);
  }

  async allPosts(): Promise<PostRow[]> {
    const hidden = await this.hidden();
    return ((await this.db.getAll('posts')) as PostRow[])
      .filter((p) => !p.deleted && !hidden.has(p.rootId))
      .sort((a, b) => b.ts - a.ts);
  }

  async homeFeed(): Promise<PostRow[]> {
    const f = await this.following();
    return (await this.allPosts()).filter((p) => p.rootId === this.rootId || f.has(p.rootId));
  }

  post_ = (id: string) => this.db.get('posts', id) as Promise<PostRow | undefined>;
  reactions = async (id: string) => ((await this.db.getAllFromIndex('reactions', 'target', id)) as ReactionRow[]).filter((r) => r.sticker);
  comments = async (id: string) =>
    ((await this.db.getAllFromIndex('comments', 'target', id)) as CommentRow[]).filter((c) => !c.deleted).sort((a, b) => a.ts - b.ts);

  async inbox(): Promise<MessageRow[]> {
    const latest = new Map<string, MessageRow>();
    for (const m of (await this.db.getAll('messages')) as MessageRow[]) {
      const cur = latest.get(m.peerRoot);
      if (!cur || m.sentAt > cur.sentAt) latest.set(m.peerRoot, m);
    }
    return [...latest.values()].sort((a, b) => b.sentAt - a.sentAt);
  }
  conversation = async (peer: RootId) =>
    ((await this.db.getAllFromIndex('messages', 'peerRoot', peer)) as MessageRow[]).sort((a, b) => a.sentAt - b.sentAt);

  static mediaOf(p: PostRow): Manifest[] {
    try {
      return parse<Manifest[]>(p.media);
    } catch {
      return [];
    }
  }

  /** Lookalike check (same rules as Android). */
  async lookalike(root: RootId): Promise<string | null> {
    const p = await this.profile(root);
    if (!p || root === this.rootId) return null;
    const f = await this.following();
    if (f.has(root) || (await this.db.get('verified', root))) return null;
    for (const o of await this.db.getAllFromIndex('profiles', 'handleSkel', skeleton(p.handle))) {
      if (o.rootId !== root && (o.rootId === this.rootId || f.has(o.rootId) || (await this.db.get('verified', o.rootId)))) {
        return `looks like @${o.handle}·${fingerprintOf(o.rootId)} — different key`;
      }
    }
    return null;
  }
}

/** Production genesis moderators (filled by packages/jaal_core/tool/genesis.dart). */
export const GENESIS: string[] = [];

// ------------------------------------------------------------- persistence

export interface StoredIdentity { rootSeed: string; deviceSeed: string; cert: unknown }

export async function loadIdentity(db: JaalDB): Promise<LocalIdentity | null> {
  const s = (await db.get('meta', 'identity')) as StoredIdentity | undefined;
  return s ? LocalIdentity.restore(unb64(s.rootSeed), unb64(s.deviceSeed), certFromJson(s.cert)) : null;
}

export async function createIdentity(db: JaalDB, phrase?: string): Promise<LocalIdentity> {
  const root = phrase ? RootIdentity.fromRecoveryPhrase(phrase) : RootIdentity.generate();
  const me = LocalIdentity.create(root, Date.now());
  await db.put('meta', { rootSeed: b64(root.seed), deviceSeed: b64(me.deviceSeed), cert: me.cert } satisfies StoredIdentity, 'identity');
  return me;
}

export { openJaalDB };
