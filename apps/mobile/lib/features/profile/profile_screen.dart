import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jaal_core/jaal_core.dart';

import '../../app/router.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';
import '../feed/post_card.dart';
import '../moderation/moderation_desk_screen.dart';
import '../safety/safety_widgets.dart';
import '../shared/media.dart';
import '../shared/people.dart';
import '../shared/providers.dart';
import '../shell/app_shell.dart';

/// Profile as a scrapbook page (design 08). [root] null = your own.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, required this.root});
  final String? root;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final node = ref.watch(nodeProvider);
    final r = root ?? node.rootId;
    final own = r == node.rootId;
    final p = ref.watch(profileProvider(r));
    final posts = ref.watch(postsByProvider(r)).value ?? const [];
    final followers = ref.watch(followersCountProvider(r)).value ?? 0;
    final following = ref.watch(followingCountProvider(r)).value ?? 0;
    final iFollow = ref.watch(followingProvider).value?.contains(r) ?? false;
    final verified = ref.watch(verifiedProvider).value?.contains(r) ?? false;
    final nearby = ref.watch(nearbyRootsProvider).contains(r);
    final seen = (ref.watch(peersSeenProvider).value ?? const []).where((s) => s.rootId == r).firstOrNull;
    final status = ref.watch(modStatusProvider).value?[r];
    final mods = ref.watch(moderatorsProvider).value ?? const {};
    final warn = ref.watch(lookalikesProvider(r)).value ?? const [];
    final pouch = ref.watch(carryPouchProvider).value?.length ?? 0;
    final clout = ref.watch(courierCloutProvider).value ?? 0;
    final ink = inkOf(context);

    if (status?.state == ModState.banned && !own) {
      return Scaffold(appBar: const ZineAppBar(title: 'profile'), body: RemovedFlyer(root: r, reason: status!.reason));
    }

    return Scaffold(
      appBar: own
          ? const JaalTopBar()
          : ZineAppBar(
              title: '@${p?.handle ?? 'anon'}·${fingerprintOf(r)}',
              subtitle: 'profile // node',
              actions: [
                ZineIconButton(icon: Icons.qr_code_2, onPressed: () => context.push(Routes.meet), tooltip: 'meet / verify'),
                _ProfileMenu(root: r),
              ],
            ),
      body: Grain(
        child: ListView(padding: const EdgeInsets.all(JaalSpace.s4), children: [
          if (warn.isNotEmpty) ...[LookalikeBanner(warning: warn.first), const SizedBox(height: JaalSpace.s4)],
          if (status?.state == ModState.flagged) ...[
            const HazardTape(child: Text('flagged by a moderator · content hidden from feeds')),
            const SizedBox(height: JaalSpace.s4),
          ],
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Stack(clipBehavior: Clip.none, children: [
              Polaroid(
                root: r,
                size: 128,
                tilt: -0.05,
                onTap: own ? () => _pickAvatar(context, ref) : () {},
              ),
              const Positioned(left: 10, top: -12, child: TapeStrip(width: 80, angle: -0.1)),
            ]),
            const SizedBox(width: JaalSpace.s4),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Highlighted(nameOf(ref, r), size: 34),
                const SizedBox(height: 8),
                MonoChip('○ @${p?.handle ?? 'anon'}·${fingerprintOf(r)}', color: JaalColors.paperDeep),
                const SizedBox(height: 8),
                Wrap(spacing: 6, runSpacing: 6, children: [
                  if (mods.contains(r)) const ModBadge(),
                  if (verified) const MetIrlStamp(),
                ]),
                if ((p?.bio ?? '').isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(p!.bio, style: Theme.of(context).textTheme.bodyLarge),
                ],
                const SizedBox(height: 8),
                if (nearby)
                  const MonoChip('● nearby now', color: JaalColors.acid)
                else if (seen != null && !own)
                  HandNote('last met: ${ago(seen.lastSeen)}', size: 20),
              ]),
            ),
          ]),
          const SizedBox(height: JaalSpace.s5),
          Row(children: [
            Expanded(child: _Stat(n: posts.length, label: 'posts')),
            const SizedBox(width: JaalSpace.s2),
            Expanded(child: _Stat(n: followers, label: 'followers')),
            const SizedBox(width: JaalSpace.s2),
            Expanded(child: _Stat(n: following, label: 'following')),
          ]),
          const SizedBox(height: JaalSpace.s4),
          if (own)
            Wrap(spacing: JaalSpace.s2, runSpacing: JaalSpace.s2, children: [
              ZineButton(icon: Icons.edit_outlined, label: 'edit profile', onPressed: () => _edit(context, ref, p)),
              ZineButton(
                  color: JaalColors.paper,
                  icon: Icons.qr_code_2,
                  label: 'my qr',
                  onPressed: () => context.push(Routes.meet)),
              ZineButton(
                  color: JaalColors.pink,
                  icon: Icons.ios_share,
                  label: 'pass jaal on',
                  onPressed: () => context.push(Routes.share)),
              ZineIconButton(icon: Icons.settings_outlined, onPressed: () => context.push(Routes.settings), tooltip: 'settings'),
            ])
          else
            Row(children: [
              Expanded(
                child: ZineButton(
                  icon: iFollow ? Icons.check : Icons.person_add_alt,
                  color: iFollow ? JaalColors.paper : JaalColors.acid,
                  label: iFollow ? 'following' : 'follow',
                  expand: true,
                  onPressed: () => iFollow ? node.unfollow(r) : node.follow(r),
                ),
              ),
              const SizedBox(width: JaalSpace.s2),
              Expanded(
                child: ZineButton(
                  color: JaalColors.paper,
                  icon: Icons.mark_email_unread_outlined,
                  label: 'letter',
                  expand: true,
                  onPressed: p == null ? null : () => context.push(Routes.chat(r)),
                ),
              ),
            ]),
          const SizedBox(height: JaalSpace.s5),
          if (own)
            ZineBox(
              color: JaalColors.blue,
              child: Row(children: [
                const Icon(Icons.inventory_2_outlined, color: JaalColors.paper),
                const SizedBox(width: 10),
                Expanded(
                  child: Text('carry pouch: $pouch letter${pouch == 1 ? '' : 's'} · clout $clout',
                      style: monoStyle(13, color: JaalColors.paper, bold: true)),
                ),
                ZineButton(small: true, color: JaalColors.paper, label: 'open', onPressed: () => context.push(Routes.pouch)),
              ]),
            )
          else
            _TrustStrip(root: r, verified: verified),
          if (own) ...[
            const SizedBox(height: JaalSpace.s4),
            _ModerationEntry(isMod: mods.contains(r)),
          ],
          const SizedBox(height: JaalSpace.s5),
          Row(children: [
            InkLabel('posts (${posts.length})', color: JaalColors.acid, textColor: JaalColors.ink),
            const Spacer(),
            Text('${posts.where((x) => JaalNode.mediaOf(x).isNotEmpty).length} photos',
                style: monoStyle(11, color: JaalColors.xerox)),
          ]),
          const SizedBox(height: JaalSpace.s3),
          if (posts.isEmpty)
            HandNote(own ? 'nothing posted yet. tap + below.' : 'no posts have reached your phone yet.',
                color: JaalColors.xerox, size: 20)
          else
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 6,
              crossAxisSpacing: 6,
              children: [for (final post in posts) _GridTile(post: post)],
            ),
          const SizedBox(height: JaalSpace.s5),
          ZineBox(
            shadow: JaalStroke.shadowSmall,
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Row(children: [
              Icon(Icons.share_location_outlined, color: ink),
              const SizedBox(width: 10),
              Expanded(child: Text('synced pocket to pocket', style: monoStyle(12))),
              Text('0 kb cloud', style: monoStyle(12, bold: true)),
            ]),
          ),
          const SizedBox(height: JaalSpace.s6),
        ]),
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, ProfileRow? p) async {
    final name = TextEditingController(text: p?.name ?? '');
    final handle = TextEditingController(text: p?.handle ?? '');
    final bio = TextEditingController(text: p?.bio ?? '');
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('edit profile'),
        content: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(controller: name, decoration: const InputDecoration(labelText: 'display name')),
            const SizedBox(height: 10),
            TextField(controller: handle, decoration: const InputDecoration(labelText: 'handle', prefixText: '@')),
            const SizedBox(height: 10),
            TextField(controller: bio, maxLines: 3, maxLength: Bodies.maxBio, decoration: const InputDecoration(labelText: 'bio')),
          ]),
        ),
        actions: [ZineButton(small: true, label: 'save', onPressed: () => Navigator.pop(ctx, true))],
      ),
    );
    if (ok == true) {
      try {
        await ref.read(nodeProvider).setProfile(
            name: name.text.trim(),
            handle: handle.text.trim().toLowerCase(),
            bio: bio.text.trim(),
            avatar: p?.avatar == null ? null : (CanonicalJson.decode(p!.avatar!)! as Map).cast());
      } on Object catch (e) {
        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final f = await ImagePicker().pickImage(source: ImageSource.gallery, requestFullMetadata: false);
    if (f == null) return;
    final bytes = await f.readAsBytes();
    final photo = await Isolate.run(() => PhotoCompressor.compress(bytes, maxEdge: 480, targetBytes: 80 * 1024));
    await ref.read(nodeProvider).setAvatar(photo);
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.n, required this.label});
  final int n;
  final String label;

  @override
  Widget build(BuildContext context) => TicketStub(
        child: Column(children: [
          Text('$n', style: monoStyle(18, bold: true)),
          Text(label, style: monoStyle(11, color: JaalColors.xerox)),
        ]),
      );
}

