import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/widgets/overlay_address_field.dart';
import '../../../../core/widgets/shimmer_box.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../profile/domain/entities/delivery_address_entity.dart';
import '../../../profile/presentation/cubit/address_cubit.dart';
import '../../../profile/presentation/cubit/order_history_cubit.dart';
import '../../../shell/presentation/bloc/shell_bloc.dart';
import '../../../shell/presentation/bloc/shell_event.dart';
import '../../../track/presentation/cubit/track_cubit.dart';
import '../../data/models/address_suggestion_model.dart';
import '../../domain/entities/preparation_suggestion_entity.dart';
import '../../domain/enums/delivery_mode.dart';
import '../cubit/checkout_cubit.dart';
import '../cubit/checkout_state.dart';
import '../cubit/payment_cubit.dart';
import '../cubit/payment_state.dart';
import '../widgets/moment_payment_sheet.dart';
import '../widgets/suggestion_chip.dart';

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
    context.read<AddressCubit>().loadAddresses();
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
    final defaultAddress = context.read<AddressCubit>().state.defaultAddress;
    if (defaultAddress == null) return;

    context.read<CheckoutCubit>().useDefaultAddress(defaultAddress);
  }

  void _selectAddress(AddressSuggestionModel suggestion) {
    context.read<CheckoutCubit>().selectAddress(suggestion);
    FocusScope.of(context).unfocus();
  }

  void _syncAddressController(String address) {
    if (_deliveryAddressCtrl.text == address) return;
    _deliveryAddressCtrl.text = address;
    _deliveryAddressCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _deliveryAddressCtrl.text.length),
    );
  }

  void _onCheckoutState(BuildContext context, CheckoutState state) {
    _syncAddressController(state.deliveryAddress);
    if (state.addressResolveError != null) {
      AppSnackbar.show(
        context,
        message: state.addressResolveError!,
        type: AppSnackbarType.error,
      );
      context.read<CheckoutCubit>().consumeAddressResolveError();
    }
  }

  void _clearAddress() {
    _deliveryAddressCtrl.clear();
    context.read<CheckoutCubit>().onAddressChanged('');
  }

  void _dismissSuggestions() {
    context.read<CheckoutCubit>().dismissSuggestions();
    FocusScope.of(context).unfocus();
  }

  void _appendPreparationSuggestion(String text) {
    final existing = _prepInstructionsCtrl.text;
    final newText = existing.isEmpty ? text : '$existing, $text';
    _prepInstructionsCtrl.text = newText;
    _prepInstructionsCtrl.selection = TextSelection.fromPosition(
      TextPosition(offset: _prepInstructionsCtrl.text.length),
    );
    context.read<CheckoutCubit>().updatePreparationInstructions(newText);
  }

  /// Validation phase: kick off the backend initiate call. We do NOT open the
  /// Moment sheet here yet — that gets wired to the real payment UI in a
  /// follow-up once this call is confirmed end to end.
  void _onProceedToPayment() {
    final checkoutCubit = context.read<CheckoutCubit>();
    final validationError = checkoutCubit.validateBeforePayment();
    if (validationError != null) {
      AppSnackbar.show(
        context,
        message: validationError,
        type: AppSnackbarType.error,
      );
      return;
    }

    final cart = context.read<CartCubit>().state.cart;
    context.read<PaymentCubit>().initiatePaymentWithBackend(
      cart,
      checkoutCubit.state,
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

    if (state.status == PaymentStatus.initiated) {
      _openMomentSheet(state);
    }
  }

  /// Opens the Moment sheet using the same [PaymentCubit] instance that ran
  /// the initiate call — never a fresh one — so the sheet's own processing
  /// simulation shares state with the screen.
  Future<void> _openMomentSheet(PaymentState paymentState) async {
    final checkoutState = context.read<CheckoutCubit>().state;

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<PaymentCubit>(),
        child: MomentPaymentSheet(
          amount: checkoutState.grandTotal,
          reference: paymentState.initiateResult?.reference,
          accessCode: paymentState.initiateResult?.accessCode,
        ),
      ),
    );

    if (result != 'success' || !mounted) return;

    // Real order data (id, payment reference, delivery code, status) now
    // comes from the backend — fetch it and let TrackCubit pick up whichever
    // order is still active.
    await getIt<OrderHistoryCubit>().loadOrders();
    await getIt<TrackCubit>().loadActiveOrder();
    if (!mounted) return;

    context.read<CartCubit>().clearCart();
    AppSnackbar.show(
      context,
      message: AppStrings.orderPlacedSuccessfully,
      type: AppSnackbarType.success,
    );
    context.read<ShellBloc>().add(const ShellTabChanged(3));
    context.pop();
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
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _dismissSuggestions,
        child: MultiBlocListener(
          listeners: [
            BlocListener<PaymentCubit, PaymentState>(
              listenWhen: (prev, curr) => prev.status != curr.status,
              listener: _onPaymentState,
            ),
            BlocListener<CheckoutCubit, CheckoutState>(
              listenWhen: (prev, curr) =>
                  prev.deliveryAddress != curr.deliveryAddress ||
                  prev.addressResolveError != curr.addressResolveError,
              listener: _onCheckoutState,
            ),
          ],
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
                          final defaultAddress = context
                              .watch<AddressCubit>()
                              .state
                              .defaultAddress;
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
                                    defaultAddress: defaultAddress,
                                    addressCtrl: _deliveryAddressCtrl,
                                    recipientAddressCtrl: _recipientAddressCtrl,
                                    recipientNameCtrl: _recipientNameCtrl,
                                    onAddressChanged: cubit.onAddressChanged,
                                    onSuggestionTapped: _selectAddress,
                                    onClearAddress: _clearAddress,
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
                                _SuggestionsRow(
                                  suggestions: state.suggestions,
                                  isLoading: state.isLoadingSuggestions,
                                  onSuggestionTap: _appendPreparationSuggestion,
                                ),
                                TextField(
                                  controller: _prepInstructionsCtrl,
                                  minLines: 2,
                                  maxLines: 4,
                                  onChanged: (value) {
                                    cubit.updatePreparationInstructions(value);
                                    cubit.filterSuggestions(value);
                                  },
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
                    ? const LoadingOverlay(label: AppStrings.initiatingPayment)
                    : const SizedBox.shrink(),
              ),
            ],
          ),
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

