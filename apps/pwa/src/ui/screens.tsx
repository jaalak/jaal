import { useState } from 'preact/hooks';
import type { JaalNode } from '../core/node';
import { compressPhoto, type Manifest } from '../core/media';
import { encodeMeetCode, fingerprintOf, longFingerprintOf } from '../core/identity';
import { answerOffer, createOffer } from '../core/webrtc';
import { ago, go, toast, useLive } from './hooks';
import { PostCard, Photo, Polaroid, QR, Scanner } from './widgets';

const Top = ({ title }: { title?: string }) => (
  <div class="topbar">
    {title ? <h2>{title}</h2> : <span class="wordmark hl">jaal</span>}
  </div>
);

// ----------------------------------------------------------------- home

export function Home({ node }: { node: JaalNode }) {
  const [all, setAll] = useState(false);
  const posts = useLive(node, () => (all ? node.allPosts() : node.homeFeed()), [all]) ?? [];
  const peers = node.engine.connectedRoots;
  return (
    <div class="page stack">
      <Top />
      <a class="tape" href="#/app" style={{ alignSelf: 'flex-start', textDecoration: 'none' }}>⬇ the android app is out · see why →</a>
      <div class="box" style={{ background: '#ddd3b8', color: 'var(--ink)' }} onClick={() => go('/meet')}>
        <span class="tape">{peers.length ? `syncing… ${peers.length} nearby` : 'nobody linked · posts wait in your pocket'}</span>
        <div class="row wrap" style={{ marginTop: '12px', minHeight: '64px' }}>
          {peers.map((r) => <Polaroid key={r} node={node} root={r} nearby />)}
          {!peers.length && <span class="hand">tap to link a phone on the same wi-fi →</span>}
        </div>
      </div>
      <div class="row">
        <button class={`btn small ${all ? 'paper' : ''} grow`} onClick={() => setAll(false)}>mesh feed</button>
        <button class={`btn small ${all ? '' : 'paper'} grow`} onClick={() => setAll(true)}>everything here</button>
      </div>
      {posts.length === 0 && (
        <div class="box dashed stack" style={{ textAlign: 'center' }}>
          <h2>quiet out here.</h2>
          <p>follow people you meet — scan their qr in "meet".</p>
        </div>
      )}
      {posts.map((p, i) => <PostCard key={p.id} node={node} post={p} i={i} />)}
      <p class="mono xerox" style={{ textAlign: 'center' }}>end of local radio buffer · {posts.length} cached</p>
    </div>
  );
}

// -------------------------------------------------------------- compose

export function Compose({ node }: { node: JaalNode }) {
  const [text, setText] = useState('');
  const [photo, setPhoto] = useState<{ bytes: Uint8Array; w: number; h: number; mime: string } | null>(null);
  const [preview, setPreview] = useState('');
  const [xerox, setXerox] = useState(false);
  const [busy, setBusy] = useState(false);
  const pick = async (f: File | undefined, x = xerox) => {
    if (!f) return;
    setBusy(true);
    const c = await compressPhoto(f, { xerox: x });
    setPhoto(c);
    setPreview(URL.createObjectURL(new Blob([c.bytes as BlobPart], { type: c.mime })));
    setBusy(false);
  };
  const [file, setFile] = useState<File>();
  const drop = async () => {
    setBusy(true);
    try {
      if (photo) await node.postPhoto(text.trim(), photo);
      else await node.post(text.trim());
      go('/home');
    } catch (e) {
      toast(String(e));
      setBusy(false);
    }
  };
  return (
    <div class="page stack">
      <div class="row">
        <h2 class="grow">new drop</h2>
        <button class="btn" disabled={busy || (!text.trim() && !photo)} onClick={drop}>drop</button>
      </div>
      <label class="box" style={{ display: 'block', background: '#fff', textAlign: 'center' }}>
        {preview ? <img src={preview} style={{ width: '100%', border: '2px solid var(--ink)' }} /> : <div class="hand" style={{ padding: '60px 0' }}>{busy ? 'crunching…' : '+ add a frame'}</div>}
        <input type="file" accept="image/*" style={{ display: 'none' }} onChange={(e) => { const f = (e.target as HTMLInputElement).files?.[0]; setFile(f); pick(f); }} />
      </label>
      {photo && (
        <div class="box small stack">
          <div class="mono">photo → <span class="chip acid">{Math.round(photo.bytes.length / 1024)} kb</span> <span class="chip">{Math.ceil(photo.bytes.length / 65536)} chunks</span></div>
          <label class="row hand"><input type="checkbox" style={{ width: 'auto' }} checked={xerox} onChange={(e) => { const v = (e.target as HTMLInputElement).checked; setXerox(v); pick(file, v); }} /> xerox it (b&amp;w)</label>
        </div>
      )}
      <textarea rows={5} maxLength={2200} placeholder="say something offline…" value={text} onInput={(e) => setText((e.target as HTMLTextAreaElement).value)} />
      <div class="hand">"it leaves your phone when someone walks by. could be 1 minute, could be 2 days."</div>
    </div>
  );
}

