import 'package:flutter/material.dart';

import '../../models/insurance_category.dart';
import '../../theme/app_colors.dart';

/// Which 3D glyph stands for which insurance line.
GlassIconKind glyphForCategory(InsuranceCategoryType category) {
  switch (category) {
    case InsuranceCategoryType.health:
      return GlassIconKind.medicalCross;
    case InsuranceCategoryType.life:
      return GlassIconKind.heart;
    case InsuranceCategoryType.vehicle:
      return GlassIconKind.car;
    case InsuranceCategoryType.home:
      return GlassIconKind.house;
    case InsuranceCategoryType.travel:
      return GlassIconKind.plane;
  }
}

/// Every glyph the app needs, painted rather than drawn as line art.
enum GlassIconKind {
  shield,
  medicalCross,
  car,
  plane,
  house,
  heart,
  key,
  bell,
  wallet,
  person,
  bag,
  receipt,
}

/// A 3D glass icon rendered at runtime: a lit, refractive tile with a glyph
/// extruded out of it. Painted instead of bundled, so it stays crisp at any
/// size and re-tints itself for the dark theme.
class GlassIcon extends StatelessWidget {
  final GlassIconKind kind;
  final double size;

  /// The internal bloom colour. Defaults to the brand cyan.
  final Color? tint;

  /// False paints just the floating glyph, for tight inline slots.
  final bool tile;

  /// Cyan/azure tile for interactive chrome; the default is the deep navy body
  /// used on content cards.
  final bool bright;

  /// Flat tint for the glyph, skipping the lit glass face. Needed wherever the
  /// icon sits on a light surface — a white glass glyph would vanish.
  final Color? mono;

  const GlassIcon({
    super.key,
    required this.kind,
    this.size = 56,
    this.tint,
    this.tile = true,
    this.bright = false,
    this.mono,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GlassIconPainter(
          kind: kind,
          accent: tint ?? AppColors.primary,
          bright: bright,
          tile: tile,
          mono: mono,
        ),
      ),
    );
  }
}

class _GlassIconPainter extends CustomPainter {
  final GlassIconKind kind;
  final Color accent;
  final bool bright;
  final bool tile;
  final Color? mono;

