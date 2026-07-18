import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../cart/presentation/cubit/cart_cubit.dart';
import '../../../profile/presentation/cubit/order_history_cubit.dart';
import '../../../track/presentation/cubit/track_cubit.dart';
import '../../data/models/initiate_payment_response_model.dart';
import '../../data/models/ussd_bank.dart';
import '../../domain/usecases/build_payment_payload_usecase.dart';
import '../../domain/usecases/get_platform_charges_usecase.dart';
import '../../domain/usecases/initiate_payment_usecase.dart';
import '../../domain/usecases/retry_payment_usecase.dart';
import '../../domain/usecases/verify_payment_usecase.dart';
import 'checkout_state.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit(
    this._buildPayload,
    this._initiatePayment,
    this._getPlatformCharges,
    this._verifyPayment,
    this._retryPayment,
  ) : super(const PaymentState());

  final BuildPaymentPayloadUseCase _buildPayload;
  final InitiatePaymentUseCase _initiatePayment;
  final GetPlatformChargesUseCase _getPlatformCharges;
  final VerifyPaymentUseCase _verifyPayment;
  final RetryPaymentUseCase _retryPayment;

  void switchMethod(PaymentMethod method) {
    emit(state.copyWith(selectedMethod: method));
  }

  void updateCardNumber(String value) {
    emit(state.copyWith(cardNumber: value));
  }

  void updateCardExpiry(String value) {
    emit(state.copyWith(cardExpiry: value));
  }

  void updateCardCvv(String value) {
    emit(state.copyWith(cardCvv: value));
  }

  void selectUssdBank(UssdBank bank) {
    emit(state.copyWith(selectedUssdBank: bank));
  }

  /// Builds the payload from the cart + checkout selections, calls the
  /// backend, and stores the Moment handoff details. On success the screen
  /// listens for [PaymentStatus.initiated] and opens the Moment WebView.
  Future<void> initiatePaymentWithBackend(
    CartEntity cart,
    CheckoutState checkoutState,
  ) async {
    debugPrint('[RSC Payment] Initiating payment...');
    emit(
      state.copyWith(
        status: PaymentStatus.initiating,
        clearInitiateResult: true,
        clearError: true,
      ),
    );

    try {
      // 1. Fetch platform charges
      final charges = await _getPlatformCharges();

      // 2. Build payload with charges
      final request = _buildPayload(
        cart: cart,
        checkout: checkoutState,
        platformCharges: charges,
      );

      // 3. Initiate payment
      final result = await _initiatePayment(request);
      if (isClosed) return;

      developer.log('Payment initiated → $result', name: 'PaymentCubit');
      debugPrint('[RSC Payment] ✅ Initiated. reference: ${result.reference}');
      debugPrint('[RSC Payment] checkoutUrl: ${result.checkoutUrl}');

      emit(
        state.copyWith(
          status: PaymentStatus.initiated,
          initiateResult: result,
          reference: result.reference,
          clearError: true,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: PaymentStatus.failed,
          errorMessage: e is AuthException
              ? e.message
              : AppStrings.paymentFailed,
        ),
      );
    }
  }

  /// Re-initiates payment for an existing PENDING_PAYMENT order. Emits the
  /// same [PaymentStatus.initiated] state as the checkout flow, so whichever
  /// screen is listening opens the Moment WebView the same way.
  Future<void> retryPaymentForOrder(String orderId) async {
    debugPrint('[RSC Payment] Retrying payment for order: $orderId');
    emit(
      state.copyWith(
        status: PaymentStatus.initiating,
        clearInitiateResult: true,
        clearError: true,
      ),
    );

    try {
      final result = await _retryPayment(orderId);
      if (isClosed) return;

      debugPrint(
        '[RSC Payment] ✅ Retry initiated. reference: ${result.reference}',
      );
      debugPrint('[RSC Payment] checkoutUrl: ${result.checkoutUrl}');

      emit(
        state.copyWith(
          status: PaymentStatus.initiated,
          initiateResult: InitiatePaymentResponseModel(
            checkoutUrl: result.checkoutUrl,
            reference: result.reference,
            masterOrderId: result.masterOrderId,
          ),
          reference: result.reference,
          clearError: true,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: PaymentStatus.failed,
          errorMessage: e is AuthException
              ? e.message
              : AppStrings.paymentFailed,
        ),
      );
    }
  }

  /// Confirms the outcome of the Moment handoff by reference. Called both
  /// when the WebView intercepts the tracking redirect (success path) and
  /// when the user manually closes the WebView (safety net).
  Future<void> verifyPaymentResult(
    String reference, {
    bool isRetry = false,
  }) async {
    if (isClosed) return;
    debugPrint('[RSC Payment] Verifying payment: $reference');
    emit(state.copyWith(status: PaymentStatus.verifying, clearError: true));

    try {
      final result = await _verifyPayment(reference);
      if (isClosed) return;

      debugPrint(
        '[RSC Payment] Verify result: status=${result.status} '
        'orderStatus=${result.orderStatus}',
      );

      if (result.isSuccess) {
        debugPrint('[RSC Payment] ✅ Payment SUCCESS — navigating to track');
        emit(state.copyWith(status: PaymentStatus.success));
        await _handlePostPaymentSuccess();
        return;
      }

      if (result.isPending && !isRetry) {
        debugPrint('[RSC Payment] ⏳ Payment PENDING — retrying in 2s...');
        await Future.delayed(const Duration(seconds: 2));
        if (isClosed) return;
        await verifyPaymentResult(reference, isRetry: true);
        return;
      }

      debugPrint('[RSC Payment] ❌ Payment FAILED: ${result.status}');
      emit(
        state.copyWith(
          status: PaymentStatus.failed,
          errorMessage: AppStrings.paymentFailed,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(
        state.copyWith(
          status: PaymentStatus.failed,
          errorMessage: AppStrings.couldNotVerifyPayment,
        ),
      );
    }
  }

  /// Clears the cart and refreshes order history/tracking so the Track tab
  /// shows the new order as soon as the shell switches to it.
  Future<void> _handlePostPaymentSuccess() async {
    getIt<CartCubit>().clearCart();
    debugPrint('[RSC Payment] Cart cleared');
    await getIt<OrderHistoryCubit>().loadOrders();
    debugPrint('[RSC Payment] Loading active order...');
    await getIt<TrackCubit>().loadActiveOrder();
  }

  Future<void> processPayment(double amount) async {
    emit(state.copyWith(status: PaymentStatus.processing));
    await Future.delayed(const Duration(seconds: 3));
    if (isClosed) return;
    emit(state.copyWith(status: PaymentStatus.success));
  }
}
