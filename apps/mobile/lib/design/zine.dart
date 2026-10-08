import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'tokens.dart';

/// Ink colour for the current brightness.
Color inkOf(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? JaalColors.inkOnVoid
    : JaalColors.ink;

/// Display text style: Space Grotesk 700, tight, negative tracking.
TextStyle displayStyle(double size, {Color? color}) => TextStyle(
  fontFamily: JaalFonts.display,
  fontWeight: FontWeight.w700,
  fontSize: size,
  height: 1.0,
  letterSpacing: -0.04 * size,
  color: color,
);

TextStyle monoStyle(double size, {Color? color, bool bold = false}) =>
    TextStyle(
      fontFamily: JaalFonts.mono,
      fontSize: size,
      letterSpacing: 0.04 * size,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
      color: color,
    );

TextStyle handStyle({
  double size = JaalSize.hand,
  Color color = JaalColors.blue,
}) => TextStyle(
  fontFamily: JaalFonts.hand,
  fontSize: size,
  fontWeight: FontWeight.w600,
  color: color,
  height: 1.1,
);

/// The basic zine block: thick ink border, hard unblurred offset shadow,
/// optional deterministic tilt.
class ZineBox extends StatelessWidget {
  const ZineBox({
    super.key,
    required this.child,
    this.color,
    this.padding = const EdgeInsets.all(JaalSpace.s4),
    this.shadow = JaalStroke.shadow,
    this.tilt = 0,
    this.dashed = false,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;
  final Offset shadow;
  final double tilt;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    final ink = inkOf(context);
    Widget box = Container(
      margin: EdgeInsets.only(right: shadow.dx, bottom: shadow.dy),
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surface,
        border: dashed ? null : Border.all(color: ink, width: JaalStroke.thick),
        boxShadow: shadow == Offset.zero
            ? null
            : [BoxShadow(color: ink, offset: shadow, blurRadius: 0)],
      ),
      child: child,
    );
    if (dashed) {
      box = CustomPaint(foregroundPainter: _DashedBorder(ink), child: box);
    }
    if (tilt != 0) box = Transform.rotate(angle: tilt, child: box);
    return box;
  }
}

class _DashedBorder extends CustomPainter {
  _DashedBorder(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    const dash = 8.0, gap = 6.0;
    final r = Offset.zero & Size(size.width - 6, size.height - 6);
    void line(Offset a, Offset b) {
      final len = (b - a).distance;
      final dir = (b - a) / len;
      for (var d = 0.0; d < len; d += dash + gap) {
        canvas.drawLine(a + dir * d, a + dir * min(d + dash, len), p);
      }
    }

    line(r.topLeft, r.topRight);
    line(r.topRight, r.bottomRight);
    line(r.bottomRight, r.bottomLeft);
    line(r.bottomLeft, r.topLeft);
  }

  @override
  bool shouldRepaint(_DashedBorder old) => old.color != color;
}

/// Button whose shadow collapses on press (the element "pushes in").
class ZineButton extends StatefulWidget {
  const ZineButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.color = JaalColors.acid,
    this.icon,
    this.small = false,
    this.expand = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color color;
  final IconData? icon;
  final bool small;
  final bool expand;

  @override
  State<ZineButton> createState() => _ZineButtonState();
}

class _ZineButtonState extends State<ZineButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final ink = inkOf(context);
    final enabled = widget.onPressed != null;
    final shadow = widget.small ? JaalStroke.shadowSmall : JaalStroke.shadow;
    final offset = _down ? shadow : Offset.zero;
    final fg = widget.color.computeLuminance() > 0.4
        ? JaalColors.ink
        : JaalColors.paper;
    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: widget.small ? 16 : 22, color: fg),
          const SizedBox(width: JaalSpace.s2),
        ],
        Flexible(
          child: Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
            style: displayStyle(
              widget.small ? JaalSize.small + 1 : JaalSize.h3,
              color: fg,
            ).copyWith(letterSpacing: widget.small ? 0 : -0.4),
          ),
        ),
      ],
    );
    return Semantics(
      button: true,
      enabled: enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: () => setState(() => _down = false),
        onTapUp: enabled
            ? (_) {
                setState(() => _down = false);
                widget.onPressed!();
              }
            : null,
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: AnimatedContainer(
            duration: JaalMotion.press,
            transform: Matrix4.translationValues(offset.dx, offset.dy, 0),
            margin: EdgeInsets.only(right: shadow.dx, bottom: shadow.dy),
            padding: EdgeInsets.symmetric(
              horizontal: widget.small ? JaalSpace.s3 : JaalSpace.s5,
              vertical: widget.small ? JaalSpace.s2 : JaalSpace.s3 + 2,
            ),
            decoration: BoxDecoration(
              color: widget.color,
              border: Border.all(color: ink, width: JaalStroke.thick),
              boxShadow: _down
                  ? const []
                  : [BoxShadow(color: ink, offset: shadow, blurRadius: 0)],
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

/// Square icon button with border + small hard shadow (top bars).
class ZineIconButton extends StatelessWidget {
  const ZineIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.badge,
    this.badgeColor = JaalColors.pink,
    this.color,
    this.tooltip,
    this.size = 48,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final int? badge;
  final Color badgeColor;
  final Color? color;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ink = inkOf(context);
    final btn = GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        margin: const EdgeInsets.only(right: 3, bottom: 3),
        decoration: BoxDecoration(
          color: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(color: ink, width: JaalStroke.thick),
          boxShadow: [BoxShadow(color: ink, offset: JaalStroke.shadowSmall)],
        ),
        child: Icon(icon, color: ink, size: size * 0.5),
      ),
    );
    return Tooltip(
      message: tooltip ?? '',
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          btn,
          if ((badge ?? 0) > 0)
            Positioned(
              right: -6,
              top: -8,
              child: Container(
                constraints: const BoxConstraints(minWidth: 22),
                height: 22,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: badgeColor,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(color: JaalColors.ink, width: 2),
                ),
                child: Text(
                  '${badge! > 99 ? '99+' : badge}',
                  style: monoStyle(11, color: JaalColors.paper, bold: true),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A strip of masking tape, for pinning things to the page.
class TapeStrip extends StatelessWidget {
  const TapeStrip({super.key, this.width = 72, this.angle = -0.08, this.label});

  final double width;
  final double angle;
  final String? label;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: angle,
    child: ClipPath(
      clipper: _RaggedClipper(),
      child: Container(
        width: width,
        height: 22,
        color: JaalColors.tape.withValues(alpha: 0.85),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: label == null
            ? null
            : Text(
                label!,
                maxLines: 1,
                overflow: TextOverflow.fade,
                softWrap: false,
                style: monoStyle(
                  JaalSize.micro,
                  color: JaalColors.ink,
                  bold: true,
                ),
              ),
      ),
    ),
  );
}

class _RaggedClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final p = Path()..moveTo(0, 0);
    p.lineTo(s.width, 0);
    for (var y = 0.0; y <= s.height; y += 4) {
      p.lineTo(s.width - ((y ~/ 4).isEven ? 3.0 : 0.0), y);
    }
    p.lineTo(0, s.height);
    for (var y = s.height; y >= 0; y -= 4) {
      p.lineTo((y ~/ 4).isOdd ? 3.0 : 0.0, y);
    }
    return p..close();
  }

  @override
  bool shouldReclip(_) => false;
}

/// Rubber-stamp postmark: double red ring, −12°, "3 hops" / "2d 4h".
class Postmark extends StatelessWidget {
  const Postmark({
    super.key,
    required this.hops,
    this.transit,
    this.size = 64,
    this.top,
    this.bottom,
  });

  final int hops;
  final Duration? transit;
  final double size;

  /// Override the stamp text (e.g. "delivered").
  final String? top, bottom;

  static String transitLabel(Duration d) {
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m';
    return 'live';
  }

  @override
  Widget build(BuildContext context) {
    final red = JaalColors.stamp.withValues(alpha: 0.88);
    return Transform.rotate(
      angle: -12 * pi / 180,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: red, width: 2),
        ),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: JaalColors.paper.withValues(alpha: 0.35),
            border: Border.all(color: red, width: 1.5),
          ),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(2),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  top ??
                      (hops == 0
                          ? 'local'
                          : '$hops hop${hops == 1 ? '' : 's'}'),
                  style: monoStyle(size * 0.15, color: red, bold: true),
                ),
                Container(
                  height: 1.5,
                  width: size * 0.55,
                  color: red,
                  margin: const EdgeInsets.symmetric(vertical: 2),
                ),
                Text(
                  bottom ?? (transit == null ? 'jaal' : transitLabel(transit!)),
                  style: monoStyle(size * 0.13, color: red),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mono label chip, e.g. a key fingerprint or a status.
class MonoChip extends StatelessWidget {
  const MonoChip(this.text, {super.key, this.color, this.textColor, this.icon});

  final String text;
  final Color? color;
  final Color? textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final ink = inkOf(context);
    final fg = textColor ?? (color == null ? ink : JaalColors.ink);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color ?? Colors.transparent,
        border: Border.all(color: ink, width: JaalStroke.hairline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: monoStyle(JaalSize.micro, color: fg, bold: color != null),
            ),
          ),
        ],
      ),
    );
  }
}

