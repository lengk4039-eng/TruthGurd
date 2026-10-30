import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/app_notification.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/glass/glass_card.dart';
import '../../../core/widgets/glass/glass_page_scaffold.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  IconData _iconFor(NotificationType type) {
    switch (type) {
      case NotificationType.payment:
        return Icons.payments_rounded;
      case NotificationType.policy:
        return Icons.shield_rounded;
      case NotificationType.promo:
        return Icons.local_offer_rounded;
      case NotificationType.system:
        return Icons.info_rounded;
    }
  }

  String _relativeTime(AppLocalizations l10n, DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) {
      return l10n.tr('notifications.minutesAgo', {
        'count': '${diff.inMinutes}',
      });
    }
    if (diff.inHours < 24) {
      return l10n.tr('notifications.hoursAgo', {'count': '${diff.inHours}'});
    }
    if (diff.inDays < 30) {
      return l10n.tr('notifications.daysAgo', {'count': '${diff.inDays}'});
    }
    return l10n.tr('notifications.monthsAgo', {
      'count': '${(diff.inDays / 30).floor()}',
    });
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(myNotificationsProvider);
    final l10n = context.l10n;
    final onDark = Theme.of(context).brightness == Brightness.dark;
    final brand = AppColors.brandOn(onDark: onDark);

    return GlassPageScaffold(
      title: l10n.tr('notifications.title'),
      child: AsyncValueView(
        value: notificationsAsync,
        onRetry: () => ref.invalidate(myNotificationsProvider),
        builder: (notifications) {
          if (notifications.isEmpty) {
            return EmptyState(
              icon: Icons.notifications_none_rounded,
              title: l10n.tr('notifications.emptyTitle'),
              message: l10n.tr('notifications.emptyBody'),
            );
          }
          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              final n = notifications[i];
              return GlassCard(
                tone: GlassTone.light,
                blur: AppBlur.medium,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadius.xl),
                ),
                // Unread mail carries a faint cyan wash; read mail rests.
                glow: n.isRead ? null : AppColors.primary,
                onTap: () async {
                  if (!n.isRead) {
                    await ref
                        .read(notificationsRepositoryProvider)
                        .markAsRead(n.id);
                    ref.invalidate(myNotificationsProvider);
                  }
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: brand.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_iconFor(n.type), color: brand, size: 18),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  n.title,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ),
                              if (!n.isRead)
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.error,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            n.body,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _relativeTime(l10n, n.createdAt),
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
