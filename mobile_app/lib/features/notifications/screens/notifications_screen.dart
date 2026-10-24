import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/app_notification.dart';
import '../../../core/providers/data_providers.dart';
import '../../../core/providers/repository_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../../core/widgets/empty_state.dart';

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

  String _relativeTime(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notificationsAsync = ref.watch(myNotificationsProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Notifications'),
      ),
      body: AsyncValueView(
        value: notificationsAsync,
        onRetry: () => ref.invalidate(myNotificationsProvider),
        builder: (notifications) {
          if (notifications.isEmpty) {
            return const EmptyState(icon: Icons.notifications_none_rounded, title: 'No notifications', message: "You're all caught up.");
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, i) {
              final n = notifications[i];
              return InkWell(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                onTap: () async {
                  if (!n.isRead) {
                    await ref.read(notificationsRepositoryProvider).markAsRead(n.id);
                    ref.invalidate(myNotificationsProvider);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: n.isRead ? Theme.of(context).cardColor : AppColors.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), shape: BoxShape.circle),
                        child: Icon(_iconFor(n.type), color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text(n.title, style: Theme.of(context).textTheme.titleSmall)),
                                if (!n.isRead) Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.error, shape: BoxShape.circle)),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(n.body, style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 6),
                            Text(_relativeTime(n.createdAt), style: Theme.of(context).textTheme.labelMedium),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
