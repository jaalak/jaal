// The PWA must reproduce the Dart protocol byte for byte.
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { b64, unb64 } from '../src/core/bytes';
import { canonical } from '../src/core/canonical';
import { certFromJson, LocalIdentity, RootIdentity, fingerprintOf, verifyCert } from '../src/core/identity';
import { createEvent, eventFromJson, eventId, hashBody, verifyEvent } from '../src/core/event';
import { signingKeyFromSeed } from '../src/core/crypto';

const v = JSON.parse(readFileSync(new URL('../../../protocol/test-vectors/v1.json', import.meta.url), 'utf8'));

describe('protocol v1 vectors', () => {
  it('canonical json', () => {
    for (const c of v.canonicalJson) expect(canonical(c.input)).toBe(c.output);
  });

  it('identity derivations', () => {
    const id = v.identity;
    const root = RootIdentity.fromSeed(unb64(id.rootSeed));
    expect(root.id).toBe(id.rootPublicKey);
    expect(root.recoveryPhrase).toBe(id.recoveryPhrase);
    expect(RootIdentity.fromRecoveryPhrase(id.recoveryPhrase).id).toBe(id.rootPublicKey);
    expect(fingerprintOf(root.id)).toBe(id.fingerprint);
    expect(b64(root.dm.publicKey)).toBe(id.dmPublicKey);
    expect(b64(root.selfKey)).toBe(id.selfKey);
    expect(verifyCert(certFromJson(id.deviceCert))).toBe(true);
    // Re-certifying with the same inputs yields Dart's exact signature.
    const me = LocalIdentity.create(root, id.deviceCert.created, unb64(id.deviceSeed));
    expect(me.feedId).toBe(id.devicePublicKey);
    expect(me.cert.sig).toBe(id.deviceCert.sig);
  });

  it('events: ids, body hashes, signatures — and we sign identically', () => {
    const device = signingKeyFromSeed(unb64(v.identity.deviceSeed));
    for (const x of v.events) {
      const e = eventFromJson(x.event);
      expect(eventId(e)).toBe(x.id);
      expect(hashBody(x.body)).toBe(e.bh);
      expect(verifyEvent(e)).toBe(true);
      const mine = createEvent(device, { seq: e.seq, prev: e.prev, lamport: e.lamport, ts: e.ts, type: e.type, body: x.body });
      expect(mine.sig).toBe(e.sig);
    }
  });
});
