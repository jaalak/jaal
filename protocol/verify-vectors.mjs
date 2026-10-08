// Independent check of protocol/test-vectors/v1.json using only WebCrypto —
// the same primitives the PWA client will have in a browser.
//
//   node protocol/verify-vectors.mjs
import { readFile } from 'node:fs/promises';

const { subtle } = globalThis.crypto;
const v = JSON.parse(await readFile(new URL('./test-vectors/v1.json', import.meta.url)));

/** Canonical JSON (protocol/SPEC.md §2). JS sorts strings by UTF-16 code units. */
function canonical(x) {
  if (x === null || typeof x === 'boolean') return JSON.stringify(x);
  if (typeof x === 'number') {
    if (!Number.isSafeInteger(x)) throw new Error('non-integer number');
    return String(x);
  }
  if (typeof x === 'string') return JSON.stringify(x); // escapes match §2
  if (Array.isArray(x)) return `[${x.map(canonical).join(',')}]`;
  const keys = Object.keys(x).sort();
  return `{${keys.map((k) => `${JSON.stringify(k)}:${canonical(x[k])}`).join(',')}}`;
}

const enc = new TextEncoder();
const b64 = (buf) => Buffer.from(buf).toString('base64url');
const unb64 = (s) => new Uint8Array(Buffer.from(s, 'base64url'));
const sha256 = async (bytes) => new Uint8Array(await subtle.digest('SHA-256', bytes));
const concat = (...parts) => {
  const out = new Uint8Array(parts.reduce((n, p) => n + p.length, 0));
  let o = 0;
  for (const p of parts) { out.set(p, o); o += p.length; }
  return out;
};

async function verifyEd25519(pub, sig, msg) {
  const key = await subtle.importKey('raw', pub, { name: 'Ed25519' }, false, ['verify']);
  return subtle.verify({ name: 'Ed25519' }, key, sig, msg);
}

let failures = 0;
const check = (ok, what) => {
  console.log(`${ok ? 'ok  ' : 'FAIL'} ${what}`);
  if (!ok) failures++;
};

for (const [i, c] of v.canonicalJson.entries()) {
  check(canonical(c.input) === c.output, `canonical json #${i}`);
}

const cert = v.identity.deviceCert;
const { sig: certSig, ...certUnsigned } = cert;
check(
  await verifyEd25519(
    unb64(cert.root), unb64(certSig),
    concat(enc.encode('jaal-devcert-v1:'), enc.encode(canonical(certUnsigned))),
  ),
  'device certificate signature',
);

for (const e of v.events) {
  const { sig, ...unsigned } = e.event;
  const unsignedBytes = enc.encode(canonical(unsigned));
  check(canonical(unsigned) === e.unsignedCanonical, `event ${e.event.seq} canonical form`);
  check(b64(await sha256(unsignedBytes)) === e.id, `event ${e.event.seq} id`);
  check(b64(await sha256(enc.encode(canonical(e.body)))) === e.event.bh, `event ${e.event.seq} body hash`);
  check(
    await verifyEd25519(unb64(e.event.feed), unb64(sig), concat(enc.encode('jaal-event-v1:'), unsignedBytes)),
    `event ${e.event.seq} signature`,
  );
}

function fingerprint(digest, chars = 4) {
  const alphabet = '0123456789abcdefghjkmnpqrstvwxyz';
  let bits = 0, value = 0, out = '';
  for (const b of digest) {
    value = ((value << 8) | b) & 0xffff;
    bits += 8;
    while (bits >= 5 && out.length < chars) {
      out += alphabet[(value >> (bits - 5)) & 31];
      bits -= 5;
    }
    if (out.length >= chars) break;
  }
  return out;
}
check(fingerprint(await sha256(unb64(v.identity.rootPublicKey))) === v.identity.fingerprint, 'fingerprint');
check(b64((await sha256(unb64(v.identity.dmPublicKey))).slice(0, 2)) === v.identity.dmHint, 'dm hint');

console.log(failures ? `\n${failures} failure(s)` : '\nall vectors verified with WebCrypto');
process.exit(failures ? 1 : 0);
