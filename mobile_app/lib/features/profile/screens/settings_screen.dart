import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/locale_controller.dart';
import '../../../core/providers/theme_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_back_button.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _paymentReminders = true;
  bool _policyUpdates = true;
  bool _promotions = false;

  Future<void> _setLanguage(AppLanguage language) async {
    await ref.read(localeControllerProvider.notifier).setLanguage(language);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          language == AppLanguage.khmer
              ? 'បានផ្លាស់ប្តូរភាសាកម្មវិធី។'
              : 'App language changed.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final themeMode = ref.watch(themeModeProvider);
    final language = ref.watch(localeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.tr('settings.title')),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            _SectionLabel(l10n.tr('settings.language')),
            Card(
              child: Column(
                children: [
                  _LanguageOption(
                    code: 'EN',
                    label: l10n.tr('settings.english'),
                    selected: language == AppLanguage.english,
                    onTap: () => _setLanguage(AppLanguage.english),
                  ),
                  const Divider(height: 1, indent: 16),
                  _LanguageOption(
                    code: 'KH',
                    label: l10n.tr('settings.khmer'),
                    selected: language == AppLanguage.khmer,
                    onTap: () => _setLanguage(AppLanguage.khmer),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: Row(
                      children: [
                        Icon(
                          Icons.translate_rounded,
                          size: 15,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            l10n.tr('settings.languageSubtitle'),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionLabel(l10n.tr('settings.appearance')),
            Card(
              child: Column(
                children: [
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    onChanged: (v) =>
                        ref.read(themeModeProvider.notifier).useSystemDefault(),
                    title: Text(l10n.tr('settings.systemDefault')),
                    activeColor: AppColors.primary,
                  ),
                  const Divider(height: 1, indent: 16),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    onChanged: (v) =>
                        ref.read(themeModeProvider.notifier).setDarkMode(false),
                    title: Text(l10n.tr('settings.light')),
                    activeColor: AppColors.primary,
                  ),
                  const Divider(height: 1, indent: 16),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    onChanged: (v) =>
                        ref.read(themeModeProvider.notifier).setDarkMode(true),
                    title: Text(l10n.tr('settings.dark')),
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionLabel(l10n.tr('settings.notifications')),
            Card(
              child: Column(
                children: [
                  SwitchListTile(
                    value: _paymentReminders,
                    onChanged: (v) => setState(() => _paymentReminders = v),
                    title: Text(l10n.tr('settings.paymentReminders')),
                    subtitle: Text(
                      l10n.tr('settings.paymentRemindersSubtitle'),
                    ),
                    activeThumbColor: AppColors.primary,
                  ),
                  const Divider(height: 1, indent: 16),
                  SwitchListTile(
                    value: _policyUpdates,
                    onChanged: (v) => setState(() => _policyUpdates = v),
                    title: Text(l10n.tr('settings.policyUpdates')),
                    subtitle: Text(l10n.tr('settings.policyUpdatesSubtitle')),
                    activeThumbColor: AppColors.primary,
                  ),
                  const Divider(height: 1, indent: 16),
                  SwitchListTile(
                    value: _promotions,
                    onChanged: (v) => setState(() => _promotions = v),
                    title: Text(l10n.tr('settings.promotions')),
                    subtitle: Text(l10n.tr('settings.promotionsSubtitle')),
                    activeThumbColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionLabel(l10n.tr('settings.account')),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(
                      Icons.lock_reset_rounded,
                      color: AppColors.brandInk,
                    ),
                    title: Text(l10n.tr('settings.changePassword')),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.tr('settings.resetSent'))),
                    ),
                  ),
                  const Divider(height: 1, indent: 16),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_outline_rounded,
                      color: AppColors.error,
                    ),
                    title: Text(
                      l10n.tr('settings.deleteAccount'),
                      style: const TextStyle(color: AppColors.error),
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l10n.tr('settings.deleteTitle')),
                        content: Text(l10n.tr('settings.deleteBody')),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.tr('common.cancel')),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.error,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: Text(l10n.tr('settings.delete')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String code;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.code,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                code,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.primary,
                  fontSize: code.length > 2 ? 13 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(label, style: Theme.of(context).textTheme.titleSmall),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected
                  ? AppColors.primary
                  : Theme.of(context).disabledColor,
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
