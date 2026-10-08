import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/session.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';
import 'profile_fields.dart';

class RestoreScreen extends ConsumerStatefulWidget {
  const RestoreScreen({super.key});

  @override
  ConsumerState<RestoreScreen> createState() => _RestoreScreenState();
}

class _RestoreScreenState extends ConsumerState<RestoreScreen> {
  final _form = GlobalKey<FormState>();
  final _phrase = TextEditingController();
  final _name = TextEditingController();
  final _handle = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _phrase.dispose();
    _name.dispose();
    _handle.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      await ref.read(sessionProvider.notifier).restore(_phrase.text,
          name: _name.text.trim(), handle: _handle.text.trim());
      if (mounted) context.go(Routes.lab);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('that phrase doesn\'t check out. typo?')));
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('restore')),
        body: Grain(
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(JaalSpace.s5),
              children: [
                const HandNote('same words → same you. this phone gets its own device key.'),
                const SizedBox(height: JaalSpace.s5),
                TextFormField(
                  controller: _phrase,
                  minLines: 4,
                  maxLines: 6,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: const TextStyle(fontFamily: JaalFonts.mono),
                  decoration: const InputDecoration(labelText: '24 words, spaces between'),
                  validator: (v) =>
                      (v ?? '').trim().split(RegExp(r'\s+')).length == 24 ? null : 'need exactly 24 words',
                ),
                const SizedBox(height: JaalSpace.s4),
                ProfileFields(name: _name, handle: _handle),
                const SizedBox(height: JaalSpace.s6),
                ZineButton(
                  label: _busy ? 'restoring…' : 'restore me',
                  expand: true,
                  onPressed: _busy ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      );
}
