// Cross-language interop: a real Dart node (jaal_core) and a browser node
// (this package) sync over WebSocket — profiles, posts, chunked photos and
// sealed DMs in both directions.
import { spawn } from 'node:child_process';
import { createInterface } from 'node:readline';
import { fileURLToPath } from 'node:url';
import { describe, expect, it } from 'vitest';
import { b64 } from '../src/core/bytes';
import { sha256 } from '../src/core/crypto';
import { openJaalDB } from '../src/core/db';
import { LocalIdentity, RootIdentity } from '../src/core/identity';
import { JaalNode } from '../src/core/node';
import { connectWebSocket } from '../src/core/ws';

const coreDir = fileURLToPath(new URL('../../../packages/jaal_core', import.meta.url));
const dart = process.env.JAAL_DART ?? (process.platform === 'win32' ? 'C:/flutter/bin/dart.bat' : 'dart');

async function until(f: () => Promise<boolean>, ms = 30000) {
  const t = Date.now();
  while (!(await f())) {
    if (Date.now() - t > ms) throw new Error('timeout');
    await new Promise((r) => setTimeout(r, 25));
  }
}

describe('dart ↔ browser interop', () => {
  it('syncs posts, photos and DMs both ways', async () => {
    const proc = spawn(dart, ['run', 'tool/interop_peer.dart'], { cwd: coreDir, shell: process.platform === 'win32' });
    const lines: any[] = [];
    createInterface({ input: proc.stdout }).on('line', (l) => {
      try {
        lines.push(JSON.parse(l));
      } catch {
        /* build output */
      }
    });
    const next = async (key: string) => {
      await until(async () => lines.some((l) => key in l), 120000);
      return lines.splice(lines.findIndex((l) => key in l), 1)[0];
    };
    try {
      const ready = await next('ready');
      const db = await openJaalDB('interop');
      const me = LocalIdentity.create(RootIdentity.generate(), Date.now());
      const web = await JaalNode.open(db, me);
      await web.setProfile('Web', 'web_peer', 'hello from safari land');
      const photo = new Uint8Array(100_000).map((_, i) => (i * 13) & 255);
      await web.postPhoto('posted from the browser', { bytes: photo, mime: 'image/jpeg', w: 600, h: 600 });

      web.connect(await connectWebSocket(`ws://127.0.0.1:${ready.ready}`));

      // Dart → browser: profile, post, photo chunks.
      await until(async () => (await web.allPosts()).some((p) => p.body === 'posted from dart'));
      const dartPost = (await web.allPosts()).find((p) => p.body === 'posted from dart')!;
      const m = JaalNode.mediaOf(dartPost)[0];
      await until(async () => !!(await web.media.read(m.hash)));
      expect((await web.profile(ready.root))?.handle).toBe('dart_peer');

      // Browser → Dart DM, Dart → browser DM.
      await web.sendDm(ready.root, 'hi from the browser');
      proc.stdin.write(`dm ${me.rootId} hi from dart\n`);
      await next('ok');
      await until(async () => (await web.inbox()).some((x) => x.body === 'hi from dart'));

      // Dart side state.
      await until(async () => {
        proc.stdin.write('dump\n');
        const d = await next('posts');
        return d.posts.includes('posted from the browser') && d.messages.some((x: any) => x.body === 'hi from the browser') &&
          d.photos.includes(b64(sha256(photo)));
      });
      // Receipts: the browser's letter to Dart shows delivered.
      await until(async () => (await web.conversation(ready.root)).some((x) => x.outgoing && x.delivered));
    } finally {
      proc.stdin.write('quit\n');
      setTimeout(() => proc.kill(), 2000);
    }
  }, 240000);
});
