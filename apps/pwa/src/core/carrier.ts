// Sealed envelopes + store-and-forward carrying (SPEC §6), mirroring
// jaal_core messaging/envelope.dart + carrier.dart.
import { b64, concat, randomBytes, unb64 } from './bytes';
import { canonical, canonicalBytes, parseBytes } from './canonical';
import { hkdf, newDhKey, open, seal, sha256, verify } from './crypto';
import { EnvelopeOrigin, EnvelopeRow, JaalDB, MessageRow, bumpStat } from './db';
import { LocalIdentity, RootId, SigDomain, certFromJson, certJson, dmHintOf, verifyCert } from './identity';

export const ENVELOPE_TTL = 14 * 24 * 3600_000;

export interface Envelope { v: number; kind: string; hint: string; epk: string; ack: string; exp: number; nonce: string; ct: string }

const header = (e: Envelope) => ({ v: e.v, kind: e.kind, hint: e.hint, epk: e.epk, ack: e.ack, exp: e.exp });
export const envelopeId = (e: Envelope) => b64(sha256(canonicalBytes(e)));
export const ackHashOf = (secret: string) => b64(sha256(unb64(secret)));
const sealKey = (shared: Uint8Array, epk: Uint8Array, rpk: Uint8Array) => hkdf(shared, concat(epk, rpk), 'jaal-seal-v1');

export function sealDm(me: LocalIdentity, to: RootId, recipientDmKey: string, text: string, now: number) {
  const rpk = unb64(recipientDmKey);
  const eph = newDhKey();
  const ackSecret = b64(randomBytes(32));
  const inner: Record<string, unknown> = { to, from: me.rootId, cert: certJson(me.cert), sentAt: now, text, ackSecret };
  inner.sig = b64(me.device.sign(concat(new TextEncoder().encode(SigDomain.dm), canonicalBytes(inner))));
  const h = { v: 1, kind: 'dm', hint: dmHintOf(rpk), epk: b64(eph.publicKey), ack: ackHashOf(ackSecret), exp: now + ENVELOPE_TTL };
  const nonce = randomBytes(24);
  const ct = seal(sealKey(eph.agree(rpk), eph.publicKey, rpk), nonce, canonicalBytes(inner), canonicalBytes(h));
  return { envelope: { ...h, nonce: b64(nonce), ct: b64(ct) } as Envelope, ackSecret };
}

export interface Opened { from: RootId; text: string; sentAt: number; ackSecret: string }

export function openDm(env: Envelope, me: LocalIdentity): Opened | null {
  if (env.kind !== 'dm' || env.hint !== me.dmHint) return null;
  try {
    const epk = unb64(env.epk);
    const key = sealKey(me.root.dm.agree(epk), epk, me.root.dm.publicKey);
    const clear = open(key, unb64(env.nonce), unb64(env.ct), canonicalBytes(header(env)));
    if (!clear) return null;
    const inner = parseBytes<Record<string, any>>(clear);
    const { sig, ...rest } = inner;
    const cert = certFromJson(rest.cert);
    if (rest.to !== me.rootId || cert.root !== rest.from || !verifyCert(cert)) return null;
    if (!verify(concat(new TextEncoder().encode(SigDomain.dm), canonicalBytes(rest)), unb64(sig), unb64(cert.device))) return null;
    if (ackHashOf(rest.ackSecret) !== env.ack) return null;
    return { from: cert.root, text: rest.text, sentAt: rest.sentAt, ackSecret: rest.ackSecret };
  } catch {
    return null;
  }
}

export type CarrierEvent = { kind: 'envelope'; id: string; exp: number } | { kind: 'ack'; secret: string; exp: number } | { kind: 'message' };

export class Carrier {
  private listeners = new Set<(e: CarrierEvent) => void>();
  constructor(readonly db: JaalDB, readonly me: LocalIdentity, readonly now: () => number, readonly maxCarryBytes = 20 * 1024 * 1024) {}

