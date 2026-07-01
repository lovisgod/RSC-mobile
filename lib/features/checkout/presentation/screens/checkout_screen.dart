import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/mock/mock_user.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../cart/domain/entities/cart_item_entity.dart';
import '../../../profile/domain/entities/order_history_entity.dart';
import '../../../profile/domain/entities/order_history_line_item.dart';
import '../../../profile/domain/entities/order_history_sub_order.dart';
import '../../../profile/presentation/cubit/order_history_cubit.dart';
import '../../../shell/presentation/bloc/shell_bloc.dart';
import '../../../shell/presentation/bloc/shell_event.dart';
import '../../../track/presentation/cubit/track_cubit.dart';
import '../../domain/enums/delivery_mode.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../widgets/moment_payment_sheet.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.cart});

  final CartEntity cart;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _deliveryAddressCtrl = TextEditingController();
  final _recipientAddressCtrl = TextEditingController();
  final _recipientNameCtrl = TextEditingController();
  final _prepInstructionsCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<CheckoutCubit>().initCheckout(widget.cart);
  }

  @override
  void dispose() {
    _deliveryAddressCtrl.dispose();
    _recipientAddressCtrl.dispose();
    _recipientNameCtrl.dispose();
    _prepInstructionsCtrl.dispose();
    super.dispose();
  }

  void _useDefaultAddress() {
    context.read<CheckoutCubit>().useDefaultAddress();
    _deliveryAddressCtrl.text = MockUser.defaultAddress;
    _deliveryAddressCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _deliveryAddressCtrl.text.length),
    );
  }

  /// Validation phase: kick off the backend initiate call. We do NOT open the
  /// Moment sheet here yet — that gets wired to the real payment UI in a
  /// follow-up once this call is confirmed end to end.
  void _onProceedToPayment() {
    final cart = context.read<CartCubit>().state.cart;
    final checkoutState = context.read<CheckoutCubit>().state;
    context.read<PaymentCubit>().initiatePaymentWithBackend(
      cart,
      checkoutState,
    );
  }

  void _onPaymentState(BuildContext context, PaymentState state) {
    if (state.status == PaymentStatus.failed) {
      AppSnackbar.show(
        context,
        message: state.errorMessage ?? AppStrings.paymentFailed,
        type: AppSnackbarType.error,
      );
      // Session expired → bounce back to home so the user can log in again.
      if (state.isSessionExpired) context.go(RouteNames.home);
      return;
    }

    final result = state.initiateResult;
    if (result != null) {
      AppSnackbar.show(
        context,
        message:
            '${AppStrings.paymentInitiatedSuccess} '
            '${AppStrings.paymentReferenceLabel} ${result.reference}',
        type: AppSnackbarType.success,
      );
    }
  }

  // Retained for the follow-up that wires the real Paystack/Moment UI; not
  // auto-triggered during this validation phase.
  // ignore: unused_element
  Future<void> _showPaymentSheet(double amount) async {
    final cartItems = context.read<CartCubit>().state.cart.items;
    final checkoutState = context.read<CheckoutCubit>().state;

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => getIt<PaymentCubit>(),
        child: MomentPaymentSheet(amount: amount),
      ),
    );

    if (result != 'success' || !mounted) return;

    getIt<TrackCubit>().startOrderTracking(cartItems);

    final activeOrder = getIt<TrackCubit>().state.activeOrder!;
    getIt<OrderHistoryCubit>().addInProgressOrder(
      OrderHistoryEntity(
        orderId: activeOrder.orderId,
        deliveryCode: activeOrder.deliveryCode,
        placedAt: DateTime.now(),
        deliveryMode: checkoutState.selectedMode == DeliveryMode.delivery
            ? 'DELIVERY'
            : 'TAKEOUT',
        deliveryAddress: checkoutState.deliveryAddress,
        subOrders: _buildOrderSubOrders(cartItems),
        subtotal: checkoutState.subtotal,
        deliveryFee: checkoutState.deliveryFee,
        vat: checkoutState.vat,
        grandTotal: checkoutState.grandTotal,
        isCompleted: false,
        cartItems: cartItems,
      ),
    );

    context.read<CartCubit>().clearCart();
    AppSnackbar.show(
      context,
      message: AppStrings.orderPlacedSuccessfully,
      type: AppSnackbarType.success,
    );
    context.read<ShellBloc>().add(const ShellTabChanged(3));
    context.pop();
  }

  List<OrderHistorySubOrder> _buildOrderSubOrders(
    List<CartItemEntity> cartItems,
  ) {
    final grouped = <String, List<CartItemEntity>>{};
    for (final item in cartItems) {
      (grouped[item.outletId] ??= []).add(item);
    }
    return grouped.entries.map((e) {
      final items = e.value;
      return OrderHistorySubOrder(
        outletName: items.first.outletName,
        outletEmoji: items.first.outletEmoji,
        items: items
            .map(
              (item) => OrderHistoryLineItem(
                itemName: item.itemNameSnapshot,
                quantity: item.quantity,
                unitPrice: item.unitPrice,
                selectedModifiers: item.selectedModifiers
                    .map((m) => m.name)
                    .toList(),
              ),
            )
            .toList(),
      );
    }).toList();
  }

  void _toggleSomeoneElse(bool? value) {
    final checked = value ?? false;
    context.read<CheckoutCubit>().toggleOrderForSomeoneElse(checked);
    if (!checked) {
      _recipientAddressCtrl.clear();
      _recipientNameCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: BlocListener<PaymentCubit, PaymentState>(
        listenWhen: (prev, curr) =>
            curr.initiateResult != prev.initiateResult ||
            (curr.status == PaymentStatus.failed && prev.status != curr.status),
        listener: _onPaymentState,
        child: Stack(
          children: [
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CheckoutAppBar(),
                  Expanded(
                    child: BlocBuilder<CheckoutCubit, CheckoutState>(
                      builder: (context, state) {
                        final cubit = context.read<CheckoutCubit>();
                        return SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── Mode toggle ────────────────────────────────
                              _ModeToggle(
                                selectedMode: state.selectedMode,
                                onChanged: cubit.switchMode,
                              ),
                              const SizedBox(height: 20),

                              // ── Delivery address (delivery only) ───────────
                              if (state.selectedMode ==
                                  DeliveryMode.delivery) ...[
                                _SectionHeader(
                                  emoji: '📍',
                                  label: AppStrings.sectionDeliveryAddress,
                                ),
                                const SizedBox(height: 10),
                                _DeliveryAddressCard(
                                  state: state,
                                  addressCtrl: _deliveryAddressCtrl,
                                  recipientAddressCtrl: _recipientAddressCtrl,
                                  recipientNameCtrl: _recipientNameCtrl,
                                  onAddressChanged: cubit.updateDeliveryAddress,
                                  onUseDefault: _useDefaultAddress,
                                  onToggleSomeoneElse: _toggleSomeoneElse,
                                  onRecipientAddressChanged:
                                      cubit.updateRecipientAddress,
                                  onRecipientNameChanged:
                                      cubit.updateRecipientName,
                                ),
                                const SizedBox(height: 20),
                              ],

                              // ── Preparation instructions ───────────────────
                              _SectionHeader(
                                emoji: '📝',
                                label:
                                    AppStrings.sectionPreparationInstructions,
                              ),
                              const SizedBox(height: 10),
                              TextField(
                                controller: _prepInstructionsCtrl,
                                minLines: 2,
                                maxLines: 4,
                                onChanged: cubit.updatePreparationInstructions,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: InputDecoration(
                                  hintText:
                                      AppStrings.preparationInstructionsHint,
                                  hintStyle: const TextStyle(
                                    fontSize: 14,
                                    color: AppColors.textHint,
                                  ),
                                  contentPadding: const EdgeInsets.all(14),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.inputBorder,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.inputBorder,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: AppColors.inputBorderFocused,
                                      width: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),

                              // ── Price breakdown ────────────────────────────
                              _PriceBreakdown(state: state),
                              const SizedBox(height: 24),

                              // ── Proceed button ─────────────────────────────
                              _ProceedButton(
                                state: state,
                                onActiveTap: _onProceedToPayment,
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Loading overlay while the initiate call is in flight.
            BlocSelector<PaymentCubit, PaymentState, bool>(
              selector: (state) => state.status == PaymentStatus.initiating,
              builder: (_, isInitiating) => isInitiating
                  ? const _InitiatingOverlay()
                  : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Initiating overlay ────────────────────────────────────────────────────────

class _InitiatingOverlay extends StatelessWidget {
  const _InitiatingOverlay();

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.45),
        child: const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
    );
  }
}

// ── App bar ───────────────────────────────────────────────────────────────────

class _CheckoutAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 16,
                color: AppColors.navyDark,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            AppStrings.checkout,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.emoji, required this.label});

  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}

// ── Mode toggle ───────────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.selectedMode, required this.onChanged});

  final DeliveryMode selectedMode;
  final ValueChanged<DeliveryMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          _ToggleTab(
            label: AppStrings.deliveryTab,
            isActive: selectedMode == DeliveryMode.delivery,
            onTap: () => onChanged(DeliveryMode.delivery),
          ),
          _ToggleTab(
            label: AppStrings.takeoutTab,
            isActive: selectedMode == DeliveryMode.takeout,
            onTap: () => onChanged(DeliveryMode.takeout),
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
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
            color: isActive ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
              color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Delivery address card ─────────────────────────────────────────────────────

class _DeliveryAddressCard extends StatelessWidget {
  const _DeliveryAddressCard({
    required this.state,
    required this.addressCtrl,
    required this.recipientAddressCtrl,
    required this.recipientNameCtrl,
    required this.onAddressChanged,
    required this.onUseDefault,
    required this.onToggleSomeoneElse,
    required this.onRecipientAddressChanged,
    required this.onRecipientNameChanged,
  });

  final CheckoutState state;
  final TextEditingController addressCtrl;
  final TextEditingController recipientAddressCtrl;
  final TextEditingController recipientNameCtrl;
  final ValueChanged<String> onAddressChanged;
  final VoidCallback onUseDefault;
  final ValueChanged<bool?> onToggleSomeoneElse;
  final ValueChanged<String> onRecipientAddressChanged;
  final ValueChanged<String> onRecipientNameChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Address row
          Row(
            children: [
              const Text('🏠', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: addressCtrl,
                  onChanged: onAddressChanged,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: AppStrings.typeDeliveryAddressHint,
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textHint,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Use Default Address button
          GestureDetector(
            onTap: onUseDefault,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.navyDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                AppStrings.useDefaultAddress,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 4),

          // Geofence checkbox
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: state.isOrderingForSomeoneElse,
                  onChanged: onToggleSomeoneElse,
                  activeColor: AppColors.primary,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  AppStrings.orderForSomeoneElse,
                  style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),

          // Animated recipient fields
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: state.isOrderingForSomeoneElse
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 14),
                      const Text(
                        AppStrings.recipientInGeofenceAddress,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _RecipientTextField(
                        controller: recipientAddressCtrl,
                        hint: AppStrings.recipientInGeofenceAddress,
                        onChanged: onRecipientAddressChanged,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        AppStrings.recipientNameLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      _RecipientTextField(
                        controller: recipientNameCtrl,
                        hint: AppStrings.recipientNameLabel,
                        onChanged: onRecipientNameChanged,
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity, height: 0),
          ),
        ],
      ),
    );
  }
}

class _RecipientTextField extends StatelessWidget {
  const _RecipientTextField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.textHint),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: AppColors.inputBorderFocused,
            width: 1.5,
          ),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
    );
  }
}

