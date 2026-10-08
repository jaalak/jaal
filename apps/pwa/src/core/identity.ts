// Identity (protocol/SPEC.md §3.1): root key ↔ 24 BIP39 words, device keys
// certified by the root, derived DM / self / moderation-feed keys.
import { entropyToMnemonic, mnemonicToEntropy } from '@scure/bip39';
import { wordlist } from '@scure/bip39/wordlists/english.js';
import { b64, concat, fingerprint, randomBytes, unb64, utf8 } from './bytes';
import { canonical, canonicalBytes } from './canonical';
import { DhKey, SigningKey, dhKeyFromSeed, hkdf, sha256, signingKeyFromSeed, verify } from './crypto';

export type RootId = string;
export type FeedId = string;

export const SigDomain = {
  deviceCert: 'jaal-devcert-v1:',
  event: 'jaal-event-v1:',
  dm: 'jaal-dm-v1:',
  auth: 'jaal-auth-v1:',
  meet: 'jaal-meet-v1:',
  revoke: 'jaal-revoke-v1:',
} as const;

export const signedBytes = (domain: string, value: unknown): Uint8Array =>
  concat(utf8(domain), canonicalBytes(value));

export interface DeviceCert {
  root: RootId;
  device: FeedId;
  created: number;
  sig: string;
  purpose?: string;
}

export const MOD_PURPOSE = 'mod';

export function certUnsigned(c: DeviceCert): Record<string, unknown> {
  const u: Record<string, unknown> = { root: c.root, device: c.device, created: c.created };
  if (c.purpose != null) u.purpose = c.purpose;
  return u;
}

export const certJson = (c: DeviceCert) => ({ ...certUnsigned(c), sig: c.sig });

export function certFromJson(j: any): DeviceCert {
  return { root: j.root, device: j.device, created: j.created, sig: j.sig, purpose: j.purpose ?? undefined };
}

export const verifyCert = (c: DeviceCert): boolean =>
  verify(signedBytes(SigDomain.deviceCert, certUnsigned(c)), unb64(c.sig), unb64(c.root));

export class RootIdentity {
  private constructor(
    readonly seed: Uint8Array,
    readonly signing: SigningKey,
    readonly dm: DhKey,
    readonly selfKey: Uint8Array,
  ) {}

  get id(): RootId {
    return b64(this.signing.publicKey);
  }

  static fromSeed(seed: Uint8Array): RootIdentity {
    const salt = utf8('jaal');
    return new RootIdentity(
      seed.slice(),
      signingKeyFromSeed(seed),
      dhKeyFromSeed(hkdf(seed, salt, 'jaal-dm-x25519-v1')),
      hkdf(seed, salt, 'jaal-self-aead-v1'),
    );
  }

  static generate = () => RootIdentity.fromSeed(randomBytes(32));

  get recoveryPhrase(): string {
    return entropyToMnemonic(this.seed, wordlist);
  }

  static fromRecoveryPhrase(phrase: string): RootIdentity {
    const normalized = phrase.trim().toLowerCase().split(/\s+/).join(' ');
    return RootIdentity.fromSeed(mnemonicToEntropy(normalized, wordlist));
  }

  certify(device: FeedId, created: number, purpose?: string): DeviceCert {
    const c: DeviceCert = { root: this.id, device, created, sig: '', purpose };
    c.sig = b64(this.signing.sign(signedBytes(SigDomain.deviceCert, certUnsigned(c))));
    return c;
  }
}

export const fingerprintOf = (root: RootId): string => fingerprint(sha256(unb64(root)));

export function longFingerprintOf(root: RootId): string {
  const f = fingerprint(sha256(unb64(root)), 16);
  return [0, 4, 8, 12].map((i) => f.slice(i, i + 4)).join(' ');
}

export const dmHintOf = (dmPublicKey: Uint8Array): string => b64(sha256(dmPublicKey).slice(0, 2));

/** One user on one device (this browser). */
export class LocalIdentity {
  private mod?: { key: SigningKey; cert: DeviceCert };

  private constructor(
    readonly root: RootIdentity,
    readonly device: SigningKey,
    readonly deviceSeed: Uint8Array,
    readonly cert: DeviceCert,
  ) {}

  get rootId(): RootId {
    return this.root.id;
  }
  get feedId(): FeedId {
    return b64(this.device.publicKey);
  }
  get dmPublicKey(): string {
    return b64(this.root.dm.publicKey);
  }
  get dmHint(): string {
    return dmHintOf(this.root.dm.publicKey);
  }

  static create(root: RootIdentity, now: number, deviceSeed = randomBytes(32)): LocalIdentity {
    const device = signingKeyFromSeed(deviceSeed);
    return new LocalIdentity(root, device, deviceSeed, root.certify(b64(device.publicKey), now));
  }

  static restore(rootSeed: Uint8Array, deviceSeed: Uint8Array, cert: DeviceCert): LocalIdentity {
    return new LocalIdentity(RootIdentity.fromSeed(rootSeed), signingKeyFromSeed(deviceSeed), deviceSeed, cert);
  }

  /** Separate feed for this device's moderation actions (SPEC §10.4). */
  moderationFeed(): { key: SigningKey; cert: DeviceCert } {
    if (!this.mod) {
      const key = signingKeyFromSeed(hkdf(this.root.seed, this.device.publicKey, 'jaal-modfeed-v1'));
      this.mod = { key, cert: this.root.certify(b64(key.publicKey), this.cert.created, MOD_PURPOSE) };
    }
    return this.mod;
  }
}

// ------------------------------------------------------------ meet codes (QR)

export const MeetPurpose = { meet: 'meet', moderator: 'mod' } as const;

export interface MeetCode {
  purpose: string;
  root: RootId;
  dm: string;
  handle: string;
  nonce: string;
  ts: number;
  sig: string;
}

const MEET_PREFIX = 'jaal:1:';
const meetUnsigned = (c: MeetCode) => ({
  purpose: c.purpose,
  root: c.root,
  dm: c.dm,
  handle: c.handle,
  nonce: c.nonce,
  ts: c.ts,
});

export function createMeetCode(me: LocalIdentity, handle: string, now: number, purpose = 'meet'): MeetCode {
  const c: MeetCode = { purpose, root: me.rootId, dm: me.dmPublicKey, handle, nonce: b64(randomBytes(12)), ts: now, sig: '' };
  c.sig = b64(me.root.signing.sign(signedBytes(SigDomain.meet, meetUnsigned(c))));
  return c;
}

export const encodeMeetCode = (c: MeetCode): string => MEET_PREFIX + b64(utf8(canonical(c)));

export function decodeMeetCode(text: string): MeetCode {
  const t = text.trim();
  if (!t.startsWith(MEET_PREFIX)) throw new Error('not a jaal code');
  return JSON.parse(new TextDecoder().decode(unb64(t.slice(MEET_PREFIX.length))));
}

export const verifyMeetCode = (c: MeetCode): boolean =>
  verify(signedBytes(SigDomain.meet, meetUnsigned(c)), unb64(c.sig), unb64(c.root));
