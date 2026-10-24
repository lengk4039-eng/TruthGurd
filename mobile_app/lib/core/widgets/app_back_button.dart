import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
    return Padding(
      padding: padding,
      child: IconButton(
        tooltip: 'Back',
        onPressed: onPressed ??
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
          backgroundColor: backgroundColor ?? scheme.primary.withValues(alpha: 0.10),
          foregroundColor: foregroundColor ?? scheme.primary,
          minimumSize: const Size(38, 38),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
        ),
      ),
    );
  }
}