// ---------------------------------------------------------- post detail

export function PostDetail({ node, id }: { node: JaalNode; id: string }) {
  const post = useLive(node, () => node.post_(id), [id]);
  const comments = useLive(node, () => node.comments(id), [id]) ?? [];
  const [text, setText] = useState('');
  if (!post) return <div class="page"><p class="hand">this post isn't on your phone (anymore).</p></div>;
  return (
    <div class="page stack">
      <Top title="post" />
      <PostCard node={node} post={post} i={0} />
      <h3>replies</h3>
      {comments.map((c) => (
        <div key={c.id} class="box small">
          <div class="mono xerox">{fingerprintOf(c.rootId)} · {ago(c.ts)}</div>
          <p>{c.body}</p>
        </div>
      ))}
      <div class="row">
        <input class="grow" placeholder="add a comment (it'll travel with the post)" value={text} onInput={(e) => setText((e.target as HTMLInputElement).value)} />
        <button class="btn small" onClick={async () => { if (text.trim()) { await node.comment(id, text.trim()); setText(''); } }}>↑</button>
      </div>
    </div>
  );
}

// -------------------------------------------------------------- profile

export function Profile({ node, root }: { node: JaalNode; root: string }) {
  const p = useLive(node, () => node.profile(root), [root]);
  const posts = useLive(node, async () => (await node.allPosts()).filter((x) => x.rootId === root), [root]) ?? [];
  const following = useLive(node, () => node.following(), []);
  const own = root === node.rootId;
  const iFollow = following?.has(root);
  return (
    <div class="page stack">
      <Top title={own ? 'you' : 'profile'} />
      <div class="row" style={{ alignItems: 'flex-start' }}>
        <Polaroid node={node} root={root} nearby={node.engine.connectedRoots.includes(root)} />
        <div class="grow stack" style={{ marginLeft: '8px' }}>
          <h1 class="hl">{p?.name.toLowerCase() ?? 'someone'}</h1>
          <span class="chip">@{p?.handle ?? 'anon'}·{fingerprintOf(root)}</span>
          {p?.bio && <p>{p.bio}</p>}
        </div>
      </div>
      <div class="mono xerox">fingerprint: {longFingerprintOf(root)}</div>
      {!own && (
        <div class="row">
          <button class={`btn grow ${iFollow ? 'paper' : ''}`} onClick={() => (iFollow ? node.unfollow(root) : node.follow(root))}>{iFollow ? '✓ following' : '+ follow'}</button>
          <button class="btn paper grow" disabled={!p} onClick={() => go(`/chat/${root}`)}>letter</button>
        </div>
      )}
      {own && <EditProfile node={node} />}
      <span class="ink-label" style={{ background: 'var(--acid)', color: 'var(--ink)', alignSelf: 'flex-start' }}>posts ({posts.length})</span>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: '6px' }}>
        {posts.map((x) => {
          const m = JSON.parse(x.media) as Manifest[];
          return (
            <a key={x.id} href={`#/post/${x.id}`} style={{ border: '2.5px solid var(--ink)', aspectRatio: '1', overflow: 'hidden', display: 'block', color: 'inherit', textDecoration: 'none', background: 'var(--sunken)' }}>
              {m.length ? <Photo node={node} m={m[0]} post={x} /> : <div class="mono" style={{ padding: '6px' }}>"{x.body.slice(0, 60)}"</div>}
            </a>
          );
        })}
      </div>
    </div>
  );
}

