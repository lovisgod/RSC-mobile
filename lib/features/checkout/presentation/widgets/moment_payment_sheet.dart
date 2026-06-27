import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/mock/mock_payment.dart';
import '../../../../core/utils/formatters.dart';
import '../../data/models/ussd_bank.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../formatters/card_expiry_formatter.dart';
import '../formatters/card_number_formatter.dart';

// ── Sheet colours (dark theme) ─────────────────────────────────────────────────

abstract final class _SheetColors {
  static const background = Color(0xFF1A1F2E);
  static const surface = Color(0xFF252B3B);
  static const surfaceActive = Color(0xFF353D52);
  static const divider = Color(0xFF2E3447);
  static const cyan = Color(0xFF4FC3F7);
  static const textMuted = Color(0xFF8892A4);
  static const badgeRed = Color(0xFFE53935);
  static const bankSelected = Color(0xFF3B82F6);
  static const bankMenu = Color(0xFF1E2537);
}

// ── Entry point ───────────────────────────────────────────────────────────────

class MomentPaymentSheet extends StatefulWidget {
  const MomentPaymentSheet({super.key, required this.amount});

  final double amount;

  @override
  State<MomentPaymentSheet> createState() => _MomentPaymentSheetState();
}

class _MomentPaymentSheetState extends State<MomentPaymentSheet> {
  final _cardNumberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final keyboardInset = MediaQuery.viewInsetsOf(context).bottom;

    return BlocConsumer<PaymentCubit, PaymentState>(
      listenWhen: (p, c) => p.status != c.status,
      listener: (ctx, state) {
        if (state.status == PaymentStatus.success) {
          Navigator.of(ctx).pop('success');
        }
      },
      builder: (context, state) {
        final cubit = context.read<PaymentCubit>();
        final isProcessing = state.status == PaymentStatus.processing;

        return Padding(
          padding: EdgeInsets.only(bottom: keyboardInset),
          child: Container(
            height: screenHeight * 0.62,
            decoration: const BoxDecoration(
              color: _SheetColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                // ── Header ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: _SheetHeader(amount: widget.amount),
                ),
                const Divider(
                  height: 1,
                  color: _SheetColors.divider,
                ),
                const SizedBox(height: 16),

                // ── Payment method tabs ─────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _PaymentTabs(
                    selected: state.selectedMethod,
                    onTap: cubit.switchMethod,
                  ),
                ),
                const SizedBox(height: 16),

                // ── Tab content ─────────────────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: IndexedStack(
                      index: state.selectedMethod.index,
                      children: [
                        _CardContent(
                          cardNumberCtrl: _cardNumberCtrl,
                          expiryCtrl: _expiryCtrl,
                          cvvCtrl: _cvvCtrl,
                          onCardNumberChanged: cubit.updateCardNumber,
                          onExpiryChanged: cubit.updateCardExpiry,
                          onCvvChanged: cubit.updateCardCvv,
                        ),
                        const _TransferContent(),
                        _UssdContent(
                          state: state,
                          onBankSelected: cubit.selectUssdBank,
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Action button ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: _ActionButton(
                    state: state,
                    amount: widget.amount,
                    onTap: isProcessing
                        ? null
                        : () => cubit.processPayment(widget.amount),
                  ),
                ),

                // ── Cancel ─────────────────────────────────────────────
                if (!isProcessing)
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                      child: Text(
                        AppStrings.cancelTransaction,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _SheetColors.textMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 36),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.amount});

  final double amount;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Brand
        const Text('⚡', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 6),
        const Text(
          'Moment',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _SheetColors.cyan,
          ),
        ),
        const SizedBox(width: 8),
        // Checkout badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _SheetColors.badgeRed,
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'Checkout',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const Spacer(),
        // Amount
        Text(
          formatNaira(amount),
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

// ── Payment method tabs ───────────────────────────────────────────────────────

class _PaymentTabs extends StatelessWidget {
  const _PaymentTabs({required this.selected, required this.onTap});

  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _SheetColors.surface,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _MethodTab(
            label: AppStrings.tabCard,
            isActive: selected == PaymentMethod.card,
            onTap: () => onTap(PaymentMethod.card),
          ),
          _MethodTab(
            label: AppStrings.tabTransfer,
            isActive: selected == PaymentMethod.transfer,
            onTap: () => onTap(PaymentMethod.transfer),
          ),
          _MethodTab(
            label: AppStrings.tabUssd,
            isActive: selected == PaymentMethod.ussd,
            onTap: () => onTap(PaymentMethod.ussd),
          ),
        ],
      ),
    );
  }
}

class _MethodTab extends StatelessWidget {
  const _MethodTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? _SheetColors.surfaceActive : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? Colors.white : _SheetColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Dark input decoration helper ──────────────────────────────────────────────

InputDecoration _darkInput({required String hint}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 14, color: _SheetColors.textMuted),
    filled: true,
    fillColor: _SheetColors.surface,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _SheetColors.cyan, width: 1.5),
    ),
  );
}

const _inputTextStyle = TextStyle(fontSize: 15, color: Colors.white);

// ── Card tab ──────────────────────────────────────────────────────────────────

