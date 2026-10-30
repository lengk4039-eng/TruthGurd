import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/app_user.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/avatar_initials.dart';
import '../../../core/widgets/glass/glass_card.dart';
import '../../../core/widgets/glass/glass_page_header.dart';
import '../../auth/providers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.tr('profile.logoutTitle')),
        content: Text(context.l10n.tr('profile.logoutBody')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.tr('common.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.tr('profile.logout')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateProvider);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.lg,
            108,
          ),
          children: [
            GlassPageHeader(title: l10n.tr('profile.title')),
            _IdentityCard(user: user),
            const SizedBox(height: AppSpacing.lg),
            _MenuSection(
              children: [
                _MenuTile(
                  icon: Icons.person_outline_rounded,
                  label: l10n.tr('profile.editProfile'),
                  onTap: () => context.push('/profile/edit'),
                ),
                _MenuTile(
                  icon: Icons.request_quote_outlined,
                  label: l10n.tr('profile.quotations'),
                  onTap: () => context.push('/quotations'),
                ),
                _MenuTile(
                  icon: Icons.assignment_outlined,
                  label: l10n.tr('profile.claims'),
                  onTap: () => context.push('/claims'),
                ),
                _MenuTile(
                  icon: Icons.badge_outlined,
                  label: l10n.tr('profile.linkPolicy'),
                  onTap: () => context.push('/link-policy'),
                ),
                _MenuTile(
                  icon: Icons.notifications_outlined,
                  label: l10n.tr('profile.notifications'),
                  onTap: () => context.push('/notifications'),
                ),
                _MenuTile(
                  icon: Icons.settings_outlined,
                  label: l10n.tr('profile.settings'),
                  onTap: () => context.push('/profile/settings'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _MenuSection(
              children: [
                _MenuTile(
                  icon: Icons.support_agent_rounded,
                  label: l10n.tr('profile.help'),
                  onTap: () => showDialog(
                    context: context,
                    builder: (dialogContext) => AlertDialog(
                      title: Text(l10n.tr('profile.help')),
                      content: Text(l10n.tr('profile.helpBody')),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext),
                          child: Text(l10n.tr('common.gotIt')),
                        ),
                      ],
                    ),
                  ),
                ),
                _MenuTile(
                  icon: Icons.logout_rounded,
                  label: l10n.tr('profile.logout'),
                  danger: true,
                  onTap: () => _confirmLogout(context, ref),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Text(
                'TrustGuard Insurance · v1.0.0',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  final AppUser? user;
  const _IdentityCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final muted = GlassInk.muted(context, GlassTone.light);
    final verified = user?.kycVerified == true;
    final memberSince = user?.memberSince;
    return GlassCard(
      tone: GlassTone.light,
      blur: AppBlur.medium,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.hero)),
      lift: 2,
      child: Row(
        children: [
          AvatarInitials(
            initials: user?.initials ?? '?',
            size: 64,
            imageUrl: user?.avatarUrl,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? '',
                  style: Theme.of(context).textTheme.titleLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  user?.email ?? '',
                  style: TextStyle(color: muted, fontSize: 12.5),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (memberSince != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    l10n.tr('profile.memberSince', {
                      'date': l10n.formatMonthYear(memberSince),
                    }),
                    style: TextStyle(color: muted, fontSize: 11.5),
                  ),
                ],
                if (verified) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        size: 15,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.tr('profile.identityVerified'),
                        style: const TextStyle(
                          color: AppColors.success,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<Widget> children;
  const _MenuSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      tone: GlassTone.light,
      blur: AppBlur.medium,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadius.xl)),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1)
              Divider(
                height: 1,
                indent: 40,
                color: GlassInk.muted(
                  context,
                  GlassTone.light,
                ).withValues(alpha: 0.14),
              ),
          ],
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;

  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final onDark = GlassInk.surfaceIsDark(context, GlassTone.light);
    final color = danger
        ? AppColors.legibleHue(AppColors.error, onDark: onDark)
        : AppColors.brandOn(onDark: onDark);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: AppSpacing.sm + 4),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: danger ? color : null,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: GlassInk.muted(context, GlassTone.light),
            ),
          ],
        ),
      ),
    );
  }
}
