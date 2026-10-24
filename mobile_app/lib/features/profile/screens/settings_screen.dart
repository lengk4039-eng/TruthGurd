import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/theme_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/theme/app_dimens.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _paymentReminders = true;
  bool _policyUpdates = true;
  bool _promotions = false;

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: const Text('Settings'),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _SectionLabel('Appearance'),
            Card(
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    onChanged: (v) => ref.read(themeModeProvider.notifier).useSystemDefault(),
                    title: const Text('Use system default'),
                    activeColor: AppColors.primary,
                  ),
                  const Divider(height: 1, indent: 16),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    onChanged: (v) => ref.read(themeModeProvider.notifier).setDarkMode(false),
                    title: const Text('Light'),
                    activeColor: AppColors.primary,
                  ),
                  const Divider(height: 1, indent: 16),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    onChanged: (v) => ref.read(themeModeProvider.notifier).setDarkMode(true),
                    title: const Text('Dark'),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionLabel('Notification preferences'),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    value: _paymentReminders,
                    onChanged: (v) => setState(() => _paymentReminders = v),
                    title: const Text('Payment reminders'),
                    subtitle: const Text('Get notified before a payment is due'),
                    activeThumbColor: AppColors.primary,
                  ),
                  const Divider(height: 1, indent: 16),
                  SwitchListTile(
                    value: _policyUpdates,
                    onChanged: (v) => setState(() => _policyUpdates = v),
                    title: const Text('Policy updates'),
                    subtitle: const Text('Renewals, expirations, and coverage changes'),
                    activeThumbColor: AppColors.primary,
                  ),
                  const Divider(height: 1, indent: 16),
                  SwitchListTile(
                    value: _promotions,
                    onChanged: (v) => setState(() => _promotions = v),
                    title: const Text('Promotions'),
                    subtitle: const Text('New packages and limited-time offers'),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionLabel('Account'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_reset_rounded, color: AppColors.primary),
                    title: const Text('Change password'),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("We've sent a password reset link to your email.")),
                    ),
                  ),
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    leading: const Icon(Icons.delete_outline_rounded, color: AppColors.error),
                    title: const Text('Delete account', style: TextStyle(color: AppColors.error)),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete account?'),
                        content: const Text('This permanently removes your account, policies, and payment history. This cannot be undone.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          FilledButton(
                            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.sm),
      child: Text(label, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}
