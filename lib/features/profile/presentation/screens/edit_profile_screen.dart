import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../../../../core/widgets/profile_avatar.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key, required this.profile});

  final Profile profile;

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.profile.name);
    _emailCtrl = TextEditingController(text: widget.profile.email);
    _phoneCtrl = TextEditingController(text: widget.profile.displayPhone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool get _hasChanges =>
      _nameCtrl.text.trim() != widget.profile.name ||
      _emailCtrl.text.trim() != widget.profile.email ||
      _phoneCtrl.text.trim() != widget.profile.displayPhone;

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      await getIt<UpdateProfileUseCase>()(
        _nameCtrl.text.trim(),
        _phoneCtrl.text.trim().replaceAll(RegExp(r'[^\d]'), ''),
        _emailCtrl.text.trim(),
      );

      if (!mounted) return;

      AppSnackbar.show(
        context,
        message: AppStrings.profileUpdated,
        emoji: '',
        backgroundColor: AppColors.navy,
      );
      context.read<ProfileCubit>().loadProfile();
      context.pop();
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: e is AuthException
            ? e.message
            : 'Failed to update profile. Please try again.',
        type: AppSnackbarType.error,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _showImageSourceSheet() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              title: const Text(AppStrings.takePhoto),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              title: const Text(AppStrings.chooseFromGallery),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
            ListTile(
              title: Text(
                AppStrings.cancel,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              onTap: () => Navigator.of(sheetContext).pop(),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );

    if (source == null) return;
    await _pickAndUploadAvatar(source);
  }

  Future<void> _pickAndUploadAvatar(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    final cubit = context.read<ProfileCubit>();
    await cubit.uploadAvatar(File(picked.path));
    if (!mounted) return;

    final error = cubit.state.error;
    if (error != null) {
      AppSnackbar.show(context, message: error, type: AppSnackbarType.error);
    } else {
      AppSnackbar.show(
        context,
        message: AppStrings.profilePhotoUpdated,
        emoji: '',
        backgroundColor: AppColors.navy,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      buildWhen: (previous, current) =>
          previous.userProfile?.avatarUrl != current.userProfile?.avatarUrl ||
          previous.isUploadingAvatar != current.isUploadingAvatar,
      builder: (context, profileState) {
        final currentProfile = profileState.userProfile ?? widget.profile;
        final isUploadingAvatar = profileState.isUploadingAvatar;

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // ── App bar ──────────────────────────────────────────────────
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _isSubmitting ? null : () => context.pop(),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.background,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 16,
                            color: AppColors.navyDark,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            AppStrings.editProfile,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 36),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ── Avatar ───────────────────────────────────────────────────
                  Center(
                    child: GestureDetector(
                      onTap: isUploadingAvatar ? null : _showImageSourceSheet,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          ProfileAvatar(
                            initials: currentProfile.initials,
                            avatarUrl: currentProfile.avatarUrl,
                          ),
                          if (isUploadingAvatar)
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: const BoxDecoration(
                                  color: Colors.black38,
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Semantics(
                                    label: AppStrings.uploadingPhoto,
                                    child: const SizedBox(
                                      width: 28,
                                      height: 28,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: AppColors.navy,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Text(
                                '📷',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── Full name ────────────────────────────────────────────────
                  _FieldLabel(AppStrings.labelFullName),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _nameCtrl,
                    hint: AppStrings.hintFullName,
                    textInputAction: TextInputAction.next,
                    enabled: !_isSubmitting,
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 20),

                  // ── Email ────────────────────────────────────────────────────
                  _FieldLabel(AppStrings.labelEmail),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _emailCtrl,
                    hint: AppStrings.hintEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !_isSubmitting,
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 20),

                  // ── Phone ────────────────────────────────────────────────────
                  _FieldLabel(AppStrings.labelPhone),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _phoneCtrl,
                    hint: AppStrings.hintPhone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.done,
                    enabled: !_isSubmitting,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) =>
                        _hasChanges && !_isSubmitting ? _submit() : null,
                  ),

                  const SizedBox(height: 36),

                  AppButton(
                    label: AppStrings.saveChanges,
                    isLoading: _isSubmitting,
                    backgroundColor: AppColors.navy,
                    onPressed: _hasChanges && !_isSubmitting ? _submit : null,
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textLabel,
        letterSpacing: 0.8,
      ),
    );
  }
}
