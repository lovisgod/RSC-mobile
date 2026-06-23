import 'package:flutter/material.dart';

class OtpPage extends StatelessWidget {
  final String phone;

  const OtpPage({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify OTP')),
      body: Center(child: Text('OtpPage ($phone) — Phase 3')),
    );
  }
}
