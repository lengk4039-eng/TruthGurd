import 'package:flutter/material.dart';

/// A real inner shadow. [BoxShadow] can only fall outwards, so a translucent
/// card would otherwise have no depth where it meets the backdrop.
///
/// The trick: blur a ring that sits *outside* the card's edge, then clip to the
/// card so only the bleed that spills inwards is visible.
class InnerShadowPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final Color color;
  final double blur;
  final Offset offset;

  const InnerShadowPainter({
    required this.borderRadius,
    required this.color,
    this.blur = 14,
    this.offset = const Offset(0, 4),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);
    final card = Path()..addRRect(rrect);
    final ring = Path.combine(
      PathOperation.difference,
      Path()..addRect(rect.inflate(blur * 2)),
      card,
    );

    canvas.save();
    canvas.clipPath(card);
    canvas.translate(offset.dx, offset.dy);
    canvas.drawPath(
      ring,
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(InnerShadowPainter old) =>
      old.borderRadius != borderRadius ||
      old.color != color ||
      old.blur != blur ||
      old.offset != offset;
}
