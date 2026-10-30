import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';

/// The page the glass floats on: a cool radial wash under drifting aurora
/// bands. The bands are not decoration for its own sake — a [BackdropFilter]
/// has nothing to blur over a flat fill, so these are what make the cards read
/// as genuinely translucent.
class AppBackdrop extends StatelessWidget {
  final Widget child;

  const AppBackdrop({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.55),
          radius: 1.3,
          colors: isDark
              ? const [AppColors.backdropInnerDark, AppColors.backdropOuterDark]
              : const [
                  AppColors.backdropInnerLight,
                  AppColors.backdropOuterLight,
                ],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(painter: _AuroraPainter(isDark: isDark)),
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Each band is a long, thin oval filled with a hue ramp along its own length
/// and faded out at both ends, so it reads as light drifting across the page
/// rather than a shape sitting on it.
class _AuroraPainter extends CustomPainter {
  final bool isDark;

  const _AuroraPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // The light page has to stay bright: the bands only have to be *present*
    // for the cards to read as glass, so on white they run at two thirds of the
    // dark-mode alpha and the violet tip stays a whisper.
    final a = isDark ? 0.62 : 0.22;

    _band(
      canvas,
      center: Offset(size.width * 0.46, size.height * 0.13),
      radii: Size(size.width * 1.5, size.height * 0.17),
      angle: -0.20,
      from: AppColors.primary,
      to: AppColors.auroraBlue,
      alpha: a,
    );
    _band(
      canvas,
      center: Offset(size.width * 0.52, size.height * 0.40),
      radii: Size(size.width * 1.7, size.height * 0.20),
      angle: 0.16,
      from: AppColors.auroraBlue,
      to: isDark ? AppColors.auroraViolet : AppColors.auroraIce,
      alpha: a * 0.85,
    );
    // Deep navy is a dark-mode-only hue: over the near-black wash it reads as
    // structure, but at the same alpha on white it composites to a grey smudge.
    _band(
      canvas,
      center: Offset(size.width * 0.48, size.height * 0.72),
      radii: Size(size.width * 1.6, size.height * 0.22),
      angle: -0.12,
      from: isDark ? AppColors.auroraDeep : AppColors.auroraIce,
      to: AppColors.auroraBlue,
      alpha: a * 0.9,
    );

    // A single bloom where the eye lands first, so the bands have something
    // to appear to be radiating from.
    _bloom(
      canvas,
      center: Offset(size.width * 0.18, size.height * 0.10),
      radius: size.width * 0.62,
      color: AppColors.primary,
      alpha: isDark ? 0.30 : 0.16,
    );
    // Counterweight in the opposite corner. Violet is the one hue that cannot
    // be confused with the cyan brand, so it only ever appears this faintly.
    _bloom(
      canvas,
      center: Offset(size.width * 0.92, size.height * 0.88),
      radius: size.width * 0.55,
      color: AppColors.auroraViolet,
      alpha: isDark ? 0.22 : 0.10,
    );
  }

  void _band(
    Canvas canvas, {
    required Offset center,
    required Size radii,
    required double angle,
    required Color from,
    required Color to,
    required double alpha,
  }) {
    final rect = Rect.fromCenter(
      center: Offset.zero,
      width: radii.width,
      height: radii.height,
    );
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          from.withValues(alpha: 0),
          from.withValues(alpha: alpha),
          to.withValues(alpha: alpha * 0.8),
          to.withValues(alpha: 0),
        ],
        stops: const [0.0, 0.32, 0.70, 1.0],
      ).createShader(rect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radii.height * 0.42);

    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..rotate(angle)
      ..drawOval(rect, paint)
      ..restore();
  }

  void _bloom(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
    required double alpha,
  }) {
    final rect = Rect.fromCircle(center: Offset.zero, radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: 0),
        ],
      ).createShader(rect)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.25);

    canvas
      ..save()
      ..translate(center.dx, center.dy)
      ..drawCircle(Offset.zero, radius, paint)
      ..restore();
  }

  @override
  bool shouldRepaint(_AuroraPainter old) => old.isDark != isDark;
}
