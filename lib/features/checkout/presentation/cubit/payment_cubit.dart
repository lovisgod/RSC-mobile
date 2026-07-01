import 'dart:developer' as developer;

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../data/models/ussd_bank.dart';
import '../../domain/usecases/build_payment_payload_usecase.dart';
import '../../domain/usecases/initiate_payment_usecase.dart';
import 'checkout_state.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit(this._buildPayload, this._initiatePayment)
      : super(const PaymentState());

  final BuildPaymentPayloadUseCase _buildPayload;
  final InitiatePaymentUseCase _initiatePayment;

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

  /// Validation-phase entry point: builds the payload from the cart + checkout
  /// selections, calls the backend, and stores the Paystack handoff details.
  /// Does NOT launch Paystack yet — that comes in a follow-up.
  Future<void> initiatePaymentWithBackend(
    CartEntity cart,
    CheckoutState checkoutState,
  ) async {
    emit(state.copyWith(
      status: PaymentStatus.initiating,
      clearInitiateResult: true,
      clearError: true,
      isSessionExpired: false,
    ));

    try {
      final request = _buildPayload(cart, checkoutState);
      final result = await _initiatePayment(request);
      if (isClosed) return;

      developer.log(
        'Payment initiated → $result',
        name: 'PaymentCubit',
      );

      // Ready for the next step (actual Paystack launch comes later).
      emit(state.copyWith(
        status: PaymentStatus.idle,
        initiateResult: result,
        clearError: true,
      ));
    } catch (e) {
      if (isClosed) return;
      final isAuth = e is AuthException &&
          e.message == AppStrings.sessionExpiredLogin;
      emit(state.copyWith(
        status: PaymentStatus.failed,
        errorMessage: e is AuthException ? e.message : AppStrings.paymentFailed,
        isSessionExpired: isAuth,
      ));
    }
  }

  Future<void> processPayment(double amount) async {
    emit(state.copyWith(status: PaymentStatus.processing));
    await Future.delayed(const Duration(seconds: 3));
    if (isClosed) return;
    emit(state.copyWith(status: PaymentStatus.success));
  }
}
