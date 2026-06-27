import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/mock/mock_user.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../domain/enums/delivery_mode.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(this._localStorage) : super(const CheckoutState());

  final LocalStorage _localStorage;

  static const double _deliveryFeeAmount = 500.0;
  static const double _vatRate = 0.075;

  Future<void> initCheckout(CartEntity cart) async {
    const deliveryFee = _deliveryFeeAmount;
    final subtotal = cart.subtotal;
    final vat = subtotal * _vatRate;
    final grandTotal = subtotal + deliveryFee + vat;

    emit(state.copyWith(
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      vat: vat,
      grandTotal: grandTotal,
    ));

    final user = await _localStorage.getUser();
    emit(state.copyWith(isLoggedIn: user != null));
  }

  void switchMode(DeliveryMode mode) {
    final deliveryFee =
        mode == DeliveryMode.delivery ? _deliveryFeeAmount : 0.0;
    final grandTotal = state.subtotal + deliveryFee + state.vat;
    emit(state.copyWith(
      selectedMode: mode,
      deliveryFee: deliveryFee,
      grandTotal: grandTotal,
    ));
  }

  void updateDeliveryAddress(String address) {
    emit(state.copyWith(
      deliveryAddress: address,
      isUsingDefaultAddress: false,
    ));
  }

  void useDefaultAddress() {
    emit(state.copyWith(
      deliveryAddress: MockUser.defaultAddress,
      isUsingDefaultAddress: true,
    ));
  }

  void toggleOrderForSomeoneElse(bool value) {
    emit(state.copyWith(
      isOrderingForSomeoneElse: value,
      recipientAddress: value ? state.recipientAddress : '',
      recipientName: value ? state.recipientName : '',
    ));
  }

  void updateRecipientAddress(String address) {
    emit(state.copyWith(recipientAddress: address));
  }

  void updateRecipientName(String name) {
    emit(state.copyWith(recipientName: name));
  }

  void updatePreparationInstructions(String instructions) {
    emit(state.copyWith(preparationInstructions: instructions));
  }
}
