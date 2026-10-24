import 'dart:async';

import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';

/// Runs [action] behind a blocking processing dialog for at least 2.5 seconds,
/// so the fake gateway never flashes past faster than a real one would.
Future<T> runPaymentProcessing<T>({
  required BuildContext context,
  required Future<T> Function() action,
  required List<String> steps,
}) async {
  final navigator = Navigator.of(context, rootNavigator: true);
  final stopwatch = Stopwatch()..start();
  var dialogOpen = true;

  showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'payment-processing',
    barrierColor: Colors.black.withValues(alpha: 0.6),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (_, _, _) => PaymentProcessingDialog(steps: steps),
    transitionBuilder: (_, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );

  try {
    final result = await action();
    final remaining = const Duration(milliseconds: 2500) - stopwatch.elapsed;
    if (remaining > Duration.zero) await Future<void>.delayed(remaining);
    if (dialogOpen && navigator.mounted && navigator.canPop()) navigator.pop();
    dialogOpen = false;
    return result;
  } catch (_) {
    if (dialogOpen && navigator.mounted && navigator.canPop()) navigator.pop();
    dialogOpen = false;
    rethrow;
  }
}

class PaymentProcessingDialog extends StatefulWidget {
  final List<String> steps;

  const PaymentProcessingDialog({super.key, required this.steps});

  @override
  State<PaymentProcessingDialog> createState() =>
      _PaymentProcessingDialogState();
}

class _PaymentProcessingDialogState extends State<PaymentProcessingDialog> {
  Timer? _timer;
  int _activeStep = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 850), (timer) {
      if (!mounted) return;
      if (_activeStep < widget.steps.length - 1) {
        setState(() => _activeStep++);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      child: Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg + 4,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 106,
                      height: 106,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation(
                          AppColors.primary.withValues(alpha: 0.7),
                        ),
                        backgroundColor: AppColors.primary.withValues(
                          alpha: 0.1,
                        ),
                      ),
                    ),
                    Container(
                      width: 82,
                      height: 82,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: AppColors.heroGradient,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.34),
                            blurRadius: 22,
                            offset: const Offset(0, 9),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  l10n.tr('payment.processingTitle'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.tr('payment.processingBody'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.055),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.09),
                    ),
                  ),
                  child: Column(
                    children: [
                      for (var i = 0; i < widget.steps.length; i++) ...[
                        _StepRow(
                          label: widget.steps[i],
                          active: i == _activeStep,
                          done: i < _activeStep,
                        ),
                        if (i != widget.steps.length - 1)
                          const SizedBox(height: AppSpacing.sm + 2),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      size: 14,
                      color: theme.textTheme.bodySmall?.color,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        l10n.tr('payment.demoNote'),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final String label;
  final bool active;
  final bool done;

  const _StepRow({
    required this.label,
    required this.active,
    required this.done,
  });

  @override
  Widget build(BuildContext context) {
    final color = done || active
        ? AppColors.primary
        : Theme.of(context).disabledColor;
    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: 22,
          height: 22,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: done
                ? AppColors.success
                : active
                ? AppColors.primary.withValues(alpha: 0.12)
                : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: done
                  ? AppColors.success
                  : color.withValues(alpha: active ? 0 : 0.5),
            ),
          ),
          child: done
              ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
              : active
              ? const SizedBox(
                  width: 11,
                  height: 11,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                )
              : null,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              fontSize: 12.5,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: done
                  ? Theme.of(context).textTheme.bodySmall?.color
                  : color,
            ),
            child: Text(label),
          ),
        ),
        if (done)
          const Icon(Icons.check_rounded, size: 14, color: AppColors.success),
      ],
    );
  }
}