/// Xerox grain over the whole background.
class Grain extends StatelessWidget {
  const Grain({super.key, required this.child, this.opacity = 0.06});

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.passthrough,
    children: [
      child,
      IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            size: Size.infinite,
            painter: _GrainPainter(inkOf(context).withValues(alpha: opacity)),
          ),
        ),
      ),
    ],
  );
}

class _GrainPainter extends CustomPainter {
  _GrainPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(1337);
    final paint = Paint()..color = color;
    final n = (size.width * size.height / 90).clamp(0, 30000).toInt();
    final pts = <Offset>[
      for (var i = 0; i < n; i++)
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
    ];
    canvas.drawPoints(ui.PointMode.points, pts, paint..strokeWidth = 1.2);
  }

  @override
  bool shouldRepaint(_GrainPainter old) => old.color != color;
}

/// Dotted halftone fill (empty states, image placeholders, corkboards).
class Halftone extends StatelessWidget {
  const Halftone({
    super.key,
    this.color = JaalColors.paperDeep,
    this.dot,
    this.child,
    this.spacing = 10,
  });

  final Color color;
  final Color? dot;
  final Widget? child;
  final double spacing;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _HalftonePainter(
      color,
      dot ?? inkOf(context).withValues(alpha: 0.13),
      spacing,
    ),
    child: child,
  );
}