  const _GlassIconPainter({
    required this.kind,
    required this.accent,
    required this.bright,
    required this.tile,
    required this.mono,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    if (tile) _paintTile(canvas, s);
    _paintGlyph(canvas, size);
  }

  void _paintTile(Canvas canvas, double s) {
    final rect = Rect.fromLTWH(s * 0.04, s * 0.04, s * 0.92, s * 0.92);
    final r = Radius.circular(s * 0.30);
    final rrect = RRect.fromRectAndCorners(
      rect,
      topLeft: r,
      topRight: r,
      bottomLeft: r,
      bottomRight: r,
    );
    final path = Path()..addRRect(rrect);

    // A bright tile is the one place the brand glow is allowed to leak: it is
    // what makes the quick actions read as lit from inside rather than printed.
    if (bright) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.deflate(s * 0.06),
          Radius.circular(s * 0.34),
        ),
        Paint()
          ..color = AppColors.primary.withValues(alpha: 0.38)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.16),
      );
    }

    canvas.drawShadow(
      path,
      Colors.black.withValues(alpha: 0.30),
      s * 0.035,
      false,
    );

    // Body: light enters top-left, the far corner falls into shadow.
    canvas.drawPath(
      path,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.75, -0.85),
          radius: 1.5,
          colors: bright
              ? const [
                  AppColors.primaryLight,
                  AppColors.primary,
                  AppColors.auroraBlue,
                ]
              : const [Color(0xFF1B6FA8), Color(0xFF0C3A57), Color(0xFF041C2E)],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(rect),
    );

    canvas.save();
    canvas.clipPath(path);

    // Specular streak across the top edge.
    canvas.drawOval(
      Rect.fromLTWH(-s * 0.2, -s * 0.44, s * 1.5, s * 0.88),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.32)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.10),
    );

    // Ambient bounce along the bottom, so the tile never reads as a decal.
    canvas.drawOval(
      Rect.fromLTWH(-s * 0.15, s * 0.70, s * 1.35, s * 0.72),
      Paint()
        ..color = accent.withValues(alpha: 0.50)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * 0.16),
    );
    canvas.restore();

    // Hairline rim, brighter where the light hits.
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.58),
            Colors.white.withValues(alpha: 0.12),
            Colors.white.withValues(alpha: 0.04),
          ],
        ).createShader(rect),
    );
  }

  void _paintGlyph(Canvas canvas, Size size) {
    final s = tile ? size.width * 0.52 : size.width * 0.80;
    final dx = (size.width - s) / 2;
    final dy = (size.height - s) / 2;
    final glyph = _Glyphs.of(kind);

    if (mono != null) {
      _paintMonoGlyph(canvas, size, glyph);
      return;
    }

    // Glyph geometry is authored in a 0..1 box, so paint it through a scaled
    // canvas. Shader rects are local and therefore unit-sized; MaskFilter blur
    // is device-space, which is why it is multiplied by the pixel scale.
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(s, s);

    final blur = MaskFilter.blur(BlurStyle.normal, s * 0.16);
    final glowPaint = Paint()
      ..color = accent.withValues(alpha: 0.70)
      ..maskFilter = blur;
    final depthPaint = Paint()..color = Colors.black.withValues(alpha: 0.45);
    final faceShader = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFFFFF), Color(0xFFF5FAFE), Color(0xFFC3E2F2)],
    ).createShader(const Rect.fromLTWH(0, 0, 1, 1));

    for (final p in glyph.fills) {
      canvas.drawPath(p.shift(const Offset(0, 0.03)), glowPaint);
      canvas.drawPath(p.shift(const Offset(0, 0.045)), depthPaint);
      canvas.drawPath(p, Paint()..shader = faceShader);
    }
    for (final st in glyph.strokes) {
      canvas.drawPath(
        st.path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = st.width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = accent.withValues(alpha: 0.70)
          ..maskFilter = blur,
      );
      canvas.drawPath(
        st.path.shift(const Offset(0, 0.045)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = st.width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = Colors.black.withValues(alpha: 0.45),
      );
      canvas.drawPath(
        st.path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = st.width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..shader = faceShader,
      );
    }
    canvas.restore();
  }

  /// Flat, lightly embossed glyph for small slots on light surfaces.
  void _paintMonoGlyph(Canvas canvas, Size size, _Glyph glyph) {
    final s = tile ? size.width * 0.52 : size.width * 0.80;
    final dx = (size.width - s) / 2;
    final dy = (size.height - s) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(s, s);

    final face = Paint()..color = mono!;
    final depth = Paint()..color = mono!.withValues(alpha: 0.28);
    for (final p in glyph.fills) {
      canvas.drawPath(p.shift(const Offset(0, 0.022)), depth);
      canvas.drawPath(p, face);
    }
    for (final st in glyph.strokes) {
      canvas.drawPath(
        st.path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = st.width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..color = mono!,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlassIconPainter old) =>
      old.kind != kind ||
      old.accent != accent ||
      old.bright != bright ||
      old.tile != tile ||
      old.mono != mono;
}

class _Stroke {
  final Path path;
  final double width;
  const _Stroke(this.path, this.width);
}

class _Glyph {
  final List<Path> fills;
  final List<_Stroke> strokes;
  const _Glyph(this.fills, [List<_Stroke>? strokes])
    : strokes = strokes ?? const [];
}

/// Glyph outlines authored in a 0..1 box. Cut-outs are done with path
/// subtraction so the glass tile shows through the hole instead of a painted
/// fake, which is what keeps the shape reading as solid glass.
class _Glyphs {
  _Glyphs._();

  static Path _rrect(double x, double y, double w, double h, double r) => Path()
    ..addRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(r)),
    );

  static Path _circle(double cx, double cy, double r) =>
      Path()..addOval(Rect.fromCircle(center: Offset(cx, cy), radius: r));

  static Path _union(List<Path> parts) =>
      parts.reduce((a, b) => Path.combine(PathOperation.union, a, b));

  static Path _cut(Path from, Path hole) =>
      Path.combine(PathOperation.difference, from, hole);

  static _Glyph of(GlassIconKind kind) {
    switch (kind) {
      case GlassIconKind.shield:
        final body = Path()
          ..moveTo(0.50, 0.04)
          ..cubicTo(0.66, 0.13, 0.80, 0.18, 0.90, 0.20)
          ..lineTo(0.90, 0.52)
          ..cubicTo(0.90, 0.74, 0.75, 0.90, 0.50, 0.98)
          ..cubicTo(0.25, 0.90, 0.10, 0.74, 0.10, 0.52)
          ..lineTo(0.10, 0.20)
          ..cubicTo(0.20, 0.18, 0.34, 0.13, 0.50, 0.04)
          ..close();
        final check = Path()
          ..moveTo(0.30, 0.50)
          ..lineTo(0.44, 0.65)
          ..lineTo(0.70, 0.34)
          ..lineTo(0.77, 0.41)
          ..lineTo(0.45, 0.78)
          ..lineTo(0.23, 0.56)
          ..close();
        return _Glyph([_cut(body, check)]);

      case GlassIconKind.medicalCross:
        return _Glyph([
          _union([
            _rrect(0.37, 0.08, 0.26, 0.84, 0.10),
            _rrect(0.08, 0.37, 0.84, 0.26, 0.10),
          ]),
        ]);

      case GlassIconKind.car:
        final body = _rrect(0.04, 0.46, 0.92, 0.30, 0.12);
        final cabin = Path()
          ..moveTo(0.19, 0.52)
          ..lineTo(0.31, 0.22)
          ..quadraticBezierTo(0.34, 0.16, 0.41, 0.16)
          ..lineTo(0.64, 0.16)
          ..quadraticBezierTo(0.71, 0.16, 0.74, 0.22)
          ..lineTo(0.86, 0.52)
          ..close();
        return _Glyph([
          _union([
            body,
            cabin,
            _circle(0.26, 0.76, 0.13),
            _circle(0.74, 0.76, 0.13),
          ]),
        ]);

      case GlassIconKind.plane:
        final jet = Path()
          ..moveTo(0.50, 0.03)
          ..quadraticBezierTo(0.60, 0.19, 0.60, 0.40)
          ..lineTo(0.98, 0.65)
          ..lineTo(0.98, 0.74)
          ..lineTo(0.59, 0.66)
          ..lineTo(0.57, 0.83)
          ..lineTo(0.72, 0.93)
          ..lineTo(0.72, 0.99)
          ..lineTo(0.50, 0.93)
          ..lineTo(0.28, 0.99)
          ..lineTo(0.28, 0.93)
          ..lineTo(0.43, 0.83)
          ..lineTo(0.41, 0.66)
          ..lineTo(0.02, 0.74)
          ..lineTo(0.02, 0.65)
          ..lineTo(0.40, 0.40)
          ..quadraticBezierTo(0.40, 0.19, 0.50, 0.03)
          ..close();
        return _Glyph([jet]);

      case GlassIconKind.house:
        final roof = Path()
          ..moveTo(0.50, 0.03)
          ..lineTo(0.98, 0.46)
          ..lineTo(0.02, 0.46)
          ..close();
        final walls = _rrect(0.15, 0.42, 0.70, 0.54, 0.08);
        final door = _rrect(0.42, 0.62, 0.17, 0.34, 0.05);
        return _Glyph([
          _cut(_union([roof, walls]), door),
        ]);

      case GlassIconKind.heart:
        final h = Path()
          ..moveTo(0.50, 0.95)
          ..cubicTo(0.11, 0.68, 0.03, 0.43, 0.14, 0.25)
          ..cubicTo(0.24, 0.09, 0.44, 0.11, 0.50, 0.29)
          ..cubicTo(0.56, 0.11, 0.76, 0.09, 0.86, 0.25)
          ..cubicTo(0.97, 0.43, 0.89, 0.68, 0.50, 0.95)
          ..close();
        return _Glyph([h]);

      case GlassIconKind.key:
        final ring = _cut(_circle(0.36, 0.29, 0.23), _circle(0.36, 0.29, 0.09));
        final shaft = _rrect(0.30, 0.44, 0.12, 0.51, 0.06);
        final toothA = _rrect(0.42, 0.66, 0.20, 0.10, 0.05);
        final toothB = _rrect(0.42, 0.82, 0.14, 0.10, 0.05);
        return _Glyph([
          _union([ring, shaft, toothA, toothB]),
        ]);

      case GlassIconKind.bell:
        final body = Path()
          ..moveTo(0.50, 0.06)
          ..cubicTo(0.69, 0.06, 0.79, 0.21, 0.79, 0.39)
          ..cubicTo(0.79, 0.57, 0.83, 0.67, 0.89, 0.75)
          ..lineTo(0.11, 0.75)
          ..cubicTo(0.17, 0.67, 0.21, 0.57, 0.21, 0.39)
          ..cubicTo(0.21, 0.21, 0.31, 0.06, 0.50, 0.06)
          ..close();
        final rim = _rrect(0.07, 0.73, 0.86, 0.14, 0.07);
        final clapper = _circle(0.50, 0.93, 0.10);
        final knob = _circle(0.50, 0.07, 0.07);
        return _Glyph([
          _union([body, rim, clapper, knob]),
        ]);

      case GlassIconKind.wallet:
        var body = _rrect(0.04, 0.20, 0.92, 0.62, 0.16);
        body = _cut(body, _rrect(0.60, 0.37, 0.44, 0.28, 0.12));
        final clasp = _circle(0.76, 0.51, 0.065);
        return _Glyph([body, clasp]);

      case GlassIconKind.person:
        final head = _circle(0.50, 0.27, 0.21);
        final shoulders = Path()
          ..moveTo(0.08, 0.97)
          ..cubicTo(0.10, 0.69, 0.27, 0.55, 0.50, 0.55)
          ..cubicTo(0.73, 0.55, 0.90, 0.69, 0.92, 0.97)
          ..close();
        return _Glyph([
          _union([head, shoulders]),
        ]);

      case GlassIconKind.bag:
        final body = _rrect(0.09, 0.29, 0.82, 0.65, 0.14);
        final handle = Path()
          ..moveTo(0.31, 0.33)
          ..cubicTo(0.31, 0.07, 0.69, 0.07, 0.69, 0.33);
        return _Glyph([body], [_Stroke(handle, 0.10)]);

      case GlassIconKind.receipt:
        final paper = Path()..moveTo(0.16, 0.04);
        paper.lineTo(0.84, 0.04);
        paper.lineTo(0.84, 0.86);
        for (var i = 0; i < 6; i++) {
          final x = 0.84 - (i + 0.5) * (0.68 / 6);
          paper.lineTo(x, i.isEven ? 0.96 : 0.86);
        }
        paper.lineTo(0.16, 0.86);
        paper.close();
        var cut = paper;
        for (final y in [0.26, 0.44, 0.62]) {
          cut = _cut(cut, _rrect(0.27, y, 0.46, 0.07, 0.035));
        }
        return _Glyph([cut]);
    }
  }
}
