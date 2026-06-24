import 'package:flutter/material.dart';

import '../../../../core/widgets/app_snackbar.dart';
import 'login_screen.dart';
import 'register_screen.dart';

/// Manages the login ↔ register switch inside the shell's Home tab.
/// Neither screen requires a route — they live entirely within this widget.
class AuthFlowScreen extends StatefulWidget {
  const AuthFlowScreen({super.key});

  @override
  State<AuthFlowScreen> createState() => _AuthFlowScreenState();
}

class _AuthFlowScreenState extends State<AuthFlowScreen> {
  bool _showRegister = false;

  void _goToRegister() => setState(() => _showRegister = true);

  void _goToLogin({String? successMessage}) {
    setState(() => _showRegister = false);
    if (successMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        AppSnackbar.show(
          context,
          message: successMessage,
          type: AppSnackbarType.success,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _showRegister
        ? RegisterScreen(onGoToLogin: _goToLogin)
        : LoginScreen(onGoToRegister: _goToRegister);
  }
}
