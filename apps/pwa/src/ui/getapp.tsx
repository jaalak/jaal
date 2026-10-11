import { toast } from './hooks';
import { QR } from './widgets';

/** Latest signed release on GitHub; the asset name stays fixed across versions. */
export const APK_URL = 'https://github.com/jaalak/jaal/releases/latest/download/jaal.apk';

type Device = 'ios' | 'android' | 'desktop';

function device(): Device {
  const ua = navigator.userAgent;
  if (/iPad|iPhone|iPod/.test(ua) || (/Macintosh/.test(ua) && navigator.maxTouchPoints > 1)) return 'ios';
  if (/Android/.test(ua)) return 'android';
  return 'desktop';
}

const FEATURES: [string, string, string, preact.JSX.Element][] = [
  ['carry pouch', 'carry sealed letters for strangers. earn courier clout when they land.', '#ffd4ea',
    <svg viewBox="0 0 28 28"><rect x="3" y="6" width="22" height="16" fill="#fff" /><path d="M3 6 L14 15 L25 6" /><rect x="18" y="8" width="5" height="5" fill="#d7263d" stroke="none" /></svg>],
  ['nearby radar wall', "see who's physically around you, pinned like polaroids.", '#e7ff85',
    <svg viewBox="0 0 28 28"><rect x="4" y="3" width="20" height="22" fill="#fff" /><rect x="6" y="5" width="16" height="13" fill="#dddad1" stroke="none" /><circle cx="19" cy="8" r="2.5" fill="#c6ff00" stroke-width="1.5" /></svg>],
  ['become a moderator', 'get vouched in by 3 mods, irl. keep your mesh clean.', '#fff480',
    <svg viewBox="0 0 28 28" stroke="none"><rect x="4" y="4" width="10" height="10" fill="#0a0a0a" /><rect x="6" y="6" width="6" height="6" fill="#fff" /><rect x="16" y="4" width="8" height="8" fill="#0a0a0a" /><circle cx="9" cy="20" r="3" fill="#d7263d" /><circle cx="17" cy="20" r="3" fill="#d7263d" /><circle cx="23" cy="16" r="3" fill="#d7263d" /></svg>],
  ['network lab', 'spin up a fake crowd and watch posts hop phone to phone.', '#d0e8ff',
    <svg viewBox="0 0 28 28"><path d="M10 4 L18 4 M12 4 L12 10 L6 22 C5 24 6 25 8 25 L20 25 C22 25 23 24 22 22 L16 10 L16 4" /><circle cx="11" cy="18" r="2" fill="#3d5afe" stroke="none" /><circle cx="17" cy="17" r="2" fill="#3d5afe" stroke="none" /><line x1="11" y1="18" x2="17" y2="17" stroke="#3d5afe" stroke-width="1.5" /></svg>],
];

const SOON = ['bluetooth + wi-fi direct mesh. no hotspot needed', "syncs in your pocket, even when the app's closed", 'your android becomes a hub iphones can join'];

export function GetApp() {
  const d = device();
  const share = async () => {
    const url = location.href.split('#')[0] + '#/app';
    try {
      if (navigator.share) await navigator.share({ title: 'jaal for android', url });
      else {
        await navigator.clipboard.writeText(url);
        toast('link copied. send it to an android friend.');
      }
    } catch {
      /* share sheet dismissed */
    }
  };
  const iphone = (
    <div class="ga-iphone">
      <h3 class="ga-display">on an iphone? stay here.</h3>
      <p>ios doesn't allow mesh apps outside the app store. the web app works offline: safari → share → add to home screen.</p>
      <a class="btn small paper" href="#/home">← back to the feed</a>
    </div>
  );
  return (
    <>
      <header class="ga-top">
        <span class="mono"><span class="ga-dot" /> jaal // get the app</span>
        <span class="ga-badge">web · {d === 'ios' ? 'iphone' : d}</span>
      </header>
      <div class="page ga">
        <span class="tape ga-tape">android only · for now</span>
        <div>
          <h1 class="ga-display ga-head">jaal hits<br />different on<br /><span class="hl">android.</span></h1>
          <div class="hand">the web app is the lite version. this is the full net ↓</div>
        </div>
        {d === 'ios' && iphone}

        <div class="ga-phone">
          <div class="ga-notch" />
          <div class="ga-screen">
            <div class="ga-screen-bar"><span>● nearby: 8 phones</span><span>syncing…</span></div>
            <div class="ga-pol">
              <div class="ga-halftone"><span class="ink-label">@maya · 1 hop</span></div>
              <div class="mono">night market zine swap // line 2</div>
            </div>
            <div class="ga-postmark">3 hops · 2d</div>
          </div>
          <span class="ga-st real">real</span>
          <span class="ga-st w">w</span>
          <div class="ga-stamp"><div><b>apk</b><span>v0.1</span><i>free</i></div></div>
        </div>

        <div class="ga-cta">
          {d === 'android' && <a class="btn block ga-dl" href={APK_URL}>⬇ download for android</a>}
          {d === 'ios' && <button class="btn paper block ga-dl" onClick={share}>send the link to an android friend</button>}
          {d === 'desktop' && (
            <div class="stack" style={{ textAlign: 'center' }}>
              <QR text={APK_URL} size={200} />
              <div class="hand">scan with your android</div>
              <a class="mono" href={APK_URL}>or grab the apk directly</a>
            </div>
          )}
          <div class="mono xerox">{d === 'ios' ? 'android phones only' : 'jaal.apk · v0.1 · android 7+ · not on play store yet'}</div>
        </div>

        <span class="ink-label ga-label">only on android</span>
        <div class="ga-cards">
          {FEATURES.map(([title, body, bg, icon], i) => (
            <div key={title} class="ga-card" style={{ transform: `rotate(${[-1.2, 1, -0.8, 1.4][i]}deg)` }}>
              {i % 2 === 0 && <span class="ga-cardtape" />}
              <div class="ga-icon" style={{ background: bg }}>{icon}</div>
              <div>
                <div class="ga-display ga-card-title">{title}</div>
                <p>{body}</p>
              </div>
            </div>
          ))}
        </div>

        <div class="ga-soon">
          <span class="ga-st soon">soon</span>
          <div class="mono"><b>☆ under active development</b></div>
          <ul>{SOON.map((s) => <li key={s} class="mono">{s}</li>)}</ul>
        </div>

        {d !== 'ios' && (
          <div class="ga-steps">
            <h3 class="ga-display">install in 3 steps</h3>
            {['tap download', 'allow "install unknown apps" for your browser', 'open jaal → type your 24 words → same you'].map((s, i) => (
              <div key={s} class="ga-step"><span>0{i + 1}</span><b class="mono">{s}</b></div>
            ))}
            <div class="hand" style={{ fontSize: '19px' }}>→ your posts + follows come with you ★</div>
          </div>
        )}

        {d !== 'ios' && iphone}
        <p class="mono xerox" style={{ textAlign: 'center', fontSize: '10px' }}>jaal v0.1 · p2p gossip protocol · zero cloud servers</p>
      </div>
    </>
  );
}
