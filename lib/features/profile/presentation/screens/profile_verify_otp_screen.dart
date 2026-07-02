import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/otp_countdown_timer.dart';
import '../../../../core/widgets/otp_input_row.dart';
import '../cubit/profile_cubit.dart';
import '../cubit/profile_state.dart';

class ProfileVerifyOtpScreen extends StatefulWidget {
  const ProfileVerifyOtpScreen({super.key, required this.otpExpiresInSeconds});

  final int otpExpiresInSeconds;

  @override
  State<ProfileVerifyOtpScreen> createState() => _ProfileVerifyOtpScreenState();
}

class _ProfileVerifyOtpScreenState extends State<ProfileVerifyOtpScreen> {
  final _otpCtrl = TextEditingController();
  final _focusNode = FocusNode();
  bool _isExpired = false;
  String? _errorText;

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

  void _submit(BuildContext blocCtx) {
    final code = _otpCtrl.text;
    if (code.length != AppConstants.otpLength) return;
    setState(() => _errorText = null);
    blocCtx.read<ProfileCubit>().verifyProfileChange(code);
  }

  void _resend() {
    AppSnackbar.show(
      context,
      message: AppStrings.goBackToResendCode,
      type: AppSnackbarType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) =>
          previous.isLoading && !current.isLoading,
      listener: (context, state) {
        if (state.error == null) {
          AppSnackbar.show(
            context,
            message: AppStrings.profileUpdated,
            emoji: '',
            backgroundColor: AppColors.navy,
          );
          context.read<ProfileCubit>().loadProfile();
          context.pop();
          context.pop();
        } else {
          setState(() {
            _errorText = state.error;
            _otpCtrl.clear();
          });
        }
      },
      builder: (context, state) {
        final isLoading = state.isLoading;
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

                  // ── App bar ──────────────────────────────────────────────
                  Row(
                    children: [
                      GestureDetector(
                        onTap: isLoading ? null : () => context.pop(),
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
                            AppStrings.verifyChange,
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

                  const SizedBox(height: 24),

                  // ── Lock icon ────────────────────────────────────────────
                  const Center(
                    child: Text('🔒', style: TextStyle(fontSize: 48)),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    AppStrings.verifyYourChange,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    AppStrings.verifyChangeSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ── OTP input ─────────────────────────────────────────────
                  OtpInputRow(
                    controller: _otpCtrl,
                    focusNode: _focusNode,
                    enabled: !isLoading,
                    onChanged: (_) => setState(() {}),
                  ),

                  if (_errorText != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _errorText!,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ── Countdown ─────────────────────────────────────────────
                  OtpCountdownTimer(
                    initialSeconds: widget.otpExpiresInSeconds,
                    onExpired: () => setState(() => _isExpired = true),
                  ),

                  const SizedBox(height: 24),

                  // ── Verify button ─────────────────────────────────────────
                  AppButton(
                    label: AppStrings.btnVerify,
                    isLoading: isLoading,
                    backgroundColor: AppColors.navy,
                    onPressed: otpFilled && !isLoading && !_isExpired
                        ? () => _submit(context)
                        : null,
                  ),

                  const SizedBox(height: 16),

                  // ── Resend ────────────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        AppStrings.didntReceiveCode,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: _isExpired && !isLoading ? _resend : null,
                        child: Text(
                          AppStrings.resend,
                          style: AppTextStyles.caption.copyWith(
                            color: _isExpired && !isLoading
                                ? AppColors.primary
                                : AppColors.textHint,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
