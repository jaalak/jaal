// Lookalike skeletons (mirrors jaal_core identity/lookalike.dart).
const CONFUSABLES: Record<string, string> = {
  '0': 'o', '1': 'l', i: 'l', '|': 'l', '3': 'e', '4': 'a', '@': 'a',
  '5': 's', $: 's', '7': 't', '8': 'b', '9': 'g', '6': 'g', '2': 'z',
};

export function skeleton(s: string): string {
  let t = s.toLowerCase().replace(/[\s._\-·]+/g, '');
  t = t.replace(/\d+$/, '');
  t = t.replace(/rn/g, 'm').replace(/vv/g, 'w').replace(/cl/g, 'd');
  return [...t].map((c) => CONFUSABLES[c] ?? c).join('');
}