function EditProfile({ node }: { node: JaalNode }) {
  const [open, setOpen] = useState(false);
  const p = useLive(node, () => node.profile(node.rootId), []);
  const [name, setName] = useState('');
  const [handle, setHandle] = useState('');
  const [bio, setBio] = useState('');
  if (!open) return <button class="btn paper" onClick={() => { setName(p?.name ?? ''); setHandle(p?.handle ?? ''); setBio(p?.bio ?? ''); setOpen(true); }}>edit profile</button>;
  return (
    <div class="box stack">
      <input value={name} placeholder="display name" onInput={(e) => setName((e.target as HTMLInputElement).value)} />
      <input value={handle} placeholder="handle" onInput={(e) => setHandle((e.target as HTMLInputElement).value.toLowerCase())} />
      <textarea value={bio} placeholder="bio" maxLength={300} onInput={(e) => setBio((e.target as HTMLTextAreaElement).value)} />
      <button class="btn" onClick={async () => { try { await node.setProfile(name.trim(), handle.trim(), bio.trim()); setOpen(false); } catch (e) { toast(String(e)); } }}>save</button>
    </div>
  );
}

// ----------------------------------------------------------------- meet

export function Meet({ node }: { node: JaalNode }) {
  const [mode, setMode] = useState<'code' | 'scan' | 'link'>('code');
  const code = useLive(node, async () => encodeMeetCode(await node.meetCode()), []);
  return (
    <div class="page stack">
      <Top title="meet" />
      <div class="row">
        {(['code', 'scan', 'link'] as const).map((m) => (
          <button key={m} class={`btn small grow ${mode === m ? '' : 'paper'}`} onClick={() => setMode(m)}>
            {m === 'code' ? 'my code' : m === 'scan' ? 'scan' : 'link a phone'}
          </button>
        ))}
      </div>
      {mode === 'code' && code && (
        <div class="stack" style={{ textAlign: 'center' }}>
          <QR text={code} />
          <div class="mono">fingerprint: <b>{longFingerprintOf(node.rootId)}</b></div>
          <div class="hand">read it out loud. they should see the same.</div>
        </div>
      )}
      {mode === 'scan' && (
        <Scanner
          prefix="jaal:1:"
          onCode={async (c) => {
            try {
              const m = await node.verifyInPerson(c);
              toast(`met @${m.handle}·${fingerprintOf(m.root)} ✓ following`);
              go(`/u/${m.root}`);
            } catch (e) {
              toast(String(e));
            }
          }}
        />
      )}
      {mode === 'link' && <LinkPhone node={node} />}
    </div>
  );
}

function LinkPhone({ node }: { node: JaalNode }) {
  const [step, setStep] = useState<'start' | 'showOffer' | 'scanAnswer' | 'scanOffer' | 'showAnswer' | 'linked'>('start');
  const [code, setCode] = useState('');
  const [offer, setOffer] = useState<Awaited<ReturnType<typeof createOffer>>>();
  const fail = (e: unknown) => toast(String(e));
  if (step === 'start')
    return (
      <div class="stack">
        <p>same wi-fi, or join the android's hotspot. no internet needed.</p>
        <button class="btn block" onClick={async () => { try { const o = await createOffer(); setOffer(o); setCode(o.code); setStep('showOffer'); } catch (e) { fail(e); } }}>show my code first</button>
        <button class="btn paper block" onClick={() => setStep('scanOffer')}>scan their code first</button>
      </div>
    );
  if (step === 'showOffer' || step === 'showAnswer')
    return (
      <div class="stack" style={{ textAlign: 'center' }}>
        <h3>{step === 'showOffer' ? '1. let them scan this' : 'now let them scan this'}</h3>
        <QR text={code} size={280} />
        {step === 'showOffer' ? <button class="btn block" onClick={() => setStep('scanAnswer')}>they show a reply → scan it</button> : <div class="hand">waiting for them to connect…</div>}
      </div>
    );
  if (step === 'scanAnswer')
    return <Scanner prefix="jaal:rtc:" onCode={async (c) => { try { node.connect(await offer!.accept(c)); setStep('linked'); } catch (e) { fail(e); } }} />;
  if (step === 'scanOffer')
    return (
      <Scanner
        prefix="jaal:rtc:"
        onCode={async (c) => {
          try {
            const a = await answerOffer(c);
            setCode(a.code);
            setStep('showAnswer');
            node.connect(await a.connection);
            setStep('linked');
          } catch (e) {
            fail(e);
          }
        }}
      />
    );
  return (
    <div class="stack">
      <h2 class="hl">linked ✓</h2>
      <p>swapping posts, photos and sealed letters directly. keep both apps open until it settles.</p>
    </div>
  );
}

// -------------------------------------------------------------- letters