  onChange(l: (e: CarrierEvent) => void) {
    this.listeners.add(l);
    return () => this.listeners.delete(l);
  }
  private emit(e: CarrierEvent) {
    for (const l of this.listeners) l(e);
  }

  async sendDm(to: RootId, text: string): Promise<void> {
    const p = await this.db.get('profiles', to);
    if (!p) throw new Error('their profile (key) hasn\'t reached this phone yet');
    const { envelope } = sealDm(this.me, to, p.dmKey, text, this.now());
    const id = envelopeId(envelope);
    await this.put(envelope, EnvelopeOrigin.sent, 0, false);
    await this.db.put('messages', { id, peerRoot: to, outgoing: true, body: text, sentAt: this.now(), receivedAt: null, ackHash: envelope.ack, delivered: false } satisfies MessageRow);
    this.emit({ kind: 'envelope', id, exp: envelope.exp });
  }

  knows = async (id: string) => !!(await this.db.get('envelopes', id));

  async accept(env: Envelope, hops: number): Promise<boolean> {
    const id = envelopeId(env);
    if (env.exp <= this.now() || (await this.db.get('envelopes', id)) || (await this.db.get('acks', env.ack))) return false;
    const opened = openDm(env, this.me);
    if (opened) {
      const banned = (await this.db.get('modStatus', opened.from))?.state === 2;
      const blocked = !!(await this.db.get('blocks', opened.from));
      await this.put(env, EnvelopeOrigin.received, hops + 1, true);
      if (!banned && !blocked) {
        await this.db.put('messages', { id, peerRoot: opened.from, outgoing: false, body: opened.text, sentAt: opened.sentAt, receivedAt: this.now(), ackHash: env.ack, delivered: true } satisfies MessageRow);
        this.emit({ kind: 'message' });
      }
      await this.db.put('acks', { ackHash: env.ack, secret: opened.ackSecret, exp: env.exp });
      this.emit({ kind: 'ack', secret: opened.ackSecret, exp: env.exp });
      return true;
    }
    const size = canonical(env).length;
    if (size > this.maxCarryBytes) return false;
    await this.put(env, EnvelopeOrigin.carried, hops + 1, false);
    await bumpStat(this.db, 'courier.carried');
    this.emit({ kind: 'envelope', id, exp: env.exp });
    return true;
  }

  async acceptAck(secret: string, exp: number): Promise<boolean> {
    if (exp <= this.now()) return false;
    const hash = ackHashOf(secret);
    if (await this.db.get('acks', hash)) return false;
    await this.db.put('acks', { ackHash: hash, secret, exp });
    for (const e of (await this.db.getAllFromIndex('envelopes', 'ackHash', hash)) as EnvelopeRow[]) {
      if (e.acked) continue;
      await this.db.put('envelopes', { ...e, acked: true, raw: '' });
      if (e.origin === EnvelopeOrigin.carried) await bumpStat(this.db, 'courier.delivered');
    }
    for (const m of (await this.db.getAll('messages')) as MessageRow[]) {
      if (m.outgoing && m.ackHash === hash && !m.delivered) await this.db.put('messages', { ...m, delivered: true });
    }
    this.emit({ kind: 'ack', secret, exp });
    return true;
  }

  async read(id: string): Promise<Envelope | null> {
    const r = (await this.db.get('envelopes', id)) as EnvelopeRow | undefined;
    return r && !r.acked && r.raw ? JSON.parse(r.raw) : null;
  }

  private async put(env: Envelope, origin: number, hops: number, acked: boolean) {
    const raw = canonical(env);
    await this.db.put('envelopes', { id: envelopeId(env), raw, hint: env.hint, ackHash: env.ack, exp: env.exp, size: raw.length, receivedAt: this.now(), hops, origin, acked } satisfies EnvelopeRow);
  }
}
