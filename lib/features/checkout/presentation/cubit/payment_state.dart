import '../../data/models/ussd_bank.dart';

enum PaymentMethod { card, transfer, ussd }

enum PaymentStatus { idle, processing, success, failed }

class PaymentState {
  final PaymentMethod selectedMethod;
  final String cardNumber;
  final String cardExpiry;
  final String cardCvv;
  final UssdBank? selectedUssdBank;
  final PaymentStatus status;

  const PaymentState({
    this.selectedMethod = PaymentMethod.card,
    this.cardNumber = '',
    this.cardExpiry = '',
    this.cardCvv = '',
    this.selectedUssdBank,
    this.status = PaymentStatus.idle,
  });

  PaymentState copyWith({
    PaymentMethod? selectedMethod,
    String? cardNumber,
    String? cardExpiry,
    String? cardCvv,
    UssdBank? selectedUssdBank,
    bool clearUssdBank = false,
    PaymentStatus? status,
  }) {
    return PaymentState(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      cardNumber: cardNumber ?? this.cardNumber,
      cardExpiry: cardExpiry ?? this.cardExpiry,
      cardCvv: cardCvv ?? this.cardCvv,
      selectedUssdBank:
          clearUssdBank ? null : (selectedUssdBank ?? this.selectedUssdBank),
      status: status ?? this.status,
    );
  }
}
