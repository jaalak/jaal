import 'package:flutter/material.dart';
import 'package:jaal_core/jaal_core.dart';

import '../../design/tokens.dart';

/// Name + handle inputs with protocol-level validation.
class ProfileFields extends StatelessWidget {
  const ProfileFields({super.key, required this.name, required this.handle});

  final TextEditingController name;
  final TextEditingController handle;

  static String? validateName(String? v) {
    final s = v?.trim() ?? '';
    if (s.isEmpty) return 'need a name (any name)';
    if (s.length > Bodies.maxName) return 'max ${Bodies.maxName} chars';
    return null;
  }

  static String? validateHandle(String? v) {
    final s = v?.trim() ?? '';
    if (!Bodies.handlePattern.hasMatch(s)) {
      return '2–24 chars: a-z 0-9 _ .';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'display name'),
            validator: validateName,
          ),
          const SizedBox(height: JaalSpace.s4),
          TextFormField(
            controller: handle,
            autocorrect: false,
            decoration: const InputDecoration(
              labelText: 'handle',
              prefixText: '@',
              helperText: 'not globally unique — your key fingerprint is shown next to it',
              helperMaxLines: 2,
            ),
            onChanged: (v) {
              final lower = v.toLowerCase();
              if (lower != v) {
                handle.value = handle.value.copyWith(text: lower);
              }
            },
            validator: validateHandle,
          ),
        ],
      );
}
