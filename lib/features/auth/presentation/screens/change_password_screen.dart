import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String? _currentError;
  String? _newError;
  String? _confirmError;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _passwordsMismatch =>
      _newCtrl.text.isNotEmpty &&
      _confirmCtrl.text.isNotEmpty &&
      _newCtrl.text != _confirmCtrl.text;

  bool get _newTooShort =>
      _newCtrl.text.isNotEmpty && _newCtrl.text.length < 6;

  bool get _sameAsCurrent =>
      _currentCtrl.text.isNotEmpty &&
      _newCtrl.text.isNotEmpty &&
      _currentCtrl.text == _newCtrl.text;

  bool get _canSubmit =>
      _currentCtrl.text.isNotEmpty &&
      _newCtrl.text.length >= 6 &&
      _newCtrl.text == _confirmCtrl.text &&
      _currentCtrl.text != _newCtrl.text;

  void _submit(BuildContext blocCtx) {
    // Inline validation pass before dispatch
    String? curErr;
    String? newErr;
    String? confErr;

    if (_currentCtrl.text.isEmpty) curErr = AppStrings.errorFieldRequired;
    if (_newCtrl.text.isEmpty) {
      newErr = AppStrings.errorFieldRequired;
    } else if (_newCtrl.text.length < 6) {
      newErr = AppStrings.errorPasswordMin;
    } else if (_currentCtrl.text == _newCtrl.text) {
      newErr = AppStrings.newPasswordSameAsCurrent;
    }
    if (_confirmCtrl.text.isEmpty) {
      confErr = AppStrings.errorFieldRequired;
    } else if (_newCtrl.text != _confirmCtrl.text) {
      confErr = AppStrings.errorPasswordsMismatch;
    }

    if (curErr != null || newErr != null || confErr != null) {
      setState(() {
        _currentError = curErr;
        _newError = newErr;
        _confirmError = confErr;
      });
      return;
    }

    blocCtx.read<AuthBloc>().add(ChangePasswordSubmitted(
          currentPassword: _currentCtrl.text,
          newPassword: _newCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (_, s) =>
          s is AuthLoading || s is ChangePasswordSuccess || s is AuthFailure,
      listener: (ctx, state) {
        if (state is AuthLoading) {
          AppSnackbar.show(
            ctx,
            message: AppStrings.processing,
            emoji: '🔒',
            type: AppSnackbarType.loading,
            persistent: true,
          );
        } else if (state is ChangePasswordSuccess) {
          AppSnackbar.dismiss();
          AppSnackbar.show(
            ctx,
            message: AppStrings.passwordUpdatedSuccessfully,
            emoji: '✅',
            type: AppSnackbarType.success,
          );
          ctx.pop();
        } else if (state is AuthFailure) {
          AppSnackbar.dismiss();
          if (state.message == AppStrings.sessionExpiredLogin) {
            AppSnackbar.show(
              ctx,
              message: state.message,
              type: AppSnackbarType.error,
            );
            ctx.go(RouteNames.home);
          } else {
            AppSnackbar.show(
              ctx,
              message: state.message,
              type: AppSnackbarType.error,
            );
          }
        }
      },
      builder: (ctx, state) {
        final isLoading = state is AuthLoading;

        return Scaffold(
          backgroundColor: AppColors.surface,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // ── Back + title ─────────────────────────────────────────
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: AppColors.navy,
                          size: 20,
                        ),
                        onPressed: isLoading ? null : () => ctx.pop(),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        AppStrings.changePassword,
                        style: AppTextStyles.h2.copyWith(color: AppColors.navy),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // ── Lock icon ────────────────────────────────────────────
                  const Center(
                    child: Text('🔒', style: TextStyle(fontSize: 48)),
                  ),

                  const SizedBox(height: 32),

                  // ── Current password ─────────────────────────────────────
                  _FieldLabel(AppStrings.labelCurrentPassword),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _currentCtrl,
                    hint: AppStrings.hintCurrentPassword,
                    obscureText: _obscureCurrent,
                    textInputAction: TextInputAction.next,
                    errorText: _currentError,
                    enabled: !isLoading,
                    onChanged: (_) {
                      setState(() => _currentError = null);
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrent
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureCurrent = !_obscureCurrent),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── New password ─────────────────────────────────────────
                  _FieldLabel(AppStrings.labelNewPassword),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _newCtrl,
                    hint: AppStrings.hintNewPasswordMin,
                    obscureText: _obscureNew,
                    textInputAction: TextInputAction.next,
                    errorText: _newError ??
                        (_newTooShort
                            ? AppStrings.errorPasswordMin
                            : _sameAsCurrent
                                ? AppStrings.newPasswordSameAsCurrent
                                : null),
                    enabled: !isLoading,
                    onChanged: (_) {
                      setState(() => _newError = null);
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNew
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureNew = !_obscureNew),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Confirm new password ─────────────────────────────────
                  _FieldLabel(AppStrings.labelConfirmNewPassword),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _confirmCtrl,
                    hint: AppStrings.hintConfirmNewPassword,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    errorText: _confirmError ??
                        (_passwordsMismatch
                            ? AppStrings.errorPasswordsMismatch
                            : null),
                    enabled: !isLoading,
                    onChanged: (_) {
                      setState(() => _confirmError = null);
                    },
                    onSubmitted: (_) => _canSubmit ? _submit(ctx) : null,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // ── Update button ────────────────────────────────────────
                  AppButton(
                    label: AppStrings.updatePassword,
                    isLoading: isLoading,
                    onPressed: _canSubmit && !isLoading ? () => _submit(ctx) : null,
                    backgroundColor: AppColors.navy,
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
