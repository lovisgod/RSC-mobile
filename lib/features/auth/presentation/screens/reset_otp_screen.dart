import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/otp_countdown_timer.dart';
import '../../../../core/widgets/otp_input_row.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ResetOtpScreen extends StatefulWidget {
  const ResetOtpScreen({
    super.key,
    required this.identifier,
    required this.otpExpiresInSeconds,
  });

  final String identifier;
  final int otpExpiresInSeconds;

  @override
  State<ResetOtpScreen> createState() => _ResetOtpScreenState();
}

class _ResetOtpScreenState extends State<ResetOtpScreen> {
  final _otpCtrl = TextEditingController();
  final _focusNode = FocusNode();
  final _timerKey = GlobalKey<OtpCountdownTimerState>();
  bool _isTimerExpired = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _otpCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    context.read<AuthBloc>().add(ResetPasswordOtpSubmitted(
          identifier: widget.identifier,
          otpCode: _otpCtrl.text,
        ));
  }

  void _resend(BuildContext context) {
    context.read<AuthBloc>().add(
          ForgotPasswordSubmitted(identifier: widget.identifier),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (_, current) =>
          current is AuthLoading ||
          current is ForgotPasswordSuccess ||
          current is ResetPasswordOtpVerified ||
          current is AuthFailure,
      listener: (context, state) {
        if (state is ForgotPasswordSuccess) {
          _timerKey.currentState?.reset(state.otpExpiresInSeconds);
          setState(() => _isTimerExpired = false);
        } else if (state is ResetPasswordOtpVerified) {
          context.push(
            RouteNames.newPassword,
            extra: {
              'identifier': state.identifier,
              'otpCode': state.otpCode,
            },
          );
        } else if (state is AuthFailure) {
          AppSnackbar.show(
            context,
            message: state.message,
            type: AppSnackbarType.error,
          );
          _otpCtrl.clear();
          setState(() {});
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final otpFilled = _otpCtrl.text.length == AppConstants.otpLength;

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
                    AppStrings.enterResetCode,
                    style: AppTextStyles.h2.copyWith(color: AppColors.navy),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.resetOtpSubtitle,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 32),

                  OtpInputRow(
                    controller: _otpCtrl,
                    focusNode: _focusNode,
                    enabled: !isLoading,
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 16),

                  OtpCountdownTimer(
                    key: _timerKey,
                    initialSeconds: widget.otpExpiresInSeconds,
                    onExpired: () => setState(() => _isTimerExpired = true),
                  ),

                  const SizedBox(height: 28),

                  AppButton(
                    label: AppStrings.btnVerify,
                    isLoading: isLoading,
                    backgroundColor: AppColors.navy,
                    onPressed:
                        otpFilled && !isLoading && !_isTimerExpired
                            ? () => _submit(context)
                            : null,
                  ),

                  const SizedBox(height: 16),

                  TextButton(
                    onPressed: _isTimerExpired && !isLoading
                        ? () => _resend(context)
                        : null,
                    child: Text(
                      AppStrings.btnResendCode,
                      style: AppTextStyles.body.copyWith(
                        color: _isTimerExpired && !isLoading
                            ? AppColors.navy
                            : AppColors.textHint,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
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
