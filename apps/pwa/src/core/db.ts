// IndexedDB schema — the same logical tables as the Android app's Drift DB.
import { IDBPDatabase, openDB } from 'idb';

export interface FeedRow { feedId: string; rootId: string; latestSeq: number; latestId: string | null; latestLamport: number; revokedAfterSeq?: number; purpose: number }
export interface EventRow { id: string; feedId: string; seq: number; rootId: string; lamport: number; ts: number; type: string; raw: string; body: string | null; hops: number; firstSeenAt: number }
export interface ProfileRow { rootId: string; name: string; handle: string; bio: string; dmKey: string; avatar: string | null; lamport: number; eventId: string; handleSkel: string; nameSkel: string }
export interface PostRow { id: string; rootId: string; feedId: string; body: string; media: string; ts: number; lamport: number; editLamport: number; editId: string | null; hops: number; firstSeenAt: number; deleted: boolean }
export interface ReactionRow { rootId: string; target: string; sticker: string | null; x: number; y: number; rot: number; lamport: number; eventId: string }
export interface CommentRow { id: string; target: string; rootId: string; body: string; parent: string | null; ts: number; lamport: number; deleted: boolean }
export interface FollowRow { rootId: string; target: string; isOn: boolean; lamport: number; eventId: string }
export interface EnvelopeRow { id: string; raw: string; hint: string; ackHash: string; exp: number; size: number; receivedAt: number; hops: number; origin: number; acked: boolean }
export interface MessageRow { id: string; peerRoot: string; outgoing: boolean; body: string; sentAt: number; receivedAt: number | null; ackHash: string; delivered: boolean }
export interface ModActionRow { eventId: string; author: string; feedId: string; seq: number; type: string; target: string; isOn: boolean; lamport: number; ts: number; body: string; valid: boolean }
export interface MediaBlobRow { hash: string; manifest: string; mime: string; size: number; chunkCount: number; chunksHeld: number; complete: boolean; rootId: string; createdAt: number }

export const FeedPurpose = { normal: 0, moderation: 1 } as const;
export const EnvelopeOrigin = { carried: 0, sent: 1, received: 2 } as const;
export const ModState = { none: 0, flagged: 1, banned: 2 } as const;

export type JaalDB = IDBPDatabase;

export async function openJaalDB(name = 'jaal'): Promise<JaalDB> {
  return openDB(name, 1, {
    upgrade(db) {
      db.createObjectStore('meta');
      db.createObjectStore('feeds', { keyPath: 'feedId' }).createIndex('rootId', 'rootId');
      const ev = db.createObjectStore('events', { keyPath: 'id' });
      ev.createIndex('feedSeq', ['feedId', 'seq']);
      ev.createIndex('rootId', 'rootId');
      const pr = db.createObjectStore('profiles', { keyPath: 'rootId' });
      pr.createIndex('handleSkel', 'handleSkel');
      pr.createIndex('nameSkel', 'nameSkel');
      const po = db.createObjectStore('posts', { keyPath: 'id' });
      po.createIndex('ts', 'ts');
      po.createIndex('rootId', 'rootId');
      db.createObjectStore('reactions', { keyPath: ['rootId', 'target'] }).createIndex('target', 'target');
      db.createObjectStore('comments', { keyPath: 'id' }).createIndex('target', 'target');
      const fo = db.createObjectStore('follows', { keyPath: ['rootId', 'target'] });
      fo.createIndex('target', 'target');
      fo.createIndex('rootId', 'rootId');
      db.createObjectStore('tombstones', { keyPath: 'target' });
      db.createObjectStore('envelopes', { keyPath: 'id' }).createIndex('ackHash', 'ackHash');
      db.createObjectStore('acks', { keyPath: 'ackHash' });
      db.createObjectStore('messages', { keyPath: 'id' }).createIndex('peerRoot', 'peerRoot');
      db.createObjectStore('blocks', { keyPath: 'rootId' });
      db.createObjectStore('peersSeen', { keyPath: 'feedId' });
      db.createObjectStore('stats', { keyPath: 'key' });
      db.createObjectStore('modActions', { keyPath: 'eventId' });
      db.createObjectStore('moderators', { keyPath: 'rootId' });
      db.createObjectStore('modStatus', { keyPath: 'rootId' });
      db.createObjectStore('verified', { keyPath: 'rootId' });
      db.createObjectStore('mediaBlobs', { keyPath: 'hash' });
      db.createObjectStore('mediaChunks', { keyPath: ['hash', 'idx'] });
    },
  });
}

export async function bumpStat(db: JaalDB, key: string, by = 1): Promise<void> {
  const cur = ((await db.get('stats', key)) as { value: number } | undefined)?.value ?? 0;
  await db.put('stats', { key, value: cur + by });
}

export const stat = async (db: JaalDB, key: string): Promise<number> =>
  ((await db.get('stats', key)) as { value: number } | undefined)?.value ?? 0;
