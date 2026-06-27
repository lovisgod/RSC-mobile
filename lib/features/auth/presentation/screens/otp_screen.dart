import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/otp_countdown_timer.dart';
import '../../../../core/widgets/otp_input_row.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    super.key,
    required this.registerSuccess,
    required this.onVerified,
    required this.onGoBack,
  });

  final RegisterSuccess registerSuccess;
  final VoidCallback onVerified;
  final VoidCallback onGoBack;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpCtrl = TextEditingController();
  final _focusNode = FocusNode();
  final _timerKey = GlobalKey<OtpCountdownTimerState>();
  bool _isExpired = false;
  bool _isResending = false;
  String _selectedChannel = 'phone';

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
    _isResending = false;
    final code = _otpCtrl.text;
    if (code.length != AppConstants.otpLength) return;
    blocCtx.read<AuthBloc>().add(OtpSubmitted(
          customerId: widget.registerSuccess.customerId,
          channel: _selectedChannel,
          phone: _selectedChannel == 'phone'
              ? widget.registerSuccess.phone
              : null,
          email: _selectedChannel == 'email'
              ? widget.registerSuccess.email
              : null,
          code: code,
        ));
  }

  void _resend(BuildContext blocCtx) {
    _isResending = true;
    blocCtx.read<AuthBloc>().add(OtpResendRequested(
          channel: _selectedChannel,
          phone: widget.registerSuccess.phone,
          email: widget.registerSuccess.email,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final channels = widget.registerSuccess.verificationChannels;
    final hasPhone = channels.containsKey('phone');
    final hasEmail = channels.containsKey('email');
    final showToggle = hasPhone && hasEmail;

    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (_, current) =>
          current is AuthLoading ||
          current is OtpVerifySuccess ||
          current is OtpResendSuccess ||
          current is AuthFailure,
      listener: (ctx, state) {
        if (state is AuthLoading) {
          AppSnackbar.show(
            ctx,
            message: _isResending
                ? AppStrings.snackResendingOtp
                : AppStrings.snackVerifyingOtp,
            emoji: '🔐',
            type: AppSnackbarType.loading,
            persistent: true,
          );
        } else if (state is OtpVerifySuccess) {
          AppSnackbar.dismiss();
          AppSnackbar.show(
            ctx,
            message: AppStrings.otpVerifySuccessMsg,
            emoji: '✅',
            type: AppSnackbarType.success,
          );
          widget.onVerified();
        } else if (state is OtpResendSuccess) {
          AppSnackbar.dismiss();
          AppSnackbar.show(
            ctx,
            message: '${AppStrings.newCodeSentTo}${state.channel}',
            emoji: '✓',
            type: AppSnackbarType.success,
          );
          _timerKey.currentState?.reset(state.otpExpiresInSeconds);
          setState(() {
            _isExpired = false;
            _isResending = false;
            _otpCtrl.clear();
          });
        } else if (state is AuthFailure) {
          AppSnackbar.dismiss();
          AppSnackbar.show(
            ctx,
            message: state.message,
            type: AppSnackbarType.error,
          );
          if (!_isResending) {
            _otpCtrl.clear();
          }
          setState(() => _isResending = false);
        }
      },
      builder: (ctx, state) {
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

                  // ── Back ─────────────────────────────────────────────────
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: AppColors.navy,
                        size: 20,
                      ),
                      onPressed: isLoading ? null : widget.onGoBack,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Logo ─────────────────────────────────────────────────
                  const _AuthLogo(),
                  const SizedBox(height: 24),

                  // ── Title & subtitle ─────────────────────────────────────
                  Text(
                    AppStrings.otpTitle,
                    style: AppTextStyles.h2.copyWith(color: AppColors.navy),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.otpSubtitle,
                    style: AppTextStyles.body
                        .copyWith(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 28),

                  // ── Channel badges ────────────────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (hasPhone)
                        _ChannelBadge(label: AppStrings.otpChannelPhone),
                      if (hasPhone && hasEmail) const SizedBox(width: 8),
                      if (hasEmail)
                        _ChannelBadge(label: AppStrings.otpChannelEmail),
                    ],
                  ),

                  // ── Channel toggle ───────────────────────────────────────
                  if (showToggle) ...[
                    const SizedBox(height: 20),
                    _ChannelToggle(
                      selected: _selectedChannel,
                      onChanged: isLoading
                          ? null
                          : (channel) {
                              setState(() {
                                _selectedChannel = channel;
                                _otpCtrl.clear();
                              });
                            },
                    ),
                  ],

                  const SizedBox(height: 28),

                  // ── OTP input ─────────────────────────────────────────────
                  OtpInputRow(
                    controller: _otpCtrl,
                    focusNode: _focusNode,
                    enabled: !isLoading,
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 16),

                  // ── Countdown ─────────────────────────────────────────────
                  OtpCountdownTimer(
                    key: _timerKey,
                    initialSeconds:
                        widget.registerSuccess.otpExpiresInSeconds,
                    onExpired: () => setState(() => _isExpired = true),
                  ),

                  const SizedBox(height: 28),

                  // ── Verify button ─────────────────────────────────────────
                  AppButton(
                    label: AppStrings.btnVerify,
                    isLoading: isLoading,
                    onPressed: otpFilled && !isLoading && !_isExpired
                        ? () => _submit(ctx)
                        : null,
                    backgroundColor: AppColors.navy,
                  ),


                  const SizedBox(height: 16),

                  // ── Resend button ─────────────────────────────────────────
                  TextButton(
                    onPressed: _isExpired && !isLoading
                        ? () => _resend(ctx)
                        : null,
                    child: Text(
                      AppStrings.btnResendCode,
                      style: AppTextStyles.body.copyWith(
                        color: _isExpired && !isLoading
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

// ── Channel badge ───────────────────────────────────────────────────────────

class _ChannelBadge extends StatelessWidget {
  const _ChannelBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.caption.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// ── Channel toggle ──────────────────────────────────────────────────────────

class _ChannelToggle extends StatelessWidget {
  const _ChannelToggle({
    required this.selected,
    required this.onChanged,
  });

  final String selected;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _ToggleOption(
            label: AppStrings.otpChannelPhone,
            value: 'phone',
            selected: selected == 'phone',
            onTap: onChanged != null ? () => onChanged!('phone') : null,
          ),
          _ToggleOption(
            label: AppStrings.otpChannelEmail,
            value: 'email',
            selected: selected == 'email',
            onTap: onChanged != null ? () => onChanged!('email') : null,
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: selected ? AppColors.navy : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: AppTextStyles.body.copyWith(
              color: selected ? AppColors.textOnDark : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Auth logo (shared) ──────────────────────────────────────────────────────

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
