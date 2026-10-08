import { useEffect, useRef, useState } from 'preact/hooks';
import QRCode from 'qrcode';
import jsQR from 'jsqr';
import type { JaalNode } from '../core/node';
import type { Manifest } from '../core/media';
import type { PostRow } from '../core/db';
import { fingerprintOf } from '../core/identity';
import { ago, go, toast, useLive } from './hooks';

const STICKER: Record<string, [string, string]> = {
  heart: ['#ff3ea5', '#f4f1e8'], fire: ['#ff4a1c', '#f4f1e8'], lol: ['#ffd21f', '#0a0a0a'],
  real: ['#c6ff00', '#0a0a0a'], slay: ['#ff1f4b', '#f4f1e8'], mid: ['#8a857a', '#f4f1e8'],
  cry: ['#2f7bff', '#f4f1e8'], peak: ['#c6ff00', '#0a0a0a'], w: ['#3d5afe', '#f4f1e8'], skull: ['#ffffff', '#0a0a0a'],
};
export const STICKERS = Object.keys(STICKER);

export function Sticker({ id, style }: { id: string; style?: Record<string, string> }) {
  const [bg, fg] = STICKER[id] ?? ['#f9e27a', '#0a0a0a'];
  return (
    <div class="sticker" style={style}>
      <span style={{ background: bg, color: fg }}>{id === 'heart' ? '♥' : id === 'skull' ? '☠' : id}</span>
    </div>
  );
}

export function Postmark({ hops, transitMs }: { hops: number; transitMs?: number }) {
  const t = transitMs == null ? 'jaal' : transitMs > 86400_000 ? `${Math.floor(transitMs / 86400_000)}d` : transitMs > 3600_000 ? `${Math.floor(transitMs / 3600_000)}h` : transitMs > 60_000 ? `${Math.floor(transitMs / 60_000)}m` : 'live';
  return (
    <div class="postmark">
      <div>
        <b>{hops === 0 ? 'local' : `${hops} hop${hops === 1 ? '' : 's'}`}</b>
        {t}
      </div>
    </div>
  );
}

const PALETTE = ['#0a0a0a', '#3d5afe', '#ff3ea5', '#c6ff00'];

export function Polaroid({ node, root, nearby }: { node: JaalNode; root: string; nearby?: boolean }) {
  const p = useLive(node, () => node.profile(root), [root]);
  const avatar = p?.avatar ? (JSON.parse(p.avatar) as Manifest) : null;
  const url = usePhotoUrl(node, avatar);
  const bg = PALETTE[root.charCodeAt(3) % PALETTE.length];
  return (
    <a class="polaroid" href={`#/u/${root}`}>
      <div class="ph" style={{ background: bg, color: bg === '#c6ff00' ? '#0a0a0a' : bg === '#0a0a0a' ? '#c6ff00' : '#f4f1e8' }}>
        {url ? <img src={url} alt="" /> : (p?.name ?? '?').slice(0, 1).toLowerCase()}
      </div>
      {nearby && <div class="dot" />}
    </a>
  );
}

export function usePhotoUrl(node: JaalNode, m: Manifest | null | undefined): string | null {
  const bytes = useLive(node, async () => (m ? node.media.read(m.hash) : null), [m?.hash]);
  const [url, setUrl] = useState<string | null>(null);
  useEffect(() => {
    if (!bytes) return;
    const u = URL.createObjectURL(new Blob([bytes as BlobPart], { type: m?.mime ?? 'image/jpeg' }));
    setUrl(u);
    return () => URL.revokeObjectURL(u);
  }, [bytes]);
  return url;
}

export function Photo({ node, m, post }: { node: JaalNode; m: Manifest; post: PostRow }) {
  const url = usePhotoUrl(node, m);
  const prog = useLive(node, () => node.media.blob(m.hash), [m.hash]);
  const reactions = useLive(node, () => node.reactions(post.id), [post.id]) ?? [];
  return (
    <div class="photo">
      {url ? (
        <img src={url} alt="" />
      ) : (
        <div class="wait">
          <span class="ink-label" style={{ color: 'var(--acid)' }}>
            chunks {prog?.chunksHeld ?? 0}/{m.chunks.length} · {prog?.chunksHeld ? 'resuming' : 'waiting for a carrier'}
          </span>
        </div>
      )}
      {reactions.slice(0, 12).map((r) => (
        <Sticker key={r.rootId} id={r.sticker!} style={{ left: `${r.x / 10 - 6}%`, top: `${r.y / 10 - 3}%`, transform: `rotate(${r.rot}deg)` }} />
      ))}
      <Postmark hops={post.hops} transitMs={post.hops ? post.firstSeenAt - post.ts : undefined} />
    </div>
  );
}