class _TrustStrip extends ConsumerWidget {
  const _TrustStrip({required this.root, required this.verified});
  final String root;
  final bool verified;

  @override
  Widget build(BuildContext context, WidgetRef ref) => ZineBox(
        dashed: true,
        shadow: Offset.zero,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
              child: verified
                  ? Transform.rotate(
                      angle: -0.02,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: JaalColors.acid.withValues(alpha: 0.35),
                          border: Border.all(color: const Color(0xFF4E6700), width: 2.5),
                        ),
                        child: Text('verified in person ✓', style: monoStyle(13, color: const Color(0xFF3A4D00), bold: true)),
                      ),
                    )
                  : Text('not verified — scan their qr when you meet', style: monoStyle(12, bold: true)),
            ),
            const Icon(Icons.lock_outline, color: Color(0xFF4E6700)),
          ]),
          const SizedBox(height: 10),
          Text('every post is signed by their key. nobody else can post as them.', style: monoStyle(11)),
          const Divider(height: 18),
          Row(children: [
            Expanded(
              child: Text('fingerprint: ${longFingerprintOf(root)}', style: monoStyle(11, color: JaalColors.xerox)),
            ),
            GestureDetector(
              onTap: () => context.push(Routes.meet),
              child: Text('verify_qr',
                  style: monoStyle(12, color: JaalColors.blue, bold: true).copyWith(decoration: TextDecoration.underline)),
            ),
          ]),
        ]),
      );
}

