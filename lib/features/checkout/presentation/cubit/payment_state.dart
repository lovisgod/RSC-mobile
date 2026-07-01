import '../../data/models/initiate_payment_response_model.dart';
import '../../data/models/ussd_bank.dart';

enum PaymentMethod { card, transfer, ussd }

enum PaymentStatus { idle, initiating, processing, success, failed }

class PaymentState {
  final PaymentMethod selectedMethod;
  final String cardNumber;
  final String cardExpiry;
  final String cardCvv;
  final UssdBank? selectedUssdBank;
  final PaymentStatus status;

  /// Set once the backend initiate call succeeds (Paystack handoff details).
  final InitiatePaymentResponseModel? initiateResult;

  /// Last failure message, surfaced by the screen on [PaymentStatus.failed].
  final String? errorMessage;

  /// True when the last failure was a 401 — drives the navigate-home behaviour.
  final bool isSessionExpired;

  const PaymentState({
    this.selectedMethod = PaymentMethod.card,
    this.cardNumber = '',
    this.cardExpiry = '',
    this.cardCvv = '',
    this.selectedUssdBank,
    this.status = PaymentStatus.idle,
    this.initiateResult,
    this.errorMessage,
    this.isSessionExpired = false,
  });

  PaymentState copyWith({
    PaymentMethod? selectedMethod,
    String? cardNumber,
    String? cardExpiry,
    String? cardCvv,
    UssdBank? selectedUssdBank,
    bool clearUssdBank = false,
    PaymentStatus? status,
    InitiatePaymentResponseModel? initiateResult,
    bool clearInitiateResult = false,
    String? errorMessage,
    bool clearError = false,
    bool? isSessionExpired,
  }) {
    return PaymentState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      cardNumber: cardNumber ?? this.cardNumber,
      cardExpiry: cardExpiry ?? this.cardExpiry,
      cardCvv: cardCvv ?? this.cardCvv,
      selectedUssdBank:
          clearUssdBank ? null : (selectedUssdBank ?? this.selectedUssdBank),
      status: status ?? this.status,
      initiateResult:
          clearInitiateResult ? null : (initiateResult ?? this.initiateResult),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSessionExpired: isSessionExpired ?? this.isSessionExpired,
    );
  }
}
