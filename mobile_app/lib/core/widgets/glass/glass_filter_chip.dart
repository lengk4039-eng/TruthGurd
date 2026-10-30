import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import 'glass_card.dart';

/// A filter pill on the aurora backdrop.
///
/// Unselected it is ordinary light glass; selected it takes the same lit cyan
/// as the nav bar's active disc, so "this is on" reads the same way everywhere.
class GlassFilterChip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const GlassFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  static const Duration animation = Duration(milliseconds: 200);
  static const EdgeInsets geometry = EdgeInsets.symmetric(
    horizontal: 15,
    vertical: 9,
  );

  @override
  Widget build(BuildContext context) {
    final idle = GlassInk.muted(context, GlassTone.light);
    final ink = selected ? AppColors.onPrimary : idle;
    return GlassCard(
      tone: GlassTone.light,
      blur: AppBlur.soft,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.pill)),
      padding: EdgeInsets.zero,
      glow: selected ? AppColors.primary : null,
      onTap: onTap,
      child: AnimatedContainer(
        duration: animation,
        curve: Curves.easeOutCubic,
        padding: geometry,
        // Both states declare the same gradient shape so the fill cross-fades
        // instead of appearing in one frame.
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(AppRadius.pill)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: selected
                ? const [AppColors.primary, AppColors.auroraBlue]
                : [Colors.transparent, Colors.white.withValues(alpha: 0.0)],
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              TweenAnimationBuilder<Color?>(
                duration: animation,
                curve: Curves.easeOutCubic,
                tween: ColorTween(end: ink),
                builder: (context, color, _) =>
                    Icon(icon, size: 16, color: color ?? idle),
              ),
              const SizedBox(width: 7),
            ],
            AnimatedDefaultTextStyle(
              duration: animation,
              curve: Curves.easeOutCubic,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                // White on the cyan fill is 1.7:1; lit pills use the navy ink.
                color: ink,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

/// The same pills as a horizontally scrolling row.
class GlassFilterBar extends StatelessWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const GlassFilterBar({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        padding: EdgeInsets.zero,
        itemCount: labels.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) => GlassFilterChip(
          label: labels[i],
          selected: i == selectedIndex,
          onTap: () => onSelect(i),
        ),
      ),
    );
  }
}