export function Letters({ node }: { node: JaalNode }) {
  const inbox = useLive(node, () => node.inbox(), []) ?? [];
  const profiles = useLive(node, () => node.profiles(), []) ?? [];
  const [pick, setPick] = useState(false);
  return (
    <div class="page stack">
      <span class="ink-label">secure store-and-forward · e2ee</span>
      <div class="row">
        <h1 class="hl pink grow">letters</h1>
        <button class="btn small paper" onClick={() => setPick(!pick)}>✉ new</button>
      </div>
      <div class="hand">carried in pockets · zero cellular data</div>
      {pick && (
        <div class="box small stack">
          {profiles.filter((p) => p.rootId !== node.rootId).map((p) => (
            <a key={p.rootId} href={`#/chat/${p.rootId}`} class="mono">@{p.handle}·{fingerprintOf(p.rootId)}</a>
          ))}
        </div>
      )}
      {inbox.length === 0 && <div class="box dashed" style={{ textAlign: 'center' }}><h2>no letters.</h2><p>send one; it'll find a way.</p></div>}
      {inbox.map((m, i) => (
        <a key={m.id} href={`#/chat/${m.peerRoot}`} class={`box ${i % 2 ? 'tilt-r' : 'tilt-l'}`} style={{ display: 'block', color: 'inherit', textDecoration: 'none', background: 'var(--sunken)' }}>
          <div class="row">
            <Polaroid node={node} root={m.peerRoot} />
            <div class="grow">
              <div class="mono xerox">{fingerprintOf(m.peerRoot)} · {ago(m.sentAt)}</div>
              <div>{m.outgoing ? 'you: ' : ''}"{m.body.slice(0, 40)}"</div>
            </div>
            <span class={`chip ${!m.outgoing ? 'pink' : m.delivered ? 'red' : ''}`}>{!m.outgoing ? 'new' : m.delivered ? 'delivered ✓' : 'in transit'}</span>
          </div>
        </a>
      ))}
    </div>
  );
}

export function Chat({ node, peer }: { node: JaalNode; peer: string }) {
  const msgs = useLive(node, () => node.conversation(peer), [peer]) ?? [];
  const p = useLive(node, () => node.profile(peer), [peer]);
  const [text, setText] = useState('');
  return (
    <div class="page stack">
      <Top title={`@${p?.handle ?? '…'}`} />
      <span class="tape">🔒 end-to-end sealed. carriers see an envelope, not you.</span>
      {msgs.map((m) => (
        <div key={m.id} class="box small" style={{ background: m.outgoing ? 'var(--acid)' : 'var(--paper)', color: 'var(--ink)', marginLeft: m.outgoing ? '20%' : 0, marginRight: m.outgoing ? 0 : '20%' }}>
          <p>{m.body}</p>
          <div class="mono xerox">{new Date(m.sentAt).toTimeString().slice(0, 5)} {m.outgoing && (m.delivered ? '· delivered ✓✓' : '· sealed, waiting for a passerby')}</div>
        </div>
      ))}
      <div class="row">
        <input class="grow" placeholder="write a letter…" value={text} onInput={(e) => setText((e.target as HTMLInputElement).value)} />
        <button class="btn pink" onClick={async () => { if (!text.trim()) return; try { await node.sendDm(peer, text.trim()); setText(''); } catch (e) { toast(String(e)); } }}>seal</button>
      </div>
    </div>
  );
}

// ------------------------------------------------------------- settings

export function Settings({ node }: { node: JaalNode }) {
  const [show, setShow] = useState(false);
  return (
    <div class="page stack">
      <Top title="settings" />
      <Profile node={node} root={node.rootId} />
      <div class="box stack">
        <h3 class="hl">recovery phrase</h3>
        {show ? (
          <div class="words">{node.me.root.recoveryPhrase.split(' ').map((w, i) => <div key={i} class="w"><i>{String(i + 1).padStart(2, '0')}</i>{w}</div>)}</div>
        ) : (
          <button class="btn red small" onClick={() => setShow(true)}>show my 24 words (nobody watching?)</button>
        )}
        <p class="mono xerox">same words in the android app → same you.</p>
      </div>
      <div class="box stack">
        <h3 class="hl">about</h3>
        <p class="mono">jaal web · protocol v1 · works offline once installed (safari → share → add to home screen).</p>
        <a class="btn small" href="#/app" style={{ textDecoration: 'none' }}>⬇ get the android app</a>
      </div>
    </div>
  );
}
