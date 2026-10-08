// Content-addressed photos split into verified 64 KiB chunks (SPEC §8).
import { b64 } from './bytes';
import { canonical, parse } from './canonical';
import { sha256 } from './crypto';
import { JaalDB, MediaBlobRow } from './db';

export const CHUNK = 64 * 1024;

export interface Manifest {
  hash: string;
  mime: string;
  size: number;
  chunkSize: number;
  chunks: string[];
  w: number | null;
  h: number | null;
  dur: number | null;
}

/** Field order/nulls match Dart's MediaManifest.toJson (body hashes depend on it). */
export function manifestFor(data: Uint8Array, mime: string, w: number | null, h: number | null): Manifest {
  const chunks: string[] = [];
  for (let o = 0; o < data.length; o += CHUNK) chunks.push(b64(sha256(data.subarray(o, Math.min(o + CHUNK, data.length)))));
  return { hash: b64(sha256(data)), mime, size: data.length, chunkSize: CHUNK, chunks, w, h, dur: null };
}

type Listener = (hash: string) => void;

export class MediaStore {
  private listeners = new Set<Listener>();
  constructor(readonly db: JaalDB, readonly now: () => number) {}

  onChange(l: Listener) {
    this.listeners.add(l);
    return () => this.listeners.delete(l);
  }
  private emit(h: string) {
    for (const l of this.listeners) l(h);
  }

  async putLocal(data: Uint8Array, mime: string, owner: string, w: number | null, h: number | null): Promise<Manifest> {
    const m = manifestFor(data, mime, w, h);
    await this.db.put('mediaBlobs', {
      hash: m.hash, manifest: canonical(m), mime, size: m.size, chunkCount: m.chunks.length,
      chunksHeld: m.chunks.length, complete: true, rootId: owner, createdAt: this.now(),
    } satisfies MediaBlobRow);
    for (let i = 0; i < m.chunks.length; i++) {
      await this.db.put('mediaChunks', { hash: m.hash, idx: i, data: data.slice(i * CHUNK, (i + 1) * CHUNK) });
    }
    this.emit(m.hash);
    return m;
  }

  async expect(manifest: any, owner: string, now: number): Promise<void> {
    if (!manifest || typeof manifest !== 'object' || !Array.isArray(manifest.chunks)) return;
    if (manifest.chunks.length === 0 || manifest.chunks.length > 4096) return;
    if (await this.db.get('mediaBlobs', manifest.hash)) return;
    await this.db.put('mediaBlobs', {
      hash: manifest.hash, manifest: canonical(manifest), mime: manifest.mime, size: manifest.size,
      chunkCount: manifest.chunks.length, chunksHeld: 0, complete: false, rootId: owner, createdAt: now,
    } satisfies MediaBlobRow);
    this.emit(manifest.hash);
  }

  blob = (hash: string) => this.db.get('mediaBlobs', hash) as Promise<MediaBlobRow | undefined>;

  async chunk(hash: string, idx: number): Promise<Uint8Array | null> {
    return ((await this.db.get('mediaChunks', [hash, idx])) as { data: Uint8Array } | undefined)?.data ?? null;
  }

  async addChunk(hash: string, idx: number, data: Uint8Array): Promise<boolean> {
    const b = await this.blob(hash);
    if (!b || b.complete || idx < 0 || idx >= b.chunkCount) return false;
    const m = parse<Manifest>(b.manifest);
    if (b64(sha256(data)) !== m.chunks[idx]) return false;
    if (await this.db.get('mediaChunks', [hash, idx])) return false;
    await this.db.put('mediaChunks', { hash, idx, data });
    let held = b.chunksHeld + 1;
    let complete = held >= b.chunkCount;
    if (complete) {
      const whole = await this.read(hash, true);
      complete = !!whole && b64(sha256(whole)) === hash;
      if (!complete) {
        for (let i = 0; i < b.chunkCount; i++) await this.db.delete('mediaChunks', [hash, i]);
        held = 0;
      }
    }
    await this.db.put('mediaBlobs', { ...b, chunksHeld: held, complete });
    this.emit(hash);
    return true;
  }

  async read(hash: string, force = false): Promise<Uint8Array | null> {
    const b = await this.blob(hash);
    if (!b || (!b.complete && !force)) return null;
    const parts: Uint8Array[] = [];
    for (let i = 0; i < b.chunkCount; i++) {
      const c = await this.chunk(hash, i);
      if (!c) return null;
      parts.push(c);
    }
    const out = new Uint8Array(parts.reduce((n, p) => n + p.length, 0));
    let o = 0;
    for (const p of parts) {
      out.set(p, o);
      o += p.length;
    }
    return out;
  }

  async wanted(maxChunks: number, skip: Set<string>): Promise<[string, number[]][]> {
    const blobs = ((await this.db.getAll('mediaBlobs')) as MediaBlobRow[])
      .filter((b) => !b.complete)
      .sort((a, b) => b.createdAt - a.createdAt)
      .slice(0, 64);
    const out: [string, number[]][] = [];
    let budget = maxChunks;
    for (const b of blobs) {
      if (budget <= 0) break;
      const missing: number[] = [];
      for (let i = 0; i < b.chunkCount && missing.length < budget; i++) {
        if (!skip.has(`${b.hash}:${i}`) && !(await this.db.getKey('mediaChunks', [b.hash, i]))) missing.push(i);
      }
      if (missing.length) {
        out.push([b.hash, missing]);
        budget -= missing.length;
      }
    }
    return out;
  }

  async drop(hash: string) {
    const b = await this.blob(hash);
    if (!b) return;
    for (let i = 0; i < b.chunkCount; i++) await this.db.delete('mediaChunks', [hash, i]);
    await this.db.delete('mediaBlobs', hash);
  }
}

/** Browser-side photo crunch: long edge ≤ maxEdge, JPEG stepped down to fit. */
export async function compressPhoto(file: Blob, opts: { maxEdge?: number; targetBytes?: number; xerox?: boolean } = {}) {
  const maxEdge = opts.maxEdge ?? 1440;
  const target = opts.targetBytes ?? 450 * 1024;
  const bmp = await createImageBitmap(file);
  const scale = Math.min(1, maxEdge / Math.max(bmp.width, bmp.height));
  const w = Math.round(bmp.width * scale);
  const h = Math.round(bmp.height * scale);
  const canvas = document.createElement('canvas');
  canvas.width = w;
  canvas.height = h;
  const ctx = canvas.getContext('2d')!;
  if (opts.xerox) ctx.filter = 'grayscale(1) contrast(1.6) brightness(1.05)';
  ctx.drawImage(bmp, 0, 0, w, h);
  let q = 0.8;
  let blob: Blob = await new Promise((r) => canvas.toBlob((b) => r(b!), 'image/jpeg', q));
  while (blob.size > target && q > 0.3) {
    q -= 0.08;
    blob = await new Promise((r) => canvas.toBlob((b) => r(b!), 'image/jpeg', q));
  }
  return { bytes: new Uint8Array(await blob.arrayBuffer()), w, h, mime: 'image/jpeg' };
}
