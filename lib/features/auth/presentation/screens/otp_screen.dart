import 'dart:async';

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

  late int _secondsLeft;
  Timer? _timer;
  bool _isExpired = false;
  String _selectedChannel = 'phone';

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.registerSuccess.otpExpiresInSeconds;
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        setState(() => _isExpired = true);
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _submit(BuildContext blocCtx) {
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
    blocCtx
        .read<AuthBloc>()
        .add(OtpResendRequested(widget.registerSuccess.customerId));
  }

  String get _formattedTime {
    final mins = _secondsLeft ~/ 60;
    final secs = _secondsLeft % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
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
          current is AuthFailure,
      listener: (ctx, state) {
        if (state is AuthLoading) {
          AppSnackbar.show(
            ctx,
            message: AppStrings.snackVerifyingOtp,
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
        } else if (state is AuthFailure) {
          AppSnackbar.dismiss();
          AppSnackbar.show(
            ctx,
            message: state.message,
            type: AppSnackbarType.error,
          );
          _otpCtrl.clear();
          setState(() {});
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
                  _OtpInputRow(
                    controller: _otpCtrl,
                    focusNode: _focusNode,
                    enabled: !isLoading,
                    onChanged: (_) => setState(() {}),
                  ),

                  const SizedBox(height: 16),

                  // ── Countdown ─────────────────────────────────────────────
                  Text(
                    _isExpired
                        ? AppStrings.otpCodeExpired
                        : '${AppStrings.otpCodeExpiresIn}$_formattedTime',
                    style: AppTextStyles.caption.copyWith(
                      color: _isExpired ? AppColors.error : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
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

// ── OTP input row ───────────────────────────────────────────────────────────

class _OtpInputRow extends StatelessWidget {
  const _OtpInputRow({
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
      height: 62,
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(AppConstants.otpLength, (i) {
              return _OtpBox(digit: i < text.length ? text[i] : null);
            }),
          ),
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
      width: 48,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: digit != null ? AppColors.navy : AppColors.inputBorder,
          width: digit != null ? 2.0 : 1.5,
        ),
      ),
      child: Center(
        child: digit != null
            ? Text(
                digit!,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              )
            : const SizedBox.shrink(),
      ),
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