class _HalftonePainter extends CustomPainter {
  _HalftonePainter(this.bg, this.dot, this.spacing);
  final Color bg, dot;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = bg);
    final p = Paint()..color = dot;
    for (var y = spacing / 2; y < size.height; y += spacing) {
      for (
        var x = (y ~/ spacing).isEven ? spacing / 2 : spacing;
        x < size.width;
        x += spacing
      ) {
        canvas.drawCircle(Offset(x, y), 1.6, p);
      }
    }
  }

  @override
  bool shouldRepaint(_HalftonePainter old) => old.bg != bg || old.dot != dot;
}

/// Handwritten aside (Caveat, blue or red).
class HandNote extends StatelessWidget {
  const HandNote(
    this.text, {
    super.key,
    this.color,
    this.angle = -0.03,
    this.size = JaalSize.hand,
  });

  final String text;
  final Color? color;
  final double angle;
  final double size;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: angle,
    child: Text(
      text,
      style: handStyle(size: size, color: color ?? JaalColors.blue),
    ),
  );
}

/// Lowercase headline with a skewed acid highlighter swipe behind it.
class Highlighted extends StatelessWidget {
  const Highlighted(
    this.text, {
    super.key,
    this.size = JaalSize.h2,
    this.color = JaalColors.acid,
  });

  final String text;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final onColor = color.computeLuminance() > 0.4
        ? JaalColors.ink
        : JaalColors.paper;
    // Size to the text, not the parent: lists hand children the full width.
    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      heightFactor: 1,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: -4,
            right: -8,
            bottom: dark ? -2 : size * 0.02,
            height: dark ? size * 1.15 : size * 0.5,
            child: Transform(
              transform: Matrix4.skewX(-0.105) * Matrix4.rotationZ(-0.012),
              child: ColoredBox(color: color),
            ),
          ),
          Text(
            text,
            style: displayStyle(size, color: dark ? onColor : inkOf(context)),
          ),
        ],
      ),
    );
  }
}

