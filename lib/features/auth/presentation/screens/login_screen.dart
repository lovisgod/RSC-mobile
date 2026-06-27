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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onGoToRegister});

  final VoidCallback onGoToRegister;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _obscurePassword = true;
  String? _identifierError;
  String? _passwordError;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  bool _validate() {
    final id = _identifierCtrl.text.trim();
    final pw = _passwordCtrl.text;

    String? idErr;
    String? pwErr;

    if (id.isEmpty) idErr = AppStrings.errorFieldRequired;
    if (pw.isEmpty) {
      pwErr = AppStrings.errorFieldRequired;
    } else if (pw.length < 6) {
      pwErr = AppStrings.errorPasswordMin;
    }

    setState(() {
      _identifierError = idErr;
      _passwordError = pwErr;
    });

    return idErr == null && pwErr == null;
  }

  void _submit(BuildContext context) {
    if (!_validate()) return;
    context.read<AuthBloc>().add(LoginSubmitted(
          identifier: _identifierCtrl.text.trim(),
          password: _passwordCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (_, current) =>
          current is AuthLoading ||
          current is LoginSuccess ||
          current is AuthFailure,
      listener: (context, state) {
        if (state is AuthLoading) {
          AppSnackbar.show(
            context,
            message: AppStrings.snackLoggingIn,
            emoji: '🔑',
            type: AppSnackbarType.loading,
            persistent: true,
          );
        } else if (state is LoginSuccess) {
          AppSnackbar.dismiss();
          // ShellBloc reacts to LoginSuccess and navigates to Home tab
        } else if (state is AuthFailure) {
          AppSnackbar.dismiss();
          final isInactive =
              state.message.toLowerCase().contains('inactive') ||
              state.message.toLowerCase().contains('unverified') ||
              state.message.toLowerCase().contains('not active');
          AppSnackbar.show(
            context,
            message: isInactive
                ? AppStrings.errorInactiveAccount
                : state.message,
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
                  const SizedBox(height: 64),

                  const _AuthLogo(),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.loginSubtitle,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 48),

                  const _FieldLabel(AppStrings.labelEmailOrPhone),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _identifierCtrl,
                    hint: AppStrings.hintEmailOrPhone,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    errorText: _identifierError,
                    enabled: !isLoading,
                    onChanged: (_) {
                      if (_identifierError != null) {
                        setState(() => _identifierError = null);
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  const _FieldLabel(AppStrings.labelPassword),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _passwordCtrl,
                    hint: AppStrings.hintPassword,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    errorText: _passwordError,
                    enabled: !isLoading,
                    onChanged: (_) {
                      if (_passwordError != null) {
                        setState(() => _passwordError = null);
                      }
                    },
                    onSubmitted: (_) => _submit(context),
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

                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: isLoading
                          ? null
                          : () => context.push(RouteNames.forgotPassword),
                      child: Text(
                        AppStrings.forgotPasswordLink,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  AppButton(
                    label: AppStrings.btnLogin,
                    isLoading: isLoading,
                    onPressed: () => _submit(context),
                    backgroundColor: AppColors.navy,
                  ),

                  const SizedBox(height: 32),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.loginFooterText,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: isLoading ? null : widget.onGoToRegister,
                        child: Text(
                          AppStrings.btnRegister,
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

// ── Shared private widgets ──────────────────────────────────────────────────

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
