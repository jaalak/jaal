// Canonical JSON (protocol/SPEC.md §2) — must match Dart's CanonicalJson
// byte for byte: sorted keys (UTF-16 code units), integers only, minimal
// escaping, no whitespace.
import { fromUtf8, utf8 } from './bytes';

export type Json = null | boolean | number | string | Json[] | { [k: string]: Json };

export function canonical(x: unknown): string {
  if (x === null || x === undefined) return 'null';
  if (typeof x === 'boolean') return x ? 'true' : 'false';
  if (typeof x === 'number') {
    if (!Number.isSafeInteger(x)) throw new Error(`non-integer number in canonical JSON: ${x}`);
    return String(x);
  }
  if (typeof x === 'string') return JSON.stringify(x);
  if (Array.isArray(x)) return `[${x.map(canonical).join(',')}]`;
  if (x instanceof Uint8Array) throw new Error('encode bytes as base64url first');
  const o = x as Record<string, unknown>;
  // Dart keeps keys whose value is null; drop only `undefined`.
  const keys = Object.keys(o).filter((k) => o[k] !== undefined).sort();
  return `{${keys.map((k) => `${JSON.stringify(k)}:${canonical(o[k])}`).join(',')}}`;
}

export const canonicalBytes = (x: unknown): Uint8Array => utf8(canonical(x));

export function parse<T = any>(s: string): T {
  const v = JSON.parse(s);
  assertNoFloats(v);
  return v as T;
}

export const parseBytes = <T = any>(b: Uint8Array): T => parse<T>(fromUtf8(b));

function assertNoFloats(v: unknown): void {
  if (typeof v === 'number' && !Number.isInteger(v)) throw new Error('floats are not allowed');
  if (Array.isArray(v)) v.forEach(assertNoFloats);
  else if (v && typeof v === 'object') Object.values(v).forEach(assertNoFloats);
}
