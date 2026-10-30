import 'dart:ui';

import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import 'glass_icon.dart';

class NavTab {
  final GlassIconKind kind;
  final String label;
  final int branch;

  const NavTab({required this.kind, required this.label, required this.branch});
}

/// The floating tab bar.
///
/// Five identical slots in one row — the centre action is not raised or
/// enlarged, so every icon shares the same baseline and the same hit area.
/// Whichever tab is active gets the glowing cyan disc; the others stay muted.
class AquaticNavBar extends StatelessWidget {
  final List<NavTab> leftTabs;
  final List<NavTab> rightTabs;
  final NavTab center;
  final int? activeBranch;
  final ValueChanged<NavTab> onSelect;

  const AquaticNavBar({
    super.key,
    required this.leftTabs,
    required this.rightTabs,
    required this.center,
    required this.activeBranch,
    required this.onSelect,
  });

  static const double barHeight = 70;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const radius = BorderRadius.all(Radius.circular(AppRadius.nav));
    final tabs = [...leftTabs, center, ...rightTabs];

    return Container(
      height: barHeight,
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppShadow.shadow(isDark: isDark, lift: 2),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: AppBlur.strong,
            sigmaY: AppBlur.strong,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        AppColors.glassDark.withValues(alpha: 0.94),
                        AppColors.glassDarkDeep,
                      ]
                    : [
                        Colors.white.withValues(alpha: 0.94),
                        Colors.white.withValues(alpha: 0.80),
                      ],
              ),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.14)
                    : Colors.white.withValues(alpha: 0.85),
                width: AppShadow.hairlineWidth,
              ),
              borderRadius: radius,
            ),
            child: Row(
              children: [
                for (final tab in tabs)
                  Expanded(
                    child: _NavButton(
                      tab: tab,
                      selected: activeBranch == tab.branch,
                      onSelect: onSelect,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final NavTab tab;
  final bool selected;
  final ValueChanged<NavTab> onSelect;

  const _NavButton({
    required this.tab,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // Labels are ~11.5px, so the brand has to darken on white glass.
    final active = selected
        ? AppColors.brandOn(onDark: isDark)
        : (isDark ? AppColors.textMutedDark : AppColors.textMutedLight);

    return InkWell(
      onTap: () => onSelect(tab),
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: SizedBox.expand(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _GlowDisc(
              size: 40,
              on: selected,
              glowRadius: 16,
              child: TweenAnimationBuilder<Color?>(
                duration: _GlowDisc.animation,
                curve: Curves.easeOutCubic,
                tween: ColorTween(end: selected ? AppColors.onPrimary : active),
                builder: (context, color, _) => GlassIcon(
                  kind: tab.kind,
                  size: 23,
                  tile: false,
                  mono: color ?? active,
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              tab.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                height: 1.1,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: active,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The glowing cyan disc behind the active tab's icon. Content on it must use
/// [AppColors.onPrimary] — white on cyan is 1.7:1.
class _GlowDisc extends StatelessWidget {
  static const Duration animation = Duration(milliseconds: 220);

  final double size;
  final bool on;
  final double glowRadius;
  final Widget child;

  const _GlowDisc({
    required this.size,
    required this.child,
    this.on = true,
    this.glowRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final a = on ? 1.0 : 0.0;
    return AnimatedContainer(
      duration: animation,
      curve: Curves.easeOutCubic,
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        // Both states keep the same gradient geometry, so switching fades the
        // disc in rather than popping a new decoration on. The light source is
        // the cyan core, cooling to aurora blue and then a violet rim, so the
        // selected tab reads as the same lamp as the coverage card.
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.45),
          radius: 1.25,
          colors: [
            AppColors.primaryLight.withValues(alpha: a),
            AppColors.auroraBlue.withValues(alpha: a),
            AppColors.auroraViolet.withValues(alpha: a),
          ],
          stops: const [0.0, 0.55, 1.0],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.55 * a),
          width: 1.2,
        ),
        // Symmetric halo: the disc sits inside the bar, so a downward offset
        // would bleed out under the bar's bottom edge.
        boxShadow: on
            ? AppShadow.glow(AppColors.primary, radius: glowRadius, y: 0)
            : const [],
      ),
      child: child,
    );
  }
}