class _ModerationEntry extends StatelessWidget {
  const _ModerationEntry({required this.isMod});
  final bool isMod;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => context.push(isMod ? Routes.modDesk : Routes.becomeMod),
        child: ZineBox(
          shadow: JaalStroke.shadowSmall,
          child: Row(children: [
            const Icon(Icons.shield_outlined, color: JaalColors.blue),
            const SizedBox(width: 10),
            Expanded(
              child: Text(isMod ? 'moderation desk' : 'become a moderator (3 in-person vouches)',
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            const Icon(Icons.arrow_forward),
          ]),
        ),
      );
}

class _GridTile extends StatelessWidget {
  const _GridTile({required this.post});
  final PostRow post;

  @override
  Widget build(BuildContext context) {
    final media = JaalNode.mediaOf(post);
    return GestureDetector(
      onTap: () => context.push(Routes.post(post.id)),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: JaalColors.ink, width: 2.5)),
        child: Stack(fit: StackFit.expand, children: [
          if (media.isNotEmpty)
            JaalPhoto(manifest: media.first, compact: false)
          else
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              padding: const EdgeInsets.all(8),
              child: Text('"${post.body}"',
                  maxLines: 5, overflow: TextOverflow.ellipsis, style: monoStyle(11)),
            ),
          if (post.hops > 0)
            Positioned(
              right: 4,
              bottom: 4,
              child: Postmark(hops: post.hops, size: 40, bottom: ago(post.ts).replaceAll(' ago', '')),
            ),
        ]),
      ),
    );
  }
}

class _ProfileMenu extends ConsumerWidget {
  const _ProfileMenu({required this.root});
  final String root;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final node = ref.read(nodeProvider);
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (v) async {
        switch (v) {
          case 'nick':
            final c = TextEditingController(text: ref.read(petnamesProvider).value?[root] ?? '');
            final name = await showDialog<String>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('private nickname'),
                content: TextField(controller: c, decoration: const InputDecoration(hintText: 'only you see this')),
                actions: [ZineButton(small: true, label: 'save', onPressed: () => Navigator.pop(ctx, c.text))],
              ),
            );
            if (name != null) await node.setPetname(root, name);
          case 'block':
            await node.block(root);
          case 'moderate':
            if (context.mounted) await showRemoveSheet(context, ref, root);
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'nick', child: Text('set private nickname')),
        const PopupMenuItem(value: 'block', child: Text('block (only you know)')),
        if (node.isModerator) const PopupMenuItem(value: 'moderate', child: Text('★ moderate')),
      ],
    );
  }
}
