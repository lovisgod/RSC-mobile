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

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _identifierCtrl = TextEditingController();

  @override
  void dispose() {
    _identifierCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    final identifier = _identifierCtrl.text.trim();
    if (identifier.isEmpty) return;
    context
        .read<AuthBloc>()
        .add(ForgotPasswordSubmitted(identifier: identifier));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (_, current) =>
          current is ForgotPasswordLoading ||
          current is ForgotPasswordSuccess ||
          current is AuthFailure,
      listener: (context, state) {
        if (state is ForgotPasswordSuccess) {
          context.push(
            RouteNames.resetOtp,
            extra: {
              'identifier': state.identifier,
              'otpExpiresInSeconds': state.otpExpiresInSeconds,
            },
          );
        } else if (state is AuthFailure) {
          AppSnackbar.show(
            context,
            message: state.message,
            type: AppSnackbarType.error,
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ForgotPasswordLoading;
        final identifier = _identifierCtrl.text.trim();

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
                  const SizedBox(height: 28),

                  Text(
                    AppStrings.forgotPasswordTitle,
                    style: AppTextStyles.h2.copyWith(color: AppColors.navy),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.forgotPasswordSubtitle,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  const _FieldLabel(AppStrings.labelEmailOrPhone),
                  const SizedBox(height: 8),
                  AppTextField(
                    controller: _identifierCtrl,
                    hint: AppStrings.hintEmailOrPhone,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    enabled: !isLoading,
                    onChanged: (_) => setState(() {}),
                    onSubmitted: (_) => _submit(context),
                  ),

                  const SizedBox(height: 32),

                  AppButton(
                    label: AppStrings.sendResetCode,
                    isLoading: isLoading,
                    backgroundColor: AppColors.navy,
                    onPressed: isLoading || identifier.isEmpty
                        ? null
                        : () => _submit(context),
                  ),

                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.rememberYourPassword,
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: isLoading ? null : () => context.pop(),
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
