// WebRTC data channel link, signalled by QR codes — no server, no internet.
// Same Wi-Fi / hotspot: host candidates connect the two phones directly.
//
//   A: offer = await createOffer()      → show QR(offer.code)
//   B: answer = await answerOffer(code) → show QR(answer.code)   (B is live)
//   A: await offer.accept(answerCode)                            (A is live)
//
// Wire format (shared with apps/mobile/lib/transport/webrtc_link.dart):
//   code  = "jaal:rtc:1:" + ("o"|"a") + ":" + b64url(deflate-raw(utf8(sdp)))
//   frame = 1-byte flag (1 = last piece) + ≤16 KiB piece   (Safari caps messages)
import { b64, unb64 } from './bytes';
import { PeerConnection } from './sync';

const PREFIX = 'jaal:rtc:1:';
const PIECE = 16 * 1024;

async function deflate(data: Uint8Array): Promise<Uint8Array> {
  const s = new Blob([data as BlobPart]).stream().pipeThrough(new CompressionStream('deflate-raw'));
  return new Uint8Array(await new Response(s).arrayBuffer());
}
async function inflate(data: Uint8Array): Promise<Uint8Array> {
  const s = new Blob([data as BlobPart]).stream().pipeThrough(new DecompressionStream('deflate-raw'));
  return new Uint8Array(await new Response(s).arrayBuffer());
}

export async function encodeSignal(kind: 'o' | 'a', sdp: string): Promise<string> {
  return `${PREFIX}${kind}:${b64(await deflate(new TextEncoder().encode(sdp)))}`;
}

export async function decodeSignal(code: string): Promise<{ kind: 'o' | 'a'; sdp: string }> {
  const t = code.trim();
  if (!t.startsWith(PREFIX)) throw new Error('not a jaal connect code');
  const [kind, data] = t.slice(PREFIX.length).split(':');
  if (kind !== 'o' && kind !== 'a') throw new Error('bad connect code');
  return { kind, sdp: new TextDecoder().decode(await inflate(unb64(data))) };
}

/** Splits/reassembles protocol frames over a data channel. */
export class Framer {
  private parts: Uint8Array[] = [];
  static split(frame: Uint8Array): Uint8Array[] {
    const out: Uint8Array[] = [];
    for (let o = 0; o < frame.length || o === 0; o += PIECE) {
      const piece = frame.subarray(o, Math.min(o + PIECE, frame.length));
      const last = o + PIECE >= frame.length;
      const m = new Uint8Array(piece.length + 1);
      m[0] = last ? 1 : 0;
      m.set(piece, 1);
      out.push(m);
      if (last) break;
    }
    return out;
  }
  push(msg: Uint8Array): Uint8Array | null {
    this.parts.push(msg.subarray(1));
    if (msg[0] !== 1) return null;
    const total = this.parts.reduce((n, p) => n + p.length, 0);
    const out = new Uint8Array(total);
    let o = 0;
    for (const p of this.parts) {
      out.set(p, o);
      o += p.length;
    }
    this.parts = [];
    return out;
  }
}

function waitIce(pc: RTCPeerConnection, ms = 4000): Promise<void> {
  if (pc.iceGatheringState === 'complete') return Promise.resolve();
  return new Promise((r) => {
    const t = setTimeout(r, ms);
    pc.addEventListener('icegatheringstatechange', () => {
      if (pc.iceGatheringState === 'complete') {
        clearTimeout(t);
        r();
      }
    });
  });
}

function wrap(pc: RTCPeerConnection, ch: RTCDataChannel): PeerConnection {
  ch.binaryType = 'arraybuffer';
  const framer = new Framer();
  let frameCb: (f: Uint8Array) => void = () => {};
  let closeCb: () => void = () => {};
  ch.onmessage = (m) => {
    const f = framer.push(new Uint8Array(m.data as ArrayBuffer));
    if (f) frameCb(f);
  };
  const end = () => closeCb();
  ch.onclose = end;
  pc.onconnectionstatechange = () => {
    if (pc.connectionState === 'failed' || pc.connectionState === 'closed') end();
  };
  return {
    label: 'webrtc',
    get open() {
      return ch.readyState === 'open';
    },
    send: (f) => Framer.split(f).forEach((p) => ch.send(p as Uint8Array<ArrayBuffer>)),
    onFrame: (cb) => (frameCb = cb),
    onClose: (cb) => (closeCb = cb),
    close: () => {
      ch.close();
      pc.close();
    },
  };
}

const channelOpen = (ch: RTCDataChannel) =>
  new Promise<void>((r, j) => {
    if (ch.readyState === 'open') return r();
    ch.onopen = () => r();
    ch.onerror = () => j(new Error('data channel failed'));
  });

export async function createOffer(): Promise<{ code: string; accept(answer: string): Promise<PeerConnection> }> {
  const pc = new RTCPeerConnection({ iceServers: [] });
  const ch = pc.createDataChannel('jaal', { ordered: true });
  await pc.setLocalDescription(await pc.createOffer());
  await waitIce(pc);
  return {
    code: await encodeSignal('o', pc.localDescription!.sdp),
    async accept(answer: string) {
      const a = await decodeSignal(answer);
      if (a.kind !== 'a') throw new Error('that is an offer — scan their answer code');
      await pc.setRemoteDescription({ type: 'answer', sdp: a.sdp });
      await channelOpen(ch);
      return wrap(pc, ch);
    },
  };
}

export async function answerOffer(offer: string): Promise<{ code: string; connection: Promise<PeerConnection> }> {
  const o = await decodeSignal(offer);
  if (o.kind !== 'o') throw new Error('that is an answer — scan their offer code');
  const pc = new RTCPeerConnection({ iceServers: [] });
  const conn = new Promise<PeerConnection>((r) => {
    pc.ondatachannel = async (e) => {
      await channelOpen(e.channel);
      r(wrap(pc, e.channel));
    };
  });
  await pc.setRemoteDescription({ type: 'offer', sdp: o.sdp });
  await pc.setLocalDescription(await pc.createAnswer());
  await waitIce(pc);
  return { code: await encodeSignal('a', pc.localDescription!.sdp), connection: conn };
}