// ── Preparation suggestions row ───────────────────────────────────────────────

class _SuggestionsRow extends StatelessWidget {
  const _SuggestionsRow({
    required this.suggestions,
    required this.isLoading,
    required this.onSuggestionTap,
  });

  final List<PreparationSuggestionEntity> suggestions;
  final bool isLoading;
  final ValueChanged<String> onSuggestionTap;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              3,
              (index) => const Padding(
                padding: EdgeInsets.only(right: 8),
                child: ShimmerBox(width: 80, height: 32, radius: 99),
              ),
            ),
          ),
        ),
      );
    }

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: suggestions
              .map(
                (suggestion) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SuggestionChip(
                    text: suggestion.text,
                    onTap: () => onSuggestionTap(suggestion.text),
                  ),
                ),
              )
              .toList(),
        ),
      ),
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
    required this.defaultAddress,
    required this.addressCtrl,
    required this.recipientAddressCtrl,
    required this.recipientNameCtrl,
    required this.onAddressChanged,
    required this.onSuggestionTapped,
    required this.onClearAddress,
    required this.onUseDefault,
    required this.onToggleSomeoneElse,
    required this.onRecipientAddressChanged,
    required this.onRecipientNameChanged,
  });

  final CheckoutState state;
  final DeliveryAddressEntity? defaultAddress;
  final TextEditingController addressCtrl;
  final TextEditingController recipientAddressCtrl;
  final TextEditingController recipientNameCtrl;
  final ValueChanged<String> onAddressChanged;
  final ValueChanged<AddressSuggestionModel> onSuggestionTapped;
  final VoidCallback onClearAddress;
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
          // Address field
          OverlayAddressField(
            controller: addressCtrl,
            hint: AppStrings.searchAndSelectAddress,
            suggestions: state.addressSuggestions,
            isSearching: state.isSearchingAddress,
            isResolving: state.isValidatingAddress,
            onChanged: onAddressChanged,
            onSuggestionTapped: onSuggestionTapped,
            onClear: onClearAddress,
          ),
          _AddressVerificationHint(state: state),
          const SizedBox(height: 12),

          // Use Default Address button
          GestureDetector(
            onTap: defaultAddress != null ? onUseDefault : null,
            child: Opacity(
              opacity: defaultAddress != null ? 1 : 0.5,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
          ),
          if (defaultAddress == null) ...[
            const SizedBox(height: 6),
            const Text(
              AppStrings.noDefaultAddressSet,
              style: TextStyle(fontSize: 11, color: AppColors.textHint),
            ),
          ],
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

// ── Address verification hint ─────────────────────────────────────────────────

class _AddressVerificationHint extends StatelessWidget {
  const _AddressVerificationHint({required this.state});

  final CheckoutState state;

  @override
  Widget build(BuildContext context) {
    if (state.deliveryAddress.isEmpty) return const SizedBox.shrink();

    if (state.isValidatingAddress) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
            SizedBox(width: 8),
            Text(
              AppStrings.checkingDeliveryAvailability,
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    if (state.addressOutOfZone) {
      return const Padding(
        padding: EdgeInsets.only(top: 8),
        child: _OutOfZoneWarningCard(),
      );
    }

    if (state.addressVerified) {
      final zoneName = state.deliveryZoneName;
      return Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Text(
          zoneName != null
              ? '${AppStrings.deliveringToZone} $zoneName'
              : AppStrings.addressVerifiedSimple,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          ),
        ),
      );
    }

    if (!state.showSuggestions && !state.isSearchingAddress) {
      return const Padding(
        padding: EdgeInsets.only(top: 6),
        child: Text(
          AppStrings.pleaseSelectFromSuggestions,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.primary,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

class _OutOfZoneWarningCard extends StatelessWidget {
  const _OutOfZoneWarningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.outsideDeliveryArea,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 2),
          Text(
            AppStrings.outsideDeliveryAreaMessage,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
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

  void _onGuestTap(BuildContext context) {
    AppSnackbar.show(
      context,
      message: AppStrings.pleaseLoginToOrder,
      emoji: '',
      backgroundColor: AppColors.navy,
    );
    Future.delayed(const Duration(milliseconds: 800), () {
      if (context.mounted) {
        context.read<ShellBloc>().add(const ShellTabChanged(4));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool formInvalid = state.isLoggedIn && !state.isFormValid;
    final bool isActive = !formInvalid;

    String? hintText;
    Color hintColor = AppColors.textSecondary;
    if (formInvalid && state.selectedMode == DeliveryMode.delivery) {
      if (state.isOrderingForSomeoneElse) {
        hintText = AppStrings.pleaseEnterDeliveryAddress;
      } else if (state.addressOutOfZone) {
        hintText = AppStrings.selectAddressInArea;
        hintColor = AppColors.error;
      } else if (state.deliveryAddress.trim().isEmpty) {
        hintText = AppStrings.enterDeliveryAddress;
      } else {
        hintText = AppStrings.selectValidAddress;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppButton(
          label: AppStrings.proceedToPayment,
          backgroundColor: formInvalid ? AppColors.textHint : AppColors.navy,
          onPressed: !isActive
              ? null
              : state.isLoggedIn
              ? onActiveTap
              : () => _onGuestTap(context),
        ),
        if (hintText != null) ...[
          const SizedBox(height: 8),
          Text(
            hintText,
            style: TextStyle(fontSize: 12, color: hintColor),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}
