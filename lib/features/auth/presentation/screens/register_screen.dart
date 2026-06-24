import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../widgets/otp_verification_sheet.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key, required this.onGoToLogin});

  final void Function({String? successMessage}) onGoToLogin;

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

// RFC 5322-aligned email regex: validates local-part @ domain . TLD(2+)
final _emailRegex = RegExp(
  r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
);

// Allows digits, +, -, spaces, and parentheses — rejects letters & symbols
final _phoneFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'[\d\s\+\-\(\)]'),
);

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String? _nameError;
  String? _emailError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmError;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final pw = _passwordCtrl.text;
    final confirm = _confirmCtrl.text;

    String? nameErr, emailErr, phoneErr, pwErr, confirmErr;

    if (name.isEmpty) nameErr = AppStrings.errorFieldRequired;
    if (email.isEmpty) {
      emailErr = AppStrings.errorFieldRequired;
    } else if (!_emailRegex.hasMatch(email)) {
      emailErr = AppStrings.errorInvalidEmail;
    }
    if (phone.isEmpty) {
      phoneErr = AppStrings.errorFieldRequired;
    } else {
      final digits = phone.replaceAll(RegExp(r'\D'), '');
      if (digits.length < 11) {
        phoneErr = AppStrings.errorPhoneTooShort;
      }
    }
    if (pw.isEmpty) {
      pwErr = AppStrings.errorFieldRequired;
    } else if (pw.length < 6) {
      pwErr = AppStrings.errorPasswordMin;
    }
    if (confirm.isEmpty) {
      confirmErr = AppStrings.errorFieldRequired;
    } else if (confirm != pw) {
      confirmErr = AppStrings.errorPasswordsMismatch;
    }

    setState(() {
      _nameError = nameErr;
      _emailError = emailErr;
      _phoneError = phoneErr;
      _passwordError = pwErr;
      _confirmError = confirmErr;
    });

    return nameErr == null &&
        emailErr == null &&
        phoneErr == null &&
        pwErr == null &&
        confirmErr == null;
  }

  void _submit(BuildContext context) {
    if (!_validate()) return;
    context.read<AuthBloc>().add(AuthRegisterRequested(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim().toLowerCase(),
          phone: _phoneCtrl.text.trim(),
          password: _passwordCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          (current is AuthLoading && previous is! AuthOtpSent) ||
          current is AuthOtpSent ||
          (current is AuthFailure && previous is! AuthOtpSent),
      listener: (context, state) {
        if (state is AuthLoading) {
          AppSnackbar.show(
            context,
            message: AppStrings.snackSendingOtp,
            emoji: '📱',
            type: AppSnackbarType.loading,
            persistent: true,
          );
        } else if (state is AuthOtpSent) {
          AppSnackbar.dismiss();
          final authBloc = context.read<AuthBloc>();
          showGeneralDialog<void>(
            context: context,
            barrierDismissible: false,
            barrierLabel: '',
            barrierColor: Colors.transparent,
            transitionDuration: const Duration(milliseconds: 320),
            transitionBuilder: (_, anim, _, child) {
              final curved = CurvedAnimation(
                parent: anim,
                curve: Curves.easeOutCubic,
              );
              return ScaleTransition(
                scale: Tween<double>(begin: 0.88, end: 1.0).animate(curved),
                child: FadeTransition(opacity: anim, child: child),
              );
            },
            pageBuilder: (dialogCtx, _, _) => BlocProvider<AuthBloc>.value(
              value: authBloc,
              child: OtpVerificationSheet(
                otpState: state,
                onSuccess: () {
                  if (mounted) widget.onGoToLogin();
                },
              ),
            ),
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
                  const SizedBox(height: 48),

                  // ── Logo ────────────────────────────────────────────────
                  const _AuthLogo(),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.registerSubtitle,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // ── Full Name ────────────────────────────────────────────
                  const _FieldLabel(AppStrings.labelFullName),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _nameCtrl,
                    hint: AppStrings.hintFullName,
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    errorText: _nameError,
                    enabled: !isLoading,
                    onChanged: (_) {
                      if (_nameError != null) {
                        setState(() => _nameError = null);
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── Email ────────────────────────────────────────────────
                  const _FieldLabel(AppStrings.labelEmail),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _emailCtrl,
                    hint: AppStrings.hintEmail,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autocorrect: false,
                    enableSuggestions: false,
                    errorText: _emailError,
                    enabled: !isLoading,
                    onChanged: (_) {
                      if (_emailError != null) {
                        setState(() => _emailError = null);
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── Phone ────────────────────────────────────────────────
                  const _FieldLabel(AppStrings.labelPhone),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _phoneCtrl,
                    hint: AppStrings.hintPhone,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [_phoneFormatter],
                    errorText: _phoneError,
                    enabled: !isLoading,
                    onChanged: (_) {
                      if (_phoneError != null) {
                        setState(() => _phoneError = null);
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  // ── Password ─────────────────────────────────────────────
                  const _FieldLabel(AppStrings.labelPassword),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _passwordCtrl,
                    hint: AppStrings.hintPassword,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    errorText: _passwordError,
                    enabled: !isLoading,
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
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

                  const SizedBox(height: 20),

                  // ── Confirm Password ─────────────────────────────────────
                  const _FieldLabel(AppStrings.labelConfirmPassword),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _confirmCtrl,
                    hint: AppStrings.hintConfirmPassword,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    errorText: _confirmError,
                    enabled: !isLoading,
                    onChanged: (_) {
                      if (_confirmError != null) {
                        setState(() => _confirmError = null);
                      }
                    },
                    onSubmitted: (_) => _submit(context),
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

                  const SizedBox(height: 32),

                  // ── Button ──────────────────────────────────────────────
                  AppButton(
                    label: AppStrings.btnRegister,
                    isLoading: isLoading,
                    onPressed: () => _submit(context),
                    backgroundColor: AppColors.navy,
                  ),

                  const SizedBox(height: 32),

                  // ── Footer ──────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.registerFooterText,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: isLoading
                            ? null
                            : () => widget.onGoToLogin(),
                        child: Text(
                          AppStrings.btnLogin,
                          style: AppTextStyles.bodyBold
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
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

// ── Private shared widgets ──────────────────────────────────────────────────

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
              fontSize: 42,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
              letterSpacing: -0.5,
            ),
          ),
          TextSpan(
            text: 'Food',
            style: TextStyle(
              fontSize: 42,
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
