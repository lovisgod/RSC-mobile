import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SuggestionChip extends StatefulWidget {
  const SuggestionChip({super.key, required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  State<SuggestionChip> createState() => _SuggestionChipState();
}

class _SuggestionChipState extends State<SuggestionChip> {
  bool _isHighlighted = false;

  void _handleTap() {
    setState(() => _isHighlighted = true);
    widget.onTap();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) setState(() => _isHighlighted = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _isHighlighted ? AppColors.navy : AppColors.background,
          borderRadius: BorderRadius.circular(99),
          border: Border.all(
            color: _isHighlighted ? AppColors.navy : AppColors.inputBorder,
          ),
        ),
        child: Text(
          widget.text,
          style: TextStyle(
            fontSize: 12,
            color: _isHighlighted ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
