import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/avatar_initials.dart';
import '../../auth/providers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text("You'll need to log in again to see your policies and payments."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Log out')),
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

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Row(
              children: [
                AvatarInitials(initials: user?.initials ?? '?', size: 64),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user?.fullName ?? '', style: Theme.of(context).textTheme.headlineSmall),
                      Text(user?.email ?? '', style: Theme.of(context).textTheme.bodyMedium),
                      const SizedBox(height: 6),
                      if (user?.kycVerified == true)
                        Row(
                          children: [
                            const Icon(Icons.verified_rounded, size: 15, color: AppColors.success),
                            const SizedBox(width: 4),
                            const Text('Identity verified', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (user != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text('Member since ${AppFormatters.monthYear(user.memberSince)}', style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: AppSpacing.xl),
            _MenuSection(
              children: [
                _MenuTile(icon: Icons.person_outline_rounded, label: 'Edit profile', onTap: () => context.push('/profile/edit')),
                _MenuTile(icon: Icons.request_quote_outlined, label: 'My quotations', onTap: () => context.push('/quotations')),
                _MenuTile(icon: Icons.assignment_outlined, label: 'My claims', onTap: () => context.push('/claims')),
                _MenuTile(icon: Icons.badge_outlined, label: 'Link an existing policy', onTap: () => context.push('/link-policy')),
                _MenuTile(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () => context.push('/notifications')),
                _MenuTile(icon: Icons.settings_outlined, label: 'Settings', onTap: () => context.push('/profile/settings')),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            _MenuSection(
              children: [
                _MenuTile(
                  icon: Icons.support_agent_rounded,
                  label: 'Help & support',
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Help & support'),
                      content: const Text(
                        'Our support team is available 24/7.\n\nPhone: +855 87 908 470\nEmail: Insurancehelpcenter12@gmail.com',
                      ),
                      actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Got it'))],
                    ),
                  ),
                ),
                _MenuTile(icon: Icons.logout_rounded, label: 'Log out', danger: true, onTap: () => _confirmLogout(context, ref)),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(child: Text('TrustGuard Insurance · v1.0.0', style: Theme.of(context).textTheme.bodySmall)),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<Widget> children;
  const _MenuSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const Divider(height: 1, indent: 56),
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

  const _MenuTile({required this.icon, required this.label, required this.onTap, this.danger = false});

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.error : null;
    return ListTile(
      leading: Icon(icon, color: color ?? AppColors.primary, size: 22),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
    );
  }
}
