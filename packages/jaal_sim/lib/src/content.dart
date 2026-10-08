import 'dart:math';

/// Throwaway personas for virtual peers.
class Persona {
  const Persona(this.name, this.handle, this.bio);
  final String name, handle, bio;
}

abstract final class Personas {
  static const all = [
    Persona('Maya', 'maya.offgrid', 'film cams + mountain wifi refusal'),
    Persona('Arjun', 'arjun_rn', 'chai > coffee. fight me.'),
    Persona('Zoe', 'zoe.zine', 'i make zines nobody asked for'),
    Persona('Kabir', 'kabirmesh', 'node #7 of the hostel mesh'),
    Persona('Noor', 'noor.exe', 'professional overthinker'),
    Persona('Leo', 'leo_lowbatt', 'always at 3%'),
    Persona('Isha', 'isha.sticks', 'sticker collector, not sorry'),
    Persona('Dev', 'dev.null', 'touching grass irl'),
  ];

  static Persona pick(int i) {
    final p = all[i % all.length];
    if (i < all.length) return p;
    final n = i ~/ all.length;
    return Persona('${p.name}$n', '${p.handle}$n', p.bio);
  }
}

abstract final class Captions {
  static const _posts = [
    'no wifi? no problem.',
    'posted from a bus with zero bars',
    'this post took 3 hops to reach you. respect it.',
    'festival day 2: the mesh is meshing',
    'sunset from the roof, delivered by a stranger\'s phone',
    'lowkey the best signal is people',
    'carried this thought across town. you\'re welcome.',
    'airplane mode era',
    'if you can read this you were near someone who was near me',
    'trek update: still alive, still offline',
    'zine drop at the corner chai stall, 4pm',
    'my phone is a postman now',
  ];

  static const _dms = [
    'u up?',
    'meet at the gate in 10',
    'did this reach u lol',
    'saving u a spot',
    'bring the stickers',
    'ok this offline thing actually slaps',
  ];

  static String random(Random r) => _posts[r.nextInt(_posts.length)];
  static String dm(Random r) => _dms[r.nextInt(_dms.length)];
}
