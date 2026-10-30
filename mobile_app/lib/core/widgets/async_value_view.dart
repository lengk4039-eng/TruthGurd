import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../localization/app_localizations.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Renders an [AsyncValue] with a consistent loading/error/data look so
/// every screen doesn't hand-roll its own spinner and error card.
///
/// Give exactly one of [builder] (a box) or [sliverBuilder] (for use inside a
/// [CustomScrollView]). The loading and error states adapt to whichever is
/// used, so a sliver list doesn't have to break out of the sliver tree.
class AsyncValueView<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data)? builder;
  final Widget Function(T data)? sliverBuilder;
  final VoidCallback? onRetry;

  const AsyncValueView({
    super.key,
    required this.value,
    this.builder,
    this.sliverBuilder,
    this.onRetry,
  }) : assert(
         (builder == null) != (sliverBuilder == null),
         'Provide either builder or sliverBuilder.',
       );

  @override
  Widget build(BuildContext context) {
    if (sliverBuilder != null) {
      return value.when(
        data: sliverBuilder!,
        loading: () => SliverToBoxAdapter(child: _loading()),
        error: (error, _) =>
            SliverToBoxAdapter(child: _error(context, error: error)),
      );
    }
    return value.when(
      data: builder!,
      loading: _loading,
      error: (error, _) => _error(context, error: error),
    );
  }

  Widget _loading() => const Padding(
    padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
    child: Center(child: CircularProgressIndicator()),
  );

  Widget _error(BuildContext context, {required Object error}) => Padding(
    padding: const EdgeInsets.symmetric(
      vertical: AppSpacing.xxl,
      horizontal: AppSpacing.lg,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.wifi_off_rounded, size: 40, color: AppColors.error),
        const SizedBox(height: AppSpacing.md),
        Text(
          error.toString().replaceFirst('AppException: ', ''),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        if (onRetry != null) ...[
          const SizedBox(height: AppSpacing.md),
          TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(context.l10n.tr('common.tryAgain')),
          ),
        ],
      ],
    ),
  );
}
