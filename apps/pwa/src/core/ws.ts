// WebSocket PeerConnection (browser + Node 22+ global WebSocket). Used for
// LAN peers and interop tests; one binary message per frame.
import { PeerConnection } from './sync';

export function connectWebSocket(url: string): Promise<PeerConnection> {
  return new Promise((resolve, reject) => {
    const ws = new WebSocket(url);
    ws.binaryType = 'arraybuffer';
    let frameCb: (f: Uint8Array) => void = () => {};
    let closeCb: () => void = () => {};
    const pending: Uint8Array[] = [];
    const conn: PeerConnection = {
      label: url,
      get open() {
        return ws.readyState === WebSocket.OPEN;
      },
      send: (f) => ws.send(f as Uint8Array<ArrayBuffer>),
      onFrame(cb) {
        frameCb = cb;
        pending.splice(0).forEach(cb);
      },
      onClose(cb) {
        closeCb = cb;
      },
      close: () => ws.close(),
    };
    ws.onmessage = (m) => {
      const f = new Uint8Array(m.data as ArrayBuffer);
      if (frameCb.length) frameCb(f);
      else pending.push(f);
    };
    ws.onclose = () => closeCb();
    ws.onerror = () => reject(new Error(`websocket ${url} failed`));
    ws.onopen = () => resolve(conn);
  });
}
