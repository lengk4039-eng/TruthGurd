import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/widgets/app_back_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/avatar_initials.dart';
import '../../../core/widgets/primary_button.dart';
import '../../auth/providers/auth_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();
  late final TextEditingController _fullName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _nationalId;
  Uint8List? _avatarBytes;
  String? _avatarFilename;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authStateProvider);
    _fullName = TextEditingController(text: user?.fullName);
    _email = TextEditingController(text: user?.email);
    _phone = TextEditingController(text: user?.phone);
    _nationalId = TextEditingController(text: user?.nationalIdNumber);
  }

  @override
  void dispose() {
    _fullName.dispose();
    _email.dispose();
    _phone.dispose();
    _nationalId.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickPhoto() async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        imageQuality: 85,
      );
      if (picked == null) return;
      final bytes = await picked.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        if (mounted) _showMessage(context.l10n.tr('editProfile.photoTooLarge'));
        return;
      }
      if (!mounted) return;
      setState(() {
        _avatarBytes = bytes;
        _avatarFilename = picked.name.isEmpty ? 'avatar.jpg' : picked.name;
      });
    } catch (_) {
      if (mounted) _showMessage(context.l10n.tr('editProfile.photoError'));
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final notifier = ref.read(authStateProvider.notifier);
      await notifier.updateProfile(
        fullName: _fullName.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        nationalIdNumber: _nationalId.text.trim(),
      );
      if (_avatarBytes != null) {
        await notifier.uploadAvatar(
          bytes: _avatarBytes!,
          filename: _avatarFilename ?? 'avatar.jpg',
        );
      }
      if (!mounted) return;
      context.pop();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.tr('editProfile.updated'))),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      _showMessage(
        e is AppException ? e.message : l10n.tr('editProfile.saveError'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final l10n = context.l10n;
    final muted = Theme.of(context).textTheme.bodySmall?.color;

    return Scaffold(
      appBar: AppBar(
        leading: const AppBackButton(),
        title: Text(l10n.tr('editProfile.title')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _isSaving ? null : _pickPhoto,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            AvatarInitials(
                              initials: user?.initials ?? '?',
                              size: 96,
                              imageUrl: user?.avatarUrl,
                              imageBytes: _avatarBytes,
                            ),
                            Positioned(
                              right: -2,
                              bottom: -2,
                              child: Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: AppColors.brandInk,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .scaffoldBackgroundColor,
                                    width: 2,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.camera_alt_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      TextButton.icon(
                        onPressed: _isSaving ? null : _pickPhoto,
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          size: 18,
                        ),
                        label: Text(
                          l10n.tr(
                            _avatarBytes == null
                                ? 'editProfile.uploadPhoto'
                                : 'editProfile.changePhoto',
                          ),
                        ),
                      ),
                      Text(
                        l10n.tr('editProfile.photoHint'),
                        style: TextStyle(color: muted, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.tr('editProfile.personal'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  label: l10n.tr('editProfile.fullName'),
                  controller: _fullName,
                  prefixIcon: Icons.person_outline_rounded,
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
                  validator: (v) => (v == null || v.trim().length < 7)
                      ? l10n.tr('editProfile.phoneError')
                      : null,
                ),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  l10n.tr('editProfile.identity'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                AppTextField(
                  label: l10n.tr('editProfile.nationalId'),
                  hint: l10n.tr('editProfile.nationalIdHint'),
                  helperText: l10n.tr('editProfile.nationalIdHelper'),
                  controller: _nationalId,
                  prefixIcon: Icons.badge_outlined,
                  validator: (v) {
                    final id = v?.trim() ?? '';
                    if (id.isEmpty) {
                      return l10n.tr('editProfile.nationalIdError');
                    }
                    if (!RegExp(r'^[A-Za-z0-9-]{6,20}$').hasMatch(id)) {
                      return l10n.tr('editProfile.nationalIdFormat');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.07),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.verified_user_outlined,
                        size: 18,
                        color: AppColors.brandInk,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          l10n.tr('editProfile.idNotice'),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: muted, height: 1.45),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                  label: l10n.tr('editProfile.save'),
                  isLoading: _isSaving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
