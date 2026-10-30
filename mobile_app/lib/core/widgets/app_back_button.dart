import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Rounded back control used on every pushed screen so navigation is always
/// visible, including when a screen is opened from a deep link.
class AppBackButton extends StatelessWidget {
  final Color? foregroundColor;
  final Color? backgroundColor;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;

  const AppBackButton({
    super.key,
    this.foregroundColor,
    this.backgroundColor,
    this.onPressed,
    this.padding = const EdgeInsets.only(left: AppSpacing.sm),
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // `primary` is a bright cyan and reads at 1.7:1 on a light page, so the
    // glyph takes the dark end of the brand ramp instead.
    final brand = AppColors.brandOn(
      onDark: Theme.of(context).brightness == Brightness.dark,
    );
    return Padding(
      padding: padding,
      child: IconButton(
        tooltip: context.l10n.tr('common.back'),
        onPressed:
            onPressed ??
            () {
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                navigator.pop();
              } else {
                context.go('/home');
              }
            },
        icon: const Icon(Icons.arrow_back_rounded, size: 20),
        style: IconButton.styleFrom(
          backgroundColor:
              backgroundColor ?? scheme.primary.withValues(alpha: 0.10),
          foregroundColor: foregroundColor ?? brand,
          minimumSize: const Size(38, 38),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
    );
  }
}
