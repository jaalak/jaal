// Primitives (protocol/SPEC.md §3): Ed25519, X25519, HKDF-SHA256,
// XChaCha20-Poly1305, SHA-256. Pure JS (noble) so Safari/iOS works everywhere.
import { ed25519, x25519 } from '@noble/curves/ed25519.js';
import { xchacha20poly1305 } from '@noble/ciphers/chacha.js';
import { hkdf as nobleHkdf } from '@noble/hashes/hkdf.js';
import { sha256 as nobleSha256 } from '@noble/hashes/sha2.js';
import { randomBytes, utf8 } from './bytes';

export const sha256 = (data: Uint8Array): Uint8Array => nobleSha256(data);

export interface SigningKey {
  readonly publicKey: Uint8Array;
  sign(message: Uint8Array): Uint8Array;
}

export function signingKeyFromSeed(seed: Uint8Array): SigningKey {
  if (seed.length !== 32) throw new Error('seed must be 32 bytes');
  const sk = seed.slice();
  const publicKey = ed25519.getPublicKey(sk);
  return { publicKey, sign: (m) => ed25519.sign(m, sk) };
}

export function verify(message: Uint8Array, signature: Uint8Array, publicKey: Uint8Array): boolean {
  if (signature.length !== 64 || publicKey.length !== 32) return false;
  try {
    return ed25519.verify(signature, message, publicKey);
  } catch {
    return false;
  }
}

export interface DhKey {
  readonly publicKey: Uint8Array;
  agree(remote: Uint8Array): Uint8Array;
}

export function dhKeyFromSeed(seed: Uint8Array): DhKey {
  const sk = seed.slice();
  return { publicKey: x25519.getPublicKey(sk), agree: (r) => x25519.getSharedSecret(sk, r) };
}

export const newDhKey = (): DhKey => dhKeyFromSeed(randomBytes(32));

export const hkdf = (ikm: Uint8Array, salt: Uint8Array, info: string, length = 32): Uint8Array =>
  nobleHkdf(nobleSha256, ikm, salt, utf8(info), length);

/** Returns ciphertext‖tag (16-byte Poly1305 tag appended), like Dart. */
export const seal = (key: Uint8Array, nonce: Uint8Array, plaintext: Uint8Array, aad: Uint8Array): Uint8Array =>
  xchacha20poly1305(key, nonce, aad).encrypt(plaintext);

export function open(key: Uint8Array, nonce: Uint8Array, sealed: Uint8Array, aad: Uint8Array): Uint8Array | null {
  try {
    return xchacha20poly1305(key, nonce, aad).decrypt(sealed);
  } catch {
    return null;
  }
}
