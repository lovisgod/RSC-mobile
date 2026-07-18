import '../../data/models/initiate_payment_response_model.dart';
import '../../data/models/ussd_bank.dart';

enum PaymentMethod { card, transfer, ussd }

enum PaymentStatus {
  idle,
  initiating,
  initiated,
  processing,
  verifying,
  success,
  failed,
  cancelled,
}

class PaymentState {
  final PaymentMethod selectedMethod;
  final String cardNumber;
  final String cardExpiry;
  final String cardCvv;
  final UssdBank? selectedUssdBank;
  final PaymentStatus status;

  /// Set once the backend initiate call succeeds (Paystack handoff details).
  final InitiatePaymentResponseModel? initiateResult;

  /// Moment reference from the initiate response, stored so [PaymentCubit]
  /// can verify the outcome after the WebView closes.
  final String? reference;

  /// Hosted checkout URL from the last initiate/retry call — what the
  /// WebView should load on [PaymentStatus.initiated].
  String? get checkoutUrl => initiateResult?.checkoutUrl;

  /// Last failure message, surfaced by the screen on [PaymentStatus.failed].
  final String? errorMessage;

  const PaymentState({
    this.selectedMethod = PaymentMethod.card,
    this.cardNumber = '',
    this.cardExpiry = '',
    this.cardCvv = '',
    this.selectedUssdBank,
    this.status = PaymentStatus.idle,
    this.initiateResult,
    this.reference,
    this.errorMessage,
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
    String? reference,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PaymentState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      cardNumber: cardNumber ?? this.cardNumber,
      cardExpiry: cardExpiry ?? this.cardExpiry,
      cardCvv: cardCvv ?? this.cardCvv,
      selectedUssdBank: clearUssdBank
          ? null
          : (selectedUssdBank ?? this.selectedUssdBank),
      status: status ?? this.status,
      initiateResult: clearInitiateResult
          ? null
          : (initiateResult ?? this.initiateResult),
      reference: reference ?? this.reference,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