/// Small black label block like "SECURE STORE-AND-FORWARD" (kept lowercase).
class InkLabel extends StatelessWidget {
  const InkLabel(
    this.text, {
    super.key,
    this.color = JaalColors.ink,
    this.textColor = JaalColors.paper,
  });
  final String text;
  final Color color, textColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    color: color,
    child: Text(
      text,
      style: monoStyle(JaalSize.micro, color: textColor, bold: true),
    ),
  );
}

/// Section header row: mono caps-free label on the left, meta on the right.
class SectionHeader extends StatelessWidget {
  const SectionHeader(this.title, {super.key, this.meta, this.icon});
  final String title;
  final String? meta;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: JaalSpace.s3),
    child: Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18, color: inkOf(context)),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            title,
            style: monoStyle(13, color: inkOf(context), bold: true),
          ),
        ),
        if (meta != null)
          Text(
            meta!,
            style: monoStyle(JaalSize.micro, color: JaalColors.xerox),
          ),
      ],
    ),
  );
}

/// Yellow/black diagonal hazard tape with a message (flagged / lookalike).
class HazardTape extends StatelessWidget {
  const HazardTape({
    super.key,
    required this.child,
    this.angle = 0.015,
    this.red = false,
  });
  final Widget child;
  final double angle;
  final bool red;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: angle,
    child: Container(
      decoration: BoxDecoration(
        border: Border.all(color: JaalColors.ink, width: 2),
      ),
      child: CustomPaint(
        painter: _StripePainter(red ? JaalColors.stamp : JaalColors.tape),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Container(
            color: red ? JaalColors.stamp : JaalColors.paper,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: DefaultTextStyle(
              style: monoStyle(
                12,
                color: red ? JaalColors.paper : JaalColors.ink,
                bold: true,
              ),
              child: child,
            ),
          ),
        ),
      ),
    ),
  );
}

class _StripePainter extends CustomPainter {
  _StripePainter(this.a);
  final Color a;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = a);
    final p = Paint()..color = JaalColors.ink;
    for (var x = -size.height; x < size.width + size.height; x += 22) {
      final path = Path()
        ..moveTo(x, size.height)
        ..lineTo(x + 11, size.height)
        ..lineTo(x + 11 + size.height, 0)
        ..lineTo(x + size.height, 0)
        ..close();
      canvas.drawPath(path, p);
    }
  }

  @override
  bool shouldRepaint(_StripePainter old) => old.a != a;
}

/// Ticket stub (stats, travel log) with punched side notches.
class TicketStub extends StatelessWidget {
  const TicketStub({super.key, required this.child, this.color});
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) => ClipPath(
    clipper: _NotchClipper(),
    child: Container(
      decoration: BoxDecoration(
        color: color ?? Theme.of(context).colorScheme.surfaceContainerHighest,
        border: Border.all(color: inkOf(context), width: JaalStroke.thick),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: child,
    ),
  );
}

class _NotchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final r = 9.0, cy = s.height / 2;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(s.width, 0)
      ..lineTo(s.width, cy - r)
      ..arcToPoint(
        Offset(s.width, cy + r),
        radius: Radius.circular(r),
        clockwise: false,
      )
      ..lineTo(s.width, s.height)
      ..lineTo(0, s.height)
      ..lineTo(0, cy + r)
      ..arcToPoint(
        Offset(0, cy - r),
        radius: Radius.circular(r),
        clockwise: false,
      )
      ..close();
  }

  @override
  bool shouldReclip(_) => false;
}

/// Circular stamp slot (moderator vouches): filled red stamp or dashed slot.
class StampSlot extends StatelessWidget {
  const StampSlot({super.key, this.label, this.sub, this.size = 92});
  final String? label;
  final String? sub;
  final double size;

  @override
  Widget build(BuildContext context) {
    final filled = label != null;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: filled ? JaalColors.stamp : JaalColors.xerox,
          width: filled ? 3 : 2,
        ),
      ),
      alignment: Alignment.center,
      child: Transform.rotate(
        angle: filled ? -0.2 : 0,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              filled ? '★ vouched' : '1 more',
              style: monoStyle(
                11,
                color: filled ? JaalColors.stamp : JaalColors.xerox,
                bold: true,
              ),
            ),
            if (filled)
              Text(label!, style: monoStyle(10, color: JaalColors.stamp)),
            if (sub != null)
              Text(sub!, style: monoStyle(9, color: JaalColors.stamp)),
          ],
        ),
      ),
    );
  }
}
