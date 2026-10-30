import 'package:flutter/material.dart';

import '../../localization/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_dimens.dart';
import 'glass_card.dart';
import 'glass_icon.dart';

/// Component B — the floating reminder strip that sits above the content.
///
/// The countdown is derived from the real due date, so it changes meaning
/// hour by hour instead of being static demo copy.
class ReminderBanner extends StatelessWidget {
  final String title;
  final DateTime dueDate;
  final VoidCallback onTap;

  const ReminderBanner({
    super.key,
    required this.title,
    required this.dueDate,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      tone: GlassTone.light,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.md)),
      blur: AppBlur.soft,
      lift: 1.4,
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
      onTap: onTap,
      child: Row(
        children: [
          const GlassIcon(kind: GlassIconKind.key, size: 46),
          const SizedBox(width: AppSpacing.sm + 2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: GlassInk.primary(context, GlassTone.light),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _countdown(context),
                  style: TextStyle(
                    fontSize: 12,
                    color: GlassInk.muted(context, GlassTone.light),
                  ),
                ),
              ],
            ),
          ),
          GlassCard(
            tone: GlassTone.dark,
            blur: AppBlur.soft,
            glow: AppColors.primary,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppRadius.pill),
            ),
            padding: const EdgeInsets.all(9),
            onTap: onTap,
            child: const Icon(
              Icons.arrow_forward_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  String _countdown(BuildContext context) {
    final l10n = context.l10n;
    final remaining = dueDate.difference(DateTime.now());
    if (remaining.isNegative) {
      final late = remaining.abs();
      return late.inDays >= 1
          ? l10n.tr('home.overdueDays', {'count': '${late.inDays}'})
          : l10n.tr('home.overdueHours', {'count': '${late.inHours}'});
    }
    if (remaining.inDays >= 1) {
      return l10n.tr('home.dueInDays', {'count': '${remaining.inDays}'});
    }
    if (remaining.inHours >= 1) {
      return l10n.tr('home.dueInHours', {'count': '${remaining.inHours}'});
    }
    return l10n.tr('home.dueInMinutes', {'count': '${remaining.inMinutes}'});
  }
}
