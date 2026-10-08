import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jaal_core/jaal_core.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/router.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../shared/people.dart';
import '../shared/providers.dart';
import '../shell/app_shell.dart';

/// Become a moderator (design 17): collect 3 vouch stamps by showing your
/// consent QR to moderators in person. Turns blue when you're in.
class BecomeModeratorScreen extends ConsumerStatefulWidget {
  const BecomeModeratorScreen({super.key});

  @override
  ConsumerState<BecomeModeratorScreen> createState() => _State();
}

class _State extends ConsumerState<BecomeModeratorScreen> {
  MeetCode? _code;
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    _refresh();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      final c = _code;
      if (c != null && _remaining(c) <= Duration.zero) _refresh();
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    final c = await ref.read(nodeProvider).meetCode(purpose: MeetPurpose.moderator);
    if (mounted) setState(() => _code = c);
  }

  Duration _remaining(MeetCode c) => Duration(
      milliseconds: c.ts + ref.read(nodeProvider).moderation.config.liveCodeMaxAge.inMilliseconds - DateTime.now().millisecondsSinceEpoch);

  @override
  Widget build(BuildContext context) {
    final node = ref.watch(nodeProvider);
    final mods = ref.watch(moderatorsProvider).value ?? const {};
    final isMod = mods.contains(node.rootId);
    final vouchers = node.moderation.vouchesFor(node.rootId);
    if (isMod) return _YoureIn(vouchers: vouchers);
    final c = _code;
    final left = c == null ? Duration.zero : _remaining(c);

    return Scaffold(
      appBar: const ZineAppBar(title: 'become a moderator'),
      body: Grain(
        child: ListView(padding: const EdgeInsets.all(JaalSpace.s4), children: [
          const Highlighted('get vouched in.', size: JaalSize.h1, color: JaalColors.blue),
          const SizedBox(height: JaalSpace.s3),
          const Text('moderators are invite-only. 3 moderators have to scan you, in person.'),
          const SizedBox(height: JaalSpace.s5),
          ZineBox(
            child: Column(children: [
              Text('vouch card', style: monoStyle(12, bold: true)),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                for (var i = 0; i < 3; i++)
                  i < vouchers.length
                      ? StampSlot(label: nameOf(ref, vouchers.elementAt(i)), size: 88)
                      : const StampSlot(size: 88),
              ]),
              const SizedBox(height: 10),
              Text('${vouchers.length}/3 vouches', style: monoStyle(12, color: JaalColors.xerox)),
            ]),
          ),
          const SizedBox(height: JaalSpace.s5),
          Center(
            child: ZineBox(
              color: Colors.white,
              tilt: -0.02,
              child: Column(children: [
                if (c != null)
                  QrImageView(data: c.encode(), size: 220, backgroundColor: Colors.white)
                else
                  const SizedBox(width: 220, height: 220),
                const SizedBox(height: 8),
                MonoChip('refreshes in ${left.inMinutes}:${(left.inSeconds % 60).toString().padLeft(2, '0')}'),
              ]),
            ),
          ),
          const SizedBox(height: JaalSpace.s3),
          const Center(
            child: HandNote('show this to a moderator. it says: i agree to moderate.', size: 19),
          ),
          const SizedBox(height: JaalSpace.s5),
          Text('only moderators who scan you in person can vouch. your vouches are public to moderators.',
              style: monoStyle(11, color: JaalColors.xerox)),
        ]),
      ),
    );
  }
}

class _YoureIn extends ConsumerWidget {
  const _YoureIn({required this.vouchers});
  final Set<String> vouchers;

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        backgroundColor: JaalColors.blue,
        appBar: const ZineAppBar(title: 'moderator'),
        body: Padding(
          padding: const EdgeInsets.all(JaalSpace.s5),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('you\'re a moderator now.', style: displayStyle(40, color: JaalColors.paper)),
            const SizedBox(height: JaalSpace.s5),
            Transform.rotate(
              angle: -0.12,
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: const BoxDecoration(
                  color: JaalColors.acid,
                  shape: BoxShape.circle,
                  border: Border.fromBorderSide(BorderSide(color: JaalColors.ink, width: 3)),
                ),
                child: Text('★ mod', style: displayStyle(28, color: JaalColors.ink)),
              ),
            ),
            const SizedBox(height: JaalSpace.s4),
            Text('with great power comes 2-vote bans.', style: handStyle(color: JaalColors.paper, size: 26)),
            const SizedBox(height: JaalSpace.s4),
            if (vouchers.isNotEmpty)
              Wrap(spacing: 12, children: [for (final v in vouchers) Polaroid(root: v, size: 50)]),
            const Spacer(),
            ZineButton(
              color: JaalColors.paper,
              label: 'open the moderation desk',
              expand: true,
              onPressed: () => context.pushReplacement(Routes.modDesk),
            ),
            const SizedBox(height: JaalSpace.s3),
            ZineButton(
              color: JaalColors.acid,
              icon: Icons.qr_code_scanner,
              label: 'vouch for someone (scan)',
              expand: true,
              onPressed: () => context.push('${Routes.meet}?mode=mod'),
            ),
          ]),
        ),
      );
}
