import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import 'inner_shadow.dart';

enum GlassTone {
  /// Rich navy glass, for the hero surfaces that sit on the light
  /// backdrop and have to look like they are floating above it.
  dark,

  /// Frosted white glass, for secondary panels, pills and the nav bar. In
  /// dark mode it resolves to deep navy glass instead — the tone describes
  /// the card's *rank* on the page, not its literal colour.
  light,

  /// White frost that never flips, for surfaces that carry their own bright
  /// fill — the aurora cover cards stay cyan in dark mode, so the pills
  /// floating on them, and the ink on those pills, stay light-surface too.
  frost,
}

/// Ink for content sitting on a [GlassCard].
///
/// A `light` card is white glass in light mode but dark glass in dark mode, so
/// text has to follow the resolved surface rather than the tone the caller
/// asked for.
class GlassInk {
  GlassInk._();

  static bool surfaceIsDark(BuildContext context, GlassTone tone) =>
      tone == GlassTone.dark ||
      (tone != GlassTone.frost &&
          Theme.of(context).brightness == Brightness.dark);

  static Color primary(BuildContext context, GlassTone tone) =>
      surfaceIsDark(context, tone)
      ? AppColors.textPrimaryDark
      : AppColors.textPrimaryLight;

  static Color muted(BuildContext context, GlassTone tone) =>
      surfaceIsDark(context, tone)
      ? AppColors.textMutedDark
      : AppColors.textMutedLight;
}

/// The one surface every floating element is built from.
///
/// Stacks, bottom to top: blurred backdrop -> tint -> top reflection ->
/// inner shadow -> hairline rim -> content. Two shadows fall *outside* the
/// clip (contact + ambient), which is what separates the card from the page.
class GlassCard extends StatelessWidget {
  final Widget child;
  final GlassTone tone;
  final EdgeInsetsGeometry? padding;
  final BorderRadius borderRadius;
  final double blur;

  /// 1 = resting, 2 = hero, 3 = sheet. Scales the ambient shadow only.
  final double lift;

  /// Coloured halo, used by primary CTAs and the active nav tab's disc.
  final Color? glow;

  /// Replaces the flat glass tint on the dark tone. Hero surfaces carry their
  /// own ramp — keep the stops partly transparent or the blur underneath has
  /// nothing left to show.
  final Gradient? fill;

  /// Replaces the neutral navy inner shadow. A bright fill (white glass, say)
  /// turns that shadow grey where it meets the edge, so those surfaces want a
  /// tinted one.
  final Color? innerTint;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.tone = GlassTone.dark,
    this.padding,
    this.borderRadius = const BorderRadius.all(Radius.circular(AppRadius.xl)),
    this.blur = AppBlur.medium,
    this.lift = 1,
    this.glow,
    this.fill,
    this.innerTint,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final darkSurface = GlassInk.surfaceIsDark(context, tone);

    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        boxShadow: glow != null
            ? AppShadow.glow(glow!)
            : AppShadow.shadow(isDark: darkSurface, lift: lift),
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    gradient: fill,
                    color: fill == null
                        ? (darkSurface
                              ? AppColors.glassDark
                              : AppColors.glassLight)
                        : null,
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: darkSurface
                          ? const [
                              AppColors.glassReflection,
                              Colors.transparent,
                            ]
                          : [
                              Colors.white.withValues(alpha: 0.55),
                              Colors.transparent,
                            ],
                      stops: const [0, 0.55],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: CustomPaint(
                  painter: InnerShadowPainter(
                    borderRadius: borderRadius,
                    color:
                        innerTint ??
                        (darkSurface
                            ? Colors.black.withValues(alpha: 0.32)
                            : // Navy at 10% is what greys a white card's edge;
                              // the brand cyan keeps the depth and stays on hue.
                              AppColors.primary.withValues(alpha: 0.12)),
                    blur: darkSurface ? 16 : 12,
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    border: Border.all(
                      color: darkSurface
                          ? AppColors.hairlineDark
                          : AppColors.hairlineLight,
                      width: AppShadow.hairlineWidth,
                    ),
                  ),
                ),
              ),
              _content(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content() {
    final body = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
    if (onTap == null) return body;
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        splashColor: Colors.white.withValues(alpha: 0.08),
        highlightColor: Colors.white.withValues(alpha: 0.04),
        child: body,
      ),
    );
  }
}
