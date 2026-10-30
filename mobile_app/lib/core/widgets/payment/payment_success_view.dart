import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';

class PaymentSuccessHeader extends StatelessWidget {
  final String title;
  final String message;
  final String? badge;

  const PaymentSuccessHeader({
    super.key,
    required this.title,
    required this.message,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.4, end: 1),
          duration: const Duration(milliseconds: 650),
          curve: Curves.elasticOut,
          builder: (context, value, child) =>
              Transform.scale(scale: value, child: child),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 116,
                height: 116,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.success.withValues(alpha: 0.08),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.16),
                    width: 8,
                  ),
                ),
              ),
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF34D07A), Color(0xFF0FA055)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.34),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 42,
                ),
              ),
              if (badge != null)
                Positioned(
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 6),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.textTheme.bodySmall?.color,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class PaymentReceiptRow {
  final String label;
  final String value;
  final bool emphasize;

  const PaymentReceiptRow(this.label, this.value, {this.emphasize = false});
}

class PaymentReceiptCard extends StatelessWidget {
  final String title;
  final List<PaymentReceiptRow> rows;
  final String? footer;
  final String? reference;

  const PaymentReceiptCard({
    super.key,
    required this.title,
    required this.rows,
    this.footer,
    this.reference,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  size: 18,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(title, style: theme.textTheme.titleMedium)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(
                  context.l10n.tr('status.paid').toUpperCase(),
                  style: const TextStyle(
                    color: AppColors.success,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (var i = 0; i < rows.length; i++) ...[
            _row(context, rows[i]),
            if (i != rows.length - 1)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 9),
                child: Divider(),
              ),
          ],
          if (reference != null) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Column(
                children: [
                  Text(
                    context.l10n.tr('payment.reference').toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 9.5,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    reference!,
                    style: theme.textTheme.titleSmall?.copyWith(
                      letterSpacing: 0.8,
                      color: AppColors.brandInk,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (footer != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 15,
                  color: theme.textTheme.bodySmall?.color,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    footer!,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _row(BuildContext context, PaymentReceiptRow row) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            row.label,
            style: theme.textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          flex: 6,
          child: Text(
            row.value,
            textAlign: TextAlign.end,
            style: row.emphasize
                ? theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.brandInk,
                    fontSize: 15,
                  )
                : theme.textTheme.titleSmall?.copyWith(fontSize: 12.5),
          ),
        ),
      ],
    );
  }
}
