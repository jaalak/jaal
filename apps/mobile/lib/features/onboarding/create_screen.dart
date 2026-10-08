import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../app/session.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';
import 'profile_fields.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _handle = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _handle.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _busy = true);
    try {
      final phrase = await ref
          .read(sessionProvider.notifier)
          .create(name: _name.text.trim(), handle: _handle.text.trim());
      if (mounted) context.go(Routes.phrase, extra: phrase);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('new node')),
        body: Grain(
          child: Form(
            key: _form,
            child: ListView(
              padding: const EdgeInsets.all(JaalSpace.s5),
              children: [
                const HandNote('your keys are made on this phone.\nno server ever sees them.'),
                const SizedBox(height: JaalSpace.s5),
                ProfileFields(name: _name, handle: _handle),
                const SizedBox(height: JaalSpace.s6),
                ZineButton(
                  label: _busy ? 'forging keys…' : 'forge my keys',
                  icon: Icons.key,
                  expand: true,
                  onPressed: _busy ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      );
}
