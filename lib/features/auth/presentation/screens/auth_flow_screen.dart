import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../bloc/auth_state.dart';
import 'login_screen.dart';
import 'otp_screen.dart';
import 'register_screen.dart';

enum _AuthPage { login, register, otp }

/// Manages the login ↔ register ↔ OTP-verify flow inside the profile tab.
/// No routes — all screens live within this single widget.
class AuthFlowScreen extends StatefulWidget {
  const AuthFlowScreen({super.key});

  @override
  State<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends State<AuthFlowScreen> {
  _AuthPage _page = _AuthPage.login;
  RegisterSuccess? _registerResult;

  void _goToRegister() => setState(() {
        _page = _AuthPage.register;
        _registerResult = null;
      });

  void _goToOtp(RegisterSuccess result) => setState(() {
        _page = _AuthPage.otp;
        _registerResult = result;
      });

  void _goToLogin({String? successMessage}) {
    setState(() {
      _page = _AuthPage.login;
      _registerResult = null;
    });
    if (successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppSnackbar.show(
          context,
          message: successMessage,
          emoji: '✅',
          type: AppSnackbarType.success,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return switch (_page) {
      _AuthPage.login => LoginScreen(onGoToRegister: _goToRegister),
      _AuthPage.register => RegisterScreen(
          onGoToLogin: _goToLogin,
          onGoToOtp: _goToOtp,
        ),
      _AuthPage.otp => OtpScreen(
          registerSuccess: _registerResult!,
          onVerified: () => _goToLogin(
            successMessage: AppStrings.otpVerifySuccessMsg,
          ),
          onGoBack: _goToRegister,
        ),
    };
  }
}
