import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/policy_verification.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/utils/minimum_age.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/primary_button.dart';
import '../providers/auth_controller.dart';

enum _RegisterPath { newCustomer, hasExistingPolicy }

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _policyNumber = TextEditingController();
  final _policyDob = TextEditingController();
  final _dateOfBirth = TextEditingController();
  _RegisterPath _path = _RegisterPath.newCustomer;
  bool _isSubmitting = false;
  String? _error;
  PolicyVerification? _verification;
  bool _isVerifying = false;
  String? _verifyError;

  bool get _requiresVerification => _path == _RegisterPath.hasExistingPolicy;

  @override
  void initState() {
    super.initState();
    // Editing either input invalidates a prior match: the token is bound to
    // the exact policy that was checked, not to whatever is typed now.
    _policyNumber.addListener(_invalidateVerification);
    _policyDob.addListener(_invalidateVerification);
  }

  void _invalidateVerification() {
    if (_verification != null) setState(() => _verification = null);
  }

  @override
  void dispose() {
    _policyNumber.removeListener(_invalidateVerification);
    _policyDob.removeListener(_invalidateVerification);
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _policyNumber.dispose();
    _policyDob.dispose();
    _dateOfBirth.dispose();
    super.dispose();
  }

  /// The policyholder's own birthday, which has to prove they are 18. Kept
  /// separate from [_policyDob]: that one is a secret that must match the
  /// insurer's record, this one is a fact about the person signing up.
  Future<void> _pickDateOfBirth() async {
    final entered = DateTime.tryParse(_dateOfBirth.text.trim());
    final picked = await showDatePicker(
      context: context,
      initialDate: entered ?? DateTime(DateTime.now().year - 25, 6, 15),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _dateOfBirth.text = _formatIsoDate(picked));
  }

  String? _validateDateOfBirth(String? value) {
    final l10n = context.l10n;
    final raw = value?.trim() ?? '';
    if (raw.isEmpty || DateTime.tryParse(raw) == null) {
      return l10n.tr('register.dobError');
    }
    if (!meetsMinimumAge(DateTime.parse(raw))) {
      return l10n.tr('register.dobTooYoung');
    }
    return null;
  }

  Future<void> _pickDob() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() => _policyDob.text = _formatIsoDate(picked));
  }

  static String _formatIsoDate(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';

  Future<void> _verifyPolicy() async {
    final l10n = context.l10n;
    if (_policyNumber.text.trim().isEmpty) {
      setState(() => _verifyError = l10n.tr('linkPolicy.policyNumberError'));
      return;
    }
    if (_policyDob.text.trim().isEmpty) {
      setState(() => _verifyError = l10n.tr('linkPolicy.dobError'));
      return;
    }
    setState(() {
      _isVerifying = true;
      _verifyError = null;
      _verification = null;
    });
    try {
      final result = await ref
          .read(authStateProvider.notifier)
          .verifyPolicy(
            policyNumber: _policyNumber.text.trim(),
            dateOfBirth: _policyDob.text.trim(),
          );
      if (!mounted) return;
      setState(() => _verification = result);
    } catch (e) {
      if (!mounted) return;
      setState(
        () => _verifyError = e.toString().replaceFirst('AppException: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _submit() async {
    final l10n = context.l10n;
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_requiresVerification && _verification == null) {
      setState(() => _error = l10n.tr('register.verifyFirstError'));
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    try {
      await ref
          .read(authStateProvider.notifier)
          .register(
            fullName: _fullName.text.trim(),
            email: _email.text.trim(),
            phone: _phone.text.trim(),
            dateOfBirth: DateTime.parse(_dateOfBirth.text.trim()),
            password: _password.text,
            hasExistingPolicy: _requiresVerification,
            policyVerificationToken: _verification?.verificationToken,
          );
      if (!mounted) return;
      context.go(ref.read(pendingAuthRouteProvider.notifier).take() ?? '/home');
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('AppException: ', ''));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(leading: const AppBackButton()),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.tr('register.title'),
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.tr('register.subtitle'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                SegmentedButton<_RegisterPath>(
                  segments: [
                    ButtonSegment(
                      value: _RegisterPath.newCustomer,
                      label: Text(l10n.tr('register.newCustomer')),
                      icon: const Icon(Icons.person_add_alt_rounded, size: 16),
                    ),
                    ButtonSegment(
                      value: _RegisterPath.hasExistingPolicy,
                      label: Text(l10n.tr('register.hasPolicy')),
                      icon: const Icon(Icons.badge_outlined, size: 16),
                    ),
                  ],
                  selected: {_path},
                  onSelectionChanged: (s) => setState(() {
                    _path = s.first;
                    _error = null;
                  }),
                  style: SegmentedButton.styleFrom(
                    selectedBackgroundColor: AppColors.primary,
                    selectedForegroundColor: Colors.white,
                  ),
                ),
                if (_requiresVerification) ...[
                  const SizedBox(height: AppSpacing.md),
                  _PolicyVerificationCard(
                    policyNumber: _policyNumber,
                    dob: _policyDob,
                    verification: _verification,
                    error: _verifyError,
                    isVerifying: _isVerifying,
                    onVerify: _verifyPolicy,
                    onPickDob: _pickDob,
                    onChange: () => setState(() => _verification = null),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                AppTextField(
                  label: l10n.tr('editProfile.fullName'),
                  controller: _fullName,
                  prefixIcon: Icons.person_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().length < 2)
                      ? l10n.tr('editProfile.nameError')
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l10n.tr('editProfile.email'),
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.mail_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || !v.contains('@'))
                      ? l10n.tr('editProfile.emailError')
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l10n.tr('editProfile.phone'),
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.trim().length < 7)
                      ? l10n.tr('editProfile.phoneError')
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l10n.tr('register.dob'),
                  controller: _dateOfBirth,
                  hint: l10n.tr('register.dobHint'),
                  helperText: l10n.tr('register.dobHelper'),
                  prefixIcon: Icons.cake_outlined,
                  readOnly: true,
                  onTap: _pickDateOfBirth,
                  validator: _validateDateOfBirth,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l10n.tr('register.password'),
                  controller: _password,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.next,
                  validator: (v) => (v == null || v.length < 6)
                      ? l10n.tr('login.passwordMin')
                      : null,
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  label: l10n.tr('register.confirmPassword'),
                  controller: _confirmPassword,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _submit(),
                  validator: (v) => v != _password.text
                      ? l10n.tr('register.passwordMismatch')
                      : null,
                ),
                if (_error != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                PrimaryButton(
                  label: l10n.tr('register.createAccount'),
                  isLoading: _isSubmitting,
                  onPressed: _requiresVerification && _verification == null
                      ? null
                      : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PolicyVerificationCard extends StatelessWidget {
  final TextEditingController policyNumber;
  final TextEditingController dob;
  final PolicyVerification? verification;
  final String? error;
  final bool isVerifying;
  final VoidCallback onVerify;
  final VoidCallback onPickDob;
  final VoidCallback onChange;

  const _PolicyVerificationCard({
    required this.policyNumber,
    required this.dob,
    required this.verification,
    required this.error,
    required this.isVerifying,
    required this.onVerify,
    required this.onPickDob,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: verification != null
              ? AppColors.success
              : Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.tr('register.verifyTitle'),
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.tr('register.verifyBody'),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          if (verification != null)
            _VerifiedSummary(verification: verification!, onChange: onChange)
          else ...[
            AppTextField(
              label: l10n.tr('linkPolicy.policyNumber'),
              controller: policyNumber,
              prefixIcon: Icons.confirmation_number_outlined,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.md),
            AppTextField(
              label: l10n.tr('linkPolicy.dob'),
              controller: dob,
              hint: l10n.tr('linkPolicy.dobHint'),
              prefixIcon: Icons.cake_outlined,
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: onPickDob,
              icon: const Icon(Icons.event_outlined, size: 18),
              label: Text(l10n.tr('linkPolicy.chooseDate')),
            ),
            if (error != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                error!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: isVerifying ? null : onVerify,
              icon: isVerifying
                  ? const SizedBox(
                      height: 16,
                      width: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.verified_outlined, size: 18),
              label: Text(l10n.tr('linkPolicy.verify')),
            ),
          ],
        ],
      ),
    );
  }
}

class _VerifiedSummary extends StatelessWidget {
  final PolicyVerification verification;
  final VoidCallback onChange;

  const _VerifiedSummary({required this.verification, required this.onChange});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        const Icon(Icons.verified_rounded, color: AppColors.success),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text(
            l10n.tr('register.verified', {
              'policy': verification.policyNumber,
              'package': verification.packageName,
            }),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        TextButton(
          onPressed: onChange,
          child: Text(l10n.tr('register.change')),
        ),
      ],
    );
  }
}
