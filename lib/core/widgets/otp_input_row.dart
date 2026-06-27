import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_constants.dart';
import '../theme/app_colors.dart';

class OtpInputRow extends StatelessWidget {
  const OtpInputRow({
    super.key,
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
              return OtpBox(digit: i < text.length ? text[i] : null);
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

class OtpBox extends StatelessWidget {
  const OtpBox({super.key, this.digit});

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
