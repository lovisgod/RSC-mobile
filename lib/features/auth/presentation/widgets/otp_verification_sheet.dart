import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpVerificationSheet extends StatefulWidget {
  const OtpVerificationSheet({
    super.key,
    required this.otpState,
    required this.onSuccess,
  });

  final AuthOtpSent otpState;
  final VoidCallback onSuccess;

  @override
  State<OtpVerificationSheet> createState() => _OtpVerificationSheetState();
}

class _OtpVerificationSheetState extends State<OtpVerificationSheet> {
  final _otpCtrl = TextEditingController();
  final _focusNode = FocusNode();

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

  void _verify(BuildContext blocCtx) {
    final otp = _otpCtrl.text;
    if (otp.length != AppConstants.otpLength) return;
    blocCtx.read<AuthBloc>().add(AuthOtpVerifyRequested(
          otp: otp,
          name: widget.otpState.name,
          email: widget.otpState.email,
          phone: widget.otpState.phone,
          password: widget.otpState.password,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (_, current) =>
          current is AuthRegisterSuccess || current is AuthFailure,
      listener: (ctx, state) {
        if (state is AuthRegisterSuccess) {
          // Show success snackbar here while dialog context is live,
          // so the overlay entry is reliably inserted before the route pops.
          AppSnackbar.show(
            ctx,
            message: AppStrings.registerSuccessMsg,
            emoji: '🎉',
            type: AppSnackbarType.success,
          );
          Navigator.of(ctx).pop();
          widget.onSuccess();
        } else if (state is AuthFailure) {
          AppSnackbar.dismiss();
          AppSnackbar.show(
            ctx,
            message: state.message,
            type: AppSnackbarType.error,
          );
        }
      },
      builder: (ctx, state) {
        final isLoading = state is AuthLoading;
        final otpComplete = _otpCtrl.text.length == AppConstants.otpLength;

        return Material(
          type: MaterialType.transparency,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Frosted-glass backdrop
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.28),
                ),
              ),

              // Centered dialog card
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Title
                        Text(
                          AppStrings.otpTitle,
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.navy,
                            fontWeight: FontWeight.w700,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 10),

                        // Subtitle with bold phone number
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: AppTextStyles.body
                                .copyWith(color: AppColors.textSecondary),
                            children: [
                              const TextSpan(text: AppStrings.otpSubtitleStart),
                              TextSpan(
                                text: widget.otpState.phone,
                                style: AppTextStyles.bodyBold
                                    .copyWith(color: AppColors.textPrimary),
                              ),
                              const TextSpan(text: AppStrings.otpSubtitleEnd),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        // OTP digit boxes
                        _OtpInput(
                          controller: _otpCtrl,
                          focusNode: _focusNode,
                          enabled: !isLoading,
                          onChanged: (_) => setState(() {}),
                        ),

                        const SizedBox(height: 32),

                        // Verify button
                        AppButton(
                          label: AppStrings.btnVerifyAndProceed,
                          isLoading: isLoading,
                          onPressed: otpComplete && !isLoading
                              ? () => _verify(ctx)
                              : null,
                          backgroundColor: AppColors.navy,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── OTP digit input ────────────────────────────────────────────────────────

class _OtpInput extends StatelessWidget {
  const _OtpInput({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = controller.text;
    return SizedBox(
      height: 60,
      child: Stack(
        children: [
          // Visual digit boxes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(AppConstants.otpLength, (i) {
              return _OtpBox(digit: i < text.length ? text[i] : null);
            }),
          ),

          // Transparent overlay captures keyboard input
          Positioned.fill(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              enabled: enabled,
              keyboardType: TextInputType.number,
              maxLength: AppConstants.otpLength,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: onChanged,
              style: const TextStyle(color: Colors.transparent, fontSize: 1),
              cursorColor: Colors.transparent,
              enableInteractiveSelection: false,
              decoration: const InputDecoration(
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                border: InputBorder.none,
                counterText: '',
                fillColor: Colors.transparent,
                filled: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({this.digit});

  final String? digit;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.inputBorder, width: 1.5),
      ),
      child: Center(
        child: digit != null
            ? Text(
                digit!,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }
}