export function PostCard({ node, post, i }: { node: JaalNode; post: PostRow; i: number }) {
  const author = useLive(node, () => node.profile(post.rootId), [post.rootId]);
  const comments = useLive(node, () => node.comments(post.id), [post.id]) ?? [];
  const reactions = useLive(node, () => node.reactions(post.id), [post.id]) ?? [];
  const warn = useLive(node, () => node.lookalike(post.rootId), [post.rootId]);
  const media = JSON.parse(post.media) as Manifest[];
  const [picking, setPicking] = useState(false);
  return (
    <div class={`box ${i % 2 ? 'tilt-r' : 'tilt-l'}`} style={{ padding: '12px', background: media.length ? undefined : 'var(--sunken)' }}>
      {warn && <div class="hazard" style={{ marginBottom: '10px' }}><div>⚠ {warn}</div></div>}
      <div class="row" style={{ marginBottom: '10px' }}>
        <Polaroid node={node} root={post.rootId} nearby={node.engine.connectedRoots.includes(post.rootId)} />
        <div class="grow">
          <div><b>{author?.name.toLowerCase() ?? 'someone'}</b> <span class="mono xerox">@{author?.handle ?? 'anon'}·{fingerprintOf(post.rootId)}</span></div>
          <div class="mono xerox">{post.hops ? `relayed ${ago(post.ts)} · ${post.hops} hop${post.hops === 1 ? '' : 's'}` : `posted ${ago(post.ts)}`}</div>
        </div>
      </div>
      {media.length ? (
        <Photo node={node} m={media[0]} post={post} />
      ) : (
        <div style={{ position: 'relative', background: '#fff', color: 'var(--ink)', border: '2px solid var(--ink)', padding: '16px 72px 16px 16px', fontSize: '20px' }}>
          "{post.body}"
          <Postmark hops={post.hops} transitMs={post.hops ? post.firstSeenAt - post.ts : undefined} />
        </div>
      )}
      {media.length > 0 && post.body && <p style={{ marginTop: '10px' }}>{post.body}</p>}
      {post.hops > 1 && <div class="hand" style={{ fontSize: '19px' }}>↗ passed through {post.hops - 1} pocket{post.hops === 2 ? '' : 's'} to reach you</div>}
      <div class="row wrap" style={{ marginTop: '10px' }}>
        <button class="btn small paper" onClick={() => setPicking(!picking)}>☺ {reactions.length ? `stick (${reactions.length})` : 'slap sticker'}</button>
        <button class="btn small paper" onClick={() => go(`/post/${post.id}`)}>💬 {comments.length}</button>
        <span class="grow" />
        <span class="mono xerox">{post.hops ? 'via the mesh' : 'from your pocket'}</span>
      </div>
      {picking && (
        <div class="row wrap" style={{ marginTop: '10px' }}>
          {STICKERS.map((s) => (
            <button
              key={s}
              class="btn small"
              style={{ background: STICKER[s][0], color: STICKER[s][1] }}
              onClick={async () => {
                setPicking(false);
                await node.react(post.id, s);
                toast('stuck. it\'ll spread as phones meet.');
              }}
            >
              {s}
            </button>
          ))}
        </div>
      )}
    </div>
  );
}

export function QR({ text, size = 240 }: { text: string; size?: number }) {
  const [src, setSrc] = useState('');
  useEffect(() => {
    QRCode.toDataURL(text, { margin: 1, width: size * 2, errorCorrectionLevel: text.length > 600 ? 'L' : 'M' }).then(setSrc);
  }, [text]);
  return <div class="qr"><img src={src} alt="qr code" style={{ width: `${size}px`, height: `${size}px` }} /></div>;
}

/** Camera QR scanner (jsQR — works in iOS Safari, which lacks BarcodeDetector). */
export function Scanner({ prefix, onCode }: { prefix: string; onCode: (code: string) => void }) {
  const video = useRef<HTMLVideoElement>(null);
  const [err, setErr] = useState('');
  const [paste, setPaste] = useState('');
  useEffect(() => {
    let stream: MediaStream | undefined;
    let raf = 0;
    let done = false;
    const canvas = document.createElement('canvas');
    const tick = () => {
      const v = video.current;
      if (!v || done) return;
      if (v.readyState >= 2) {
        canvas.width = v.videoWidth;
        canvas.height = v.videoHeight;
        const ctx = canvas.getContext('2d', { willReadFrequently: true })!;
        ctx.drawImage(v, 0, 0);
        const img = ctx.getImageData(0, 0, canvas.width, canvas.height);
        const r = jsQR(img.data, img.width, img.height);
        if (r?.data.startsWith(prefix)) {
          done = true;
          onCode(r.data);
          return;
        }
      }
      raf = requestAnimationFrame(tick);
    };
    navigator.mediaDevices
      ?.getUserMedia({ video: { facingMode: 'environment' } })
      .then((s) => {
        stream = s;
        if (video.current) {
          video.current.srcObject = s;
          video.current.play();
          tick();
        }
      })
      .catch(() => setErr('camera unavailable — paste the code instead'));
    return () => {
      done = true;
      cancelAnimationFrame(raf);
      stream?.getTracks().forEach((t) => t.stop());
    };
  }, []);
  return (
    <div class="stack">
      <video class="scan" ref={video} playsInline muted />
      {err && <div class="mono">{err}</div>}
      <div class="row">
        <input class="grow" placeholder={`or paste a ${prefix} code`} value={paste} onInput={(e) => setPaste((e.target as HTMLInputElement).value)} />
        <button class="btn small" onClick={() => paste.trim() && onCode(paste.trim())}>use</button>
      </div>
    </div>
  );
}
