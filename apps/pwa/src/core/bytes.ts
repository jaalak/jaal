// Byte helpers shared by the whole protocol (mirrors jaal_core util/bytes.dart).

const enc = new TextEncoder();
const dec = new TextDecoder();

export const utf8 = (s: string): Uint8Array => enc.encode(s);
export const fromUtf8 = (b: Uint8Array): string => dec.decode(b);

/** Unpadded base64url — the only binary-to-text encoding on the wire. */
export function b64(bytes: Uint8Array): string {
  let s = '';
  for (let i = 0; i < bytes.length; i++) s += String.fromCharCode(bytes[i]);
  return btoa(s).replace(/\+/g, '-').replace(/\//g, '_').replace(/=+$/, '');
}

export function unb64(s: string): Uint8Array {
  const pad = (4 - (s.length % 4)) % 4;
  if (pad === 3) throw new Error('invalid base64url length');
  const bin = atob(s.replace(/-/g, '+').replace(/_/g, '/') + '='.repeat(pad));
  const out = new Uint8Array(bin.length);
  for (let i = 0; i < bin.length; i++) out[i] = bin.charCodeAt(i);
  return out;
}

export function concat(...parts: Uint8Array[]): Uint8Array {
  const out = new Uint8Array(parts.reduce((n, p) => n + p.length, 0));
  let o = 0;
  for (const p of parts) {
    out.set(p, o);
    o += p.length;
  }
  return out;
}

export function randomBytes(n: number): Uint8Array {
  const b = new Uint8Array(n);
  crypto.getRandomValues(b);
  return b;
}

export function bytesEqual(a: Uint8Array, b: Uint8Array): boolean {
  if (a.length !== b.length) return false;
  let d = 0;
  for (let i = 0; i < a.length; i++) d |= a[i] ^ b[i];
  return d === 0;
}

/** Crockford base32 prefix of a digest: `k7f2` (same bit order as Dart). */
export function fingerprint(digest: Uint8Array, chars = 4): string {
  const alphabet = '0123456789abcdefghjkmnpqrstvwxyz';
  let bits = 0;
  let value = 0;
  let out = '';
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
