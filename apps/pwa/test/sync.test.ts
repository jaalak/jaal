// Two browser nodes syncing over an in-memory link: posts, photos (chunked),
// sealed DMs with receipts, store-and-forward, and moderation.
import { describe, expect, it } from 'vitest';
import { openJaalDB } from '../src/core/db';
import { LocalIdentity, RootIdentity, MeetPurpose, createMeetCode } from '../src/core/identity';
import { JaalNode } from '../src/core/node';
import { defaultModeration } from '../src/core/store';
import { memoryPair } from '../src/core/sync';

let n = 0;
async function node(name: string, genesis: string[] = [], root = RootIdentity.generate()) {
  const db = await openJaalDB(`test-${name}-${++n}`);
  const me = LocalIdentity.create(root, Date.now());
  const node = await JaalNode.open(db, me, { moderation: defaultModeration(genesis) });
  await node.setProfile(name, name.toLowerCase());
  return node;
}

function link(a: JaalNode, b: JaalNode) {
  const [x, y] = memoryPair();
  a.connect(x);
  b.connect(y);
  return () => x.close();
}

async function until(f: () => Promise<boolean>, ms = 10000) {
  const t = Date.now();
  while (!(await f())) {
    if (Date.now() - t > ms) throw new Error('timeout');
    await new Promise((r) => setTimeout(r, 10));
  }
}

describe('browser nodes', () => {
  it('sync posts and photos; photos reassemble byte-exact', async () => {
    const a = await node('Ana');
    const b = await node('Ben');
    const photo = new Uint8Array(150_000).map((_, i) => (i * 31) & 255);
    const p = await a.postPhoto('summit', { bytes: photo, mime: 'image/jpeg', w: 900, h: 900 });
    link(a, b);
    await until(async () => (await b.allPosts()).length >= 1);
    const row = (await b.allPosts())[0];
    const m = JaalNode.mediaOf(row)[0];
    await until(async () => !!(await b.media.read(m.hash)));
    expect(await b.media.read(m.hash)).toEqual(photo);
    expect((await b.profile(a.rootId))?.handle).toBe('ana');
    expect(row.hops).toBe(1);
    void p;
  });

  it('DM carried by a stranger, delivered, receipt flows back', async () => {
    const a = await node('Ana');
    const c = await node('Cy');
    const s = await node('Stranger');
    let cut = link(a, c);
    await until(async () => !!(await a.profile(c.rootId)));
    cut();
    await a.sendDm(c.rootId, 'carried by a courier');
    cut = link(a, s);
    await until(async () => (await s.db.getAll('envelopes')).length >= 1);
    cut();
    cut = link(s, c);
    await until(async () => (await c.inbox()).length >= 1);
    expect((await c.inbox())[0].body).toBe('carried by a courier');
    cut();
    link(s, a);
    await until(async () => (await a.conversation(c.rootId))[0]?.delivered === true);
  });

  it('moderation: 3 vouches promote, 2 votes ban and purge', async () => {
    const roots = [RootIdentity.generate(), RootIdentity.generate(), RootIdentity.generate()];
    const genesis = roots.map((r) => r.id);
    const [g1, g2, g3] = await Promise.all(roots.map((r, i) => node(`G${i}`, genesis, r)));
    const troll = await node('Troll', genesis);
    const fan = await node('Fan', genesis);
    const all = [g1, g2, g3, troll, fan];
    for (let i = 0; i < all.length; i++) for (let j = i + 1; j < all.length; j++) link(all[i], all[j]);
    await until(async () => (await fan.profiles()).length >= 5);

    const consent = createMeetCode(fan.me, 'fan', Date.now(), MeetPurpose.moderator);
    for (const g of [g1, g2, g3]) await g.store.append('mod.vouch', { candidate: fan.rootId, consent });
    await until(async () => troll.store.moderation.isModerator(fan.rootId));

    await fan.follow(troll.rootId);
    const p = await troll.post('vile');
    await until(async () => !!(await fan.post_(p ? (p as any).id ?? '' : '')) || (await fan.allPosts()).length > 0);
    await g1.store.append('mod.ban', { target: troll.rootId, on: true, reason: 'harassment' });
    await fan.store.append('mod.ban', { target: troll.rootId, on: true, reason: 'harassment' });
    await until(async () => g2.store.moderation.isBanned(troll.rootId));
    await until(async () => troll.store.moderation.isBanned(troll.rootId));
    await expect(troll.post('let me in')).rejects.toThrow(/removed/);
  });
});
