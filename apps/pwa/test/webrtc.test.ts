// QR signalling + framing parity with the Android app (Dart RtcSignal).
import { readFileSync } from 'node:fs';
import { describe, expect, it } from 'vitest';
import { Framer, decodeSignal, encodeSignal } from '../src/core/webrtc';

const v = JSON.parse(readFileSync(new URL('../../../protocol/test-vectors/rtc.json', import.meta.url), 'utf8'));

describe('webrtc signalling', () => {
  it('decodes the code the Android app produced', async () => {
    const d = await decodeSignal(v.code);
    expect(d.kind).toBe('o');
    expect(d.sdp).toBe(v.sdp);
  });

  it('round-trips its own codes', async () => {
    const code = await encodeSignal('a', v.sdp);
    expect(code.startsWith('jaal:rtc:1:a:')).toBe(true);
    expect((await decodeSignal(code)).sdp).toBe(v.sdp);
  });

  it('frames split ≤16 KiB and reassemble', () => {
    for (const n of [0, 1, 16384, 16385, 200000]) {
      const f = new Uint8Array(n).map((_, i) => i & 255);
      const parts = Framer.split(f);
      expect(parts.every((p) => p.length <= 16385)).toBe(true);
      const r = new Framer();
      let out: Uint8Array | null = null;
      for (const p of parts) out = r.push(p);
      expect(out).toEqual(f);
    }
  });
});
