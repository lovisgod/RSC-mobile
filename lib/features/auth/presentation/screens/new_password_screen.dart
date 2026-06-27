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

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({
    super.key,
    required this.identifier,
    required this.otpCode,
  });

  final String identifier;
  final String otpCode;

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool get _passwordTooShort =>
      _passwordCtrl.text.isNotEmpty && _passwordCtrl.text.length < 6;

  bool get _passwordsMismatch =>
      _confirmCtrl.text.isNotEmpty &&
      _passwordCtrl.text != _confirmCtrl.text;

  bool get _canSubmit =>
      _passwordCtrl.text.length >= 6 &&
      _confirmCtrl.text.isNotEmpty &&
      _passwordCtrl.text == _confirmCtrl.text;

  void _submit(BuildContext context) {
    context.read<AuthBloc>().add(ResetPasswordSubmitted(
          identifier: widget.identifier,
          otpCode: widget.otpCode,
          newPassword: _passwordCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (_, current) =>
          current is AuthLoading ||
          current is ResetPasswordSuccess ||
          current is AuthFailure,
      listener: (context, state) {
        if (state is ResetPasswordSuccess) {
          AppSnackbar.dismiss();
          AppSnackbar.show(
            context,
            message: AppStrings.passwordResetSuccess,
            type: AppSnackbarType.success,
          );
          context.go(RouteNames.home);
        } else if (state is AuthLoading) {
          AppSnackbar.show(
            context,
            message: AppStrings.processing,
            emoji: '🔐',
            type: AppSnackbarType.loading,
            persistent: true,
          );
        } else if (state is AuthFailure) {
          AppSnackbar.dismiss();
          AppSnackbar.show(
            context,
            message: state.message,
            type: AppSnackbarType.error,
          );
        }
      },
      builder: (context, state) {
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

                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.navy,
                        size: 20,
                      ),
                      onPressed: isLoading ? null : () => context.pop(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  const _AuthLogo(),
                  const SizedBox(height: 24),

                  Text(
                    AppStrings.setNewPassword,
                    style: AppTextStyles.h2.copyWith(color: AppColors.navy),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.newPasswordSubtitle,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  const _FieldLabel(AppStrings.labelNewPassword),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _passwordCtrl,
                    hint: AppStrings.hintNewPassword,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    onChanged: (_) => setState(() {}),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  if (_passwordTooShort) ...[
                    const SizedBox(height: 4),
                    const Text(
                      AppStrings.errorPasswordMin,
                      style: TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                  ],

                  const SizedBox(height: 20),

                  const _FieldLabel(AppStrings.labelConfirmPassword),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _confirmCtrl,
                    hint: AppStrings.hintConfirmNewPassword,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    enabled: !isLoading,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) {
                      if (_canSubmit) _submit(context);
                    },
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
                  if (_passwordsMismatch) ...[
                    const SizedBox(height: 4),
                    const Text(
                      AppStrings.errorPasswordsMismatch,
                      style: TextStyle(fontSize: 12, color: AppColors.error),
                    ),
                  ],

                  const SizedBox(height: 32),

                  AppButton(
                    label: AppStrings.resetPassword,
                    isLoading: isLoading,
                    backgroundColor: AppColors.navy,
                    onPressed: _canSubmit && !isLoading
                        ? () => _submit(context)
                        : null,
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _AuthLogo extends StatelessWidget {
  const _AuthLogo();

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: const TextSpan(
        children: [
          TextSpan(
            text: 'RSC ',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
              letterSpacing: -0.5,
            ),
          ),
          TextSpan(
            text: 'Food',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
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