// ── Price breakdown ───────────────────────────────────────────────────────────

class _PriceBreakdown extends StatelessWidget {
  const _PriceBreakdown({required this.state});

  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          AppStrings.priceBreakdown,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        _PriceRow(
          label: AppStrings.subtotal,
          value: formatNaira(state.subtotal),
        ),
        const SizedBox(height: 6),
        _PriceRow(
          label: AppStrings.deliveryFeeLabel,
          value: formatNaira(state.deliveryFee),
        ),
        const SizedBox(height: 6),
        _PriceRow(label: AppStrings.vatLabel, value: formatNaira(state.vat)),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 10),
          child: Divider(height: 1, color: AppColors.divider),
        ),
        _PriceRow(
          label: AppStrings.grandTotal,
          value: formatNaira(state.grandTotal),
          isBold: true,
          valueColor: AppColors.primary,
        ),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    this.isBold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: isBold ? 15 : 14,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
      color: AppColors.textPrimary,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(
          value,
          style: style.copyWith(color: valueColor ?? AppColors.textPrimary),
        ),
      ],
    );
  }
}

// ── Proceed button ────────────────────────────────────────────────────────────

class _ProceedButton extends StatelessWidget {
  const _ProceedButton({required this.state, required this.onActiveTap});

  final CheckoutState state;
  final VoidCallback onActiveTap;

  @override
  Widget build(BuildContext context) {
    final bool isActive = state.isLoggedIn && state.isFormValid;

    String? hintText;
    if (!state.isLoggedIn) {
      hintText = AppStrings.pleaseLoginToOrder;
    } else if (!state.isFormValid &&
        state.selectedMode == DeliveryMode.delivery) {
      hintText = AppStrings.pleaseEnterDeliveryAddress;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppButton(
          label: AppStrings.proceedToPayment,
          backgroundColor: state.isLoggedIn
              ? AppColors.navy
              : AppColors.textHint,
          onPressed: isActive ? onActiveTap : null,
        ),
        if (hintText != null) ...[
          const SizedBox(height: 8),
          Text(
            hintText,
            style: TextStyle(
              fontSize: 12,
              color: state.isLoggedIn
                  ? AppColors.error
                  : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
