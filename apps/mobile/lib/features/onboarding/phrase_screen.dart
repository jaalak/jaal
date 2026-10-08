import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../design/tokens.dart';
import '../../design/zine.dart';

/// Shows the 24-word recovery phrase like numbered stickers on paper.
class PhraseScreen extends StatefulWidget {
  const PhraseScreen({super.key, required this.phrase});
  final String phrase;

  @override
  State<PhraseScreen> createState() => _PhraseScreenState();
}

class _PhraseScreenState extends State<PhraseScreen> {
  bool _wroteItDown = false;

  @override
  Widget build(BuildContext context) {
    final words = widget.phrase.split(' ');
    return Scaffold(
      appBar: AppBar(title: const Text('your 24 words')),
      body: Grain(
        child: ListView(
          padding: const EdgeInsets.all(JaalSpace.s5),
          children: [
            Text('write these down.\nlike, on paper.',
                style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: JaalSpace.s2),
            const HandNote('lose the phone + lose these = lose you. no reset button out here.',
                color: JaalColors.stamp),
            const SizedBox(height: JaalSpace.s5),
            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: JaalSpace.s2,
              crossAxisSpacing: JaalSpace.s2,
              childAspectRatio: 2.1,
              children: [
                for (var i = 0; i < words.length; i++)
                  ZineBox(
                    shadow: JaalStroke.shadowSmall,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    tilt: (i % 3 - 1) * 0.012,
                    color: i.isEven ? null : Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Row(
                      children: [
                        Text('${i + 1}'.padLeft(2, '0'),
                            style: const TextStyle(
                                fontFamily: JaalFonts.mono,
                                fontSize: JaalSize.micro,
                                color: JaalColors.xerox)),
                        const SizedBox(width: 4),
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(words[i],
                                style: const TextStyle(
                                    fontFamily: JaalFonts.mono, fontWeight: FontWeight.w700)),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: JaalSpace.s5),
            CheckboxListTile(
              value: _wroteItDown,
              onChanged: (v) => setState(() => _wroteItDown = v ?? false),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              title: const Text('i wrote them down somewhere safe'),
            ),
            const SizedBox(height: JaalSpace.s3),
            ZineButton(
              label: 'enter jaal',
              expand: true,
              onPressed: _wroteItDown ? () => context.go(Routes.home) : null,
            ),
            const SizedBox(height: JaalSpace.s3),
            Center(
              child: TextButton(
                onPressed: () => context.go(Routes.home),
                child: const Text('skip for now (risky — we\'ll nag you)',
                    style: TextStyle(color: JaalColors.xerox)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
