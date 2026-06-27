import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/ussd_bank.dart';
import 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit() : super(const PaymentState());

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

  Future<void> processPayment(double amount) async {
    emit(state.copyWith(status: PaymentStatus.processing));
    await Future.delayed(const Duration(seconds: 3));
    if (isClosed) return;
    emit(state.copyWith(status: PaymentStatus.success));
  }
}
