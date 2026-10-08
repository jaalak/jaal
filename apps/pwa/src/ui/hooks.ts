import { useEffect, useState } from 'preact/hooks';
import type { JaalNode } from '../core/node';

/** Re-runs [load] whenever the node reports a change. */
export function useLive<T>(node: JaalNode, load: () => Promise<T>, deps: unknown[] = []): T | undefined {
  const [v, setV] = useState<T>();
  useEffect(() => {
    let alive = true;
    const run = () => load().then((x) => alive && setV(x));
    run();
    const off = node.onChange(run);
    return () => {
      alive = false;
      off();
    };
  }, deps);
  return v;
}

export function useHash(): string {
  const [h, setH] = useState(location.hash.slice(1) || '/home');
  useEffect(() => {
    const f = () => setH(location.hash.slice(1) || '/home');
    addEventListener('hashchange', f);
    return () => removeEventListener('hashchange', f);
  }, []);
  return h;
}

export const go = (path: string) => (location.hash = path);

export function ago(ms: number): string {
  const d = Date.now() - ms;
  if (d > 86400_000) return `${Math.floor(d / 86400_000)}d ago`;
  if (d > 3600_000) return `${Math.floor(d / 3600_000)}h ago`;
  if (d > 60_000) return `${Math.floor(d / 60_000)}m ago`;
  return 'just now';
}

let toastTimer: number | undefined;
export function toast(msg: string) {
  let el = document.querySelector<HTMLDivElement>('.toast');
  if (!el) {
    el = document.createElement('div');
    el.className = 'toast';
    document.body.appendChild(el);
  }
  el.textContent = msg;
  el.style.display = 'block';
  clearTimeout(toastTimer);
  toastTimer = window.setTimeout(() => (el!.style.display = 'none'), 3000);
}
