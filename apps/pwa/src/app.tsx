import { useEffect, useState } from 'preact/hooks';
import { JaalNode, createIdentity, loadIdentity, openJaalDB } from './core/node';
import type { JaalDB } from './core/db';
import { go, toast, useHash } from './ui/hooks';
import { Chat, Compose, Home, Letters, Meet, PostDetail, Profile, Settings } from './ui/screens';
import { GetApp } from './ui/getapp';

export function App() {
  const [db, setDb] = useState<JaalDB>();
  const [node, setNode] = useState<JaalNode | null>();
  const route = useHash();
  useEffect(() => {
    openJaalDB().then(async (d) => {
      setDb(d);
      const me = await loadIdentity(d);
      setNode(me ? await JaalNode.open(d, me) : null);
      navigator.storage?.persist?.();
    });
  }, []);
  // The download page needs no node: show it before (or without) one.
  if (route === '/app' && !node) return <GetApp />;
  if (node === undefined || !db) return <div class="page"><span class="wordmark hl">jaal</span><p class="hand">waking up your node…</p></div>;
  if (node === null) return <Onboarding db={db} onReady={setNode} />;
  return <Shell node={node} />;
}

function Shell({ node }: { node: JaalNode }) {
  const route = useHash();
  const [, seg, arg] = route.split('/');
  const screen = (() => {
    switch (seg) {
      case 'new': return <Compose node={node} />;
      case 'post': return <PostDetail node={node} id={arg} />;
      case 'u': return <Profile node={node} root={arg} />;
      case 'me': return <Settings node={node} />;
      case 'letters': return <Letters node={node} />;
      case 'chat': return <Chat node={node} peer={arg} />;
      case 'meet': return <Meet node={node} />;
      case 'app': return <GetApp />;
      default: return <Home node={node} />;
    }
  })();
  const tab = (path: string, icon: string, label: string) => (
    <a href={`#${path}`} class={route.startsWith(path) ? 'on' : ''}><span class="ic">{icon}</span>{label}</a>
  );
  return (
    <>
      {screen}
      <nav class="tabs">
        {tab('/home', '⌂', 'home')}
        {tab('/meet', '◎', 'meet')}
        <a href="#/new" class="plus">+</a>
        {tab('/letters', '✉', 'letters')}
        {tab('/me', '☺', 'you')}
      </nav>
    </>
  );
}

function Onboarding({ db, onReady }: { db: JaalDB; onReady: (n: JaalNode) => void }) {
  const [mode, setMode] = useState<'welcome' | 'create' | 'restore' | 'phrase'>('welcome');
  const [name, setName] = useState('');
  const [handle, setHandle] = useState('');
  const [phrase, setPhrase] = useState('');
  const [node, setNode] = useState<JaalNode>();
  const make = async (restore: boolean) => {
    try {
      const me = await createIdentity(db, restore ? phrase : undefined);
      const n = await JaalNode.open(db, me);
      await n.setProfile(name.trim(), handle.trim());
      setNode(n);
      if (restore) onReady(n);
      else setMode('phrase');
    } catch (e) {
      toast(String(e));
    }
  };
  if (mode === 'welcome')
    return (
      <div class="page stack" style={{ paddingTop: '20vh' }}>
        <span class="tape">v0.1 · offline · web</span>
        <h1 style={{ fontSize: '88px' }} class="wordmark hl">jaal</h1>
        <h1>no wifi?<br />no problem.</h1>
        <div class="hand">a social network that runs on people, not towers ↓</div>
        <button class="btn block" onClick={() => setMode('create')}>⚡ make me a node</button>
        <button class="btn paper block" onClick={() => setMode('restore')}>i have a recovery phrase</button>
        <p class="mono xerox">tip: safari → share → add to home screen. then it works offline.</p>
        <a class="mono" href="#/app">on android? get the full app →</a>
      </div>
    );
  if (mode === 'phrase')
    return (
      <div class="page stack">
        <h2>write these down.<br />like, on paper.</h2>
        <div class="hand red">lose the phone + lose these = lose you.</div>
        <div class="words">{node!.me.root.recoveryPhrase.split(' ').map((w, i) => <div key={i} class="w"><i>{String(i + 1).padStart(2, '0')}</i>{w}</div>)}</div>
        <button class="btn block" onClick={() => { onReady(node!); go('/home'); }}>i wrote them down → enter jaal</button>
      </div>
    );
  return (
    <div class="page stack">
      <h2>{mode === 'create' ? 'new node' : 'restore'}</h2>
      <div class="hand">your keys are made on this phone. no server ever sees them.</div>
      {mode === 'restore' && <textarea rows={4} placeholder="24 words, spaces between" value={phrase} onInput={(e) => setPhrase((e.target as HTMLTextAreaElement).value)} />}
      <input placeholder="display name" value={name} onInput={(e) => setName((e.target as HTMLInputElement).value)} />
      <input placeholder="handle (a-z 0-9 _ .)" value={handle} onInput={(e) => setHandle((e.target as HTMLInputElement).value.toLowerCase())} />
      <button class="btn block" disabled={!name.trim() || handle.trim().length < 2} onClick={() => make(mode === 'restore')}>{mode === 'create' ? 'forge my keys' : 'restore me'}</button>
      <button class="btn paper small" onClick={() => setMode('welcome')}>back</button>
    </div>
  );
}
