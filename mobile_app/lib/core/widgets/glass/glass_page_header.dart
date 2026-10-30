import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import 'glass_card.dart';

/// A control for a page header — the same light glass as the cards, at button
/// size, so the header row and the content below it share one material.
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final String? tooltip;
  final double size;

  /// Paints a dot in the top-right corner; used for unread counts.
  final bool showBadge;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.size = 42,
    this.showBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final button = GlassCard(
      tone: GlassTone.light,
      blur: AppBlur.soft,
      borderRadius: BorderRadius.all(Radius.circular(size / 2)),
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Icon(
          icon,
          size: size * 0.5,
          color: GlassInk.primary(context, GlassTone.light),
        ),
      ),
    );
    final Widget framed = tooltip == null
        ? button
        : Tooltip(message: tooltip!, child: button);
    if (!showBadge) return framed;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        framed,
        Positioned(
          right: 2,
          top: 2,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.error,
              shape: BoxShape.circle,
              border: Border.all(
                color: GlassInk.surfaceIsDark(context, GlassTone.light)
                    ? AppColors.glassDark
                    : Colors.white,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// The title block that replaces a solid [AppBar] on a glass screen.
///
/// It scrolls with the content rather than pinning, which keeps the backdrop
/// visible behind the status area instead of capping it with an opaque bar.
class GlassPageHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;

  const GlassPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 10)],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.headlineSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          for (final action in actions) ...[
            const SizedBox(width: AppSpacing.sm),
            action,
          ],
        ],
      ),
    );
  }
}