class _CardContent extends StatelessWidget {
  const _CardContent({
    required this.cardNumberCtrl,
    required this.expiryCtrl,
    required this.cvvCtrl,
    required this.onCardNumberChanged,
    required this.onExpiryChanged,
    required this.onCvvChanged,
  });

  final TextEditingController cardNumberCtrl;
  final TextEditingController expiryCtrl;
  final TextEditingController cvvCtrl;
  final ValueChanged<String> onCardNumberChanged;
  final ValueChanged<String> onExpiryChanged;
  final ValueChanged<String> onCvvChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Card number
        TextField(
          controller: cardNumberCtrl,
          onChanged: onCardNumberChanged,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            CardNumberFormatter(),
          ],
          style: _inputTextStyle,
          decoration: _darkInput(hint: AppStrings.cardNumberHint),
        ),
        const SizedBox(height: 12),

        // Expiry + CVV row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: expiryCtrl,
                onChanged: onExpiryChanged,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  CardExpiryFormatter(),
                ],
                style: _inputTextStyle,
                decoration: _darkInput(hint: AppStrings.expiry),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: cvvCtrl,
                onChanged: onCvvChanged,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 3,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: _inputTextStyle,
                decoration: _darkInput(hint: AppStrings.cvv).copyWith(
                  counterText: '',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Transfer tab ──────────────────────────────────────────────────────────────

class _TransferContent extends StatelessWidget {
  const _TransferContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CustomPaint(
          painter: _DashedBorderPainter(color: _SheetColors.cyan),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: _SheetColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  MockPayment.bankName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  MockPayment.accountNumber,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: _SheetColors.cyan,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.transferInstructions,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _SheetColors.textMuted,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Dashed border painter ─────────────────────────────────────────────────────

class _DashedBorderPainter extends CustomPainter {
  final Color color;

  const _DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    const strokeWidth = 1.5;
    const radius = 12.0;

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        const Radius.circular(radius),
      ));

    final result = Path();
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        result.addPath(
          metric.extractPath(distance, distance + dashWidth),
          Offset.zero,
        );
        distance += dashWidth + dashSpace;
      }
    }
    canvas.drawPath(result, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── USSD tab ──────────────────────────────────────────────────────────────────

class _UssdContent extends StatelessWidget {
  const _UssdContent({required this.state, required this.onBankSelected});

  final PaymentState state;
  final ValueChanged<UssdBank> onBankSelected;

  @override
  Widget build(BuildContext context) {
    final selected = state.selectedUssdBank;

    return Column(
      children: [
        // Bank selector
        PopupMenuButton<UssdBank>(
          onSelected: onBankSelected,
          color: _SheetColors.bankMenu,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          offset: const Offset(0, 8),
          itemBuilder: (_) => UssdBank.banks.map((bank) {
            final isSelected = selected?.name == bank.name;
            return PopupMenuItem<UssdBank>(
              value: bank,
              padding: EdgeInsets.zero,
              child: ColoredBox(
                color: isSelected
                    ? _SheetColors.bankSelected
                    : Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: isSelected
                            ? const Icon(Icons.check,
                                color: _SheetColors.cyan, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${bank.name} (${bank.ussdCode})',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: _SheetColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    selected != null
                        ? '${selected.name} (${selected.ussdCode})'
                        : AppStrings.selectBank,
                    style: TextStyle(
                      fontSize: 14,
                      color: selected != null
                          ? Colors.white
                          : _SheetColors.textMuted,
                    ),
                  ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _SheetColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        // Dial instruction (shown after bank selected)
        if (selected != null) ...[
          const SizedBox(height: 16),
          Text(
            '${AppStrings.ussdDialPrefix}${selected.ussdCode}${AppStrings.ussdDialSuffix}',
            style: const TextStyle(
              fontSize: 14,
              color: _SheetColors.textMuted,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
        const SizedBox(height: 8),
      ],
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.state,
    required this.amount,
    required this.onTap,
  });

  final PaymentState state;
  final double amount;
  final VoidCallback? onTap;

  String _label() {
    if (state.status == PaymentStatus.processing) {
      return AppStrings.processing;
    }
    return switch (state.selectedMethod) {
      PaymentMethod.card => AppStrings.paySecurelyWithMoment,
      PaymentMethod.transfer => AppStrings.iSentTheMoney,
      PaymentMethod.ussd => AppStrings.iDialledTheCode,
    };
  }

  @override
  Widget build(BuildContext context) {
    final isProcessing = state.status == PaymentStatus.processing;
    final isFailed = state.status == PaymentStatus.failed;

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: Opacity(
            opacity: isProcessing ? 0.8 : 1.0,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: _SheetColors.cyan,
                foregroundColor: _SheetColors.background,
                disabledBackgroundColor:
                    _SheetColors.cyan.withValues(alpha: 0.8),
                shape: const StadiumBorder(),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isProcessing) ...[
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: _SheetColors.background,
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Text(
                    _label(),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _SheetColors.background,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isFailed) ...[
          const SizedBox(height: 8),
          Text(
            AppStrings.paymentFailed,
            style: const TextStyle(
              fontSize: 12,
              color: _SheetColors.badgeRed,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
