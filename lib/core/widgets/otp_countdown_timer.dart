import 'dart:async';

import 'package:flutter/material.dart';

import '../constants/app_strings.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class OtpCountdownTimer extends StatefulWidget {
  const OtpCountdownTimer({
    super.key,
    required this.initialSeconds,
    this.onExpired,
  });

  final int initialSeconds;
  final VoidCallback? onExpired;

  @override
  State<OtpCountdownTimer> createState() => OtpCountdownTimerState();
}

class OtpCountdownTimerState extends State<OtpCountdownTimer> {
  late int _secondsLeft;
  Timer? _timer;
  bool _isExpired = false;

  bool get isExpired => _isExpired;

  @override
  void initState() {
    super.initState();
    _secondsLeft = widget.initialSeconds;
    _start();
  }

  void reset(int seconds) {
    _timer?.cancel();
    setState(() {
      _secondsLeft = seconds;
      _isExpired = false;
    });
    _start();
  }

  void _start() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        _timer?.cancel();
        setState(() => _isExpired = true);
        widget.onExpired?.call();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final mins = _secondsLeft ~/ 60;
    final secs = _secondsLeft % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _isExpired
          ? AppStrings.otpCodeExpired
          : '${AppStrings.otpCodeExpiresIn}$_formattedTime',
      style: AppTextStyles.caption.copyWith(
        color: _isExpired ? AppColors.error : AppColors.primary,
        fontWeight: FontWeight.w600,
      ),
      textAlign: TextAlign.center,
    );
  }
}
