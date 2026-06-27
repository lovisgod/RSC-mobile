import '../../domain/enums/delivery_mode.dart';

class CheckoutState {
  final DeliveryMode selectedMode;
  final String deliveryAddress;
  final bool isUsingDefaultAddress;
  final bool isOrderingForSomeoneElse;
  final String recipientAddress;
  final String recipientName;
  final String preparationInstructions;
  final double subtotal;
  final double deliveryFee;
  final double vat;
  final double grandTotal;
  final bool isLoggedIn;

  const CheckoutState({
    this.selectedMode = DeliveryMode.delivery,
    this.deliveryAddress = '',
    this.isUsingDefaultAddress = false,
    this.isOrderingForSomeoneElse = false,
    this.recipientAddress = '',
    this.recipientName = '',
    this.preparationInstructions = '',
    this.subtotal = 0,
    this.deliveryFee = 0,
    this.vat = 0,
    this.grandTotal = 0,
    this.isLoggedIn = false,
  });

  bool get isFormValid {
    if (selectedMode == DeliveryMode.takeout) return true;
    if (isOrderingForSomeoneElse) {
      return recipientAddress.isNotEmpty && recipientName.isNotEmpty;
    }
    return deliveryAddress.isNotEmpty;
  }

  CheckoutState copyWith({
    DeliveryMode? selectedMode,
    String? deliveryAddress,
    bool? isUsingDefaultAddress,
    bool? isOrderingForSomeoneElse,
    String? recipientAddress,
    String? recipientName,
    String? preparationInstructions,
    double? subtotal,
    double? deliveryFee,
    double? vat,
    double? grandTotal,
    bool? isLoggedIn,
  }) {
    return CheckoutState(
      selectedMode: selectedMode ?? this.selectedMode,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      isUsingDefaultAddress:
          isUsingDefaultAddress ?? this.isUsingDefaultAddress,
      isOrderingForSomeoneElse:
          isOrderingForSomeoneElse ?? this.isOrderingForSomeoneElse,
      recipientAddress: recipientAddress ?? this.recipientAddress,
      recipientName: recipientName ?? this.recipientName,
      preparationInstructions:
          preparationInstructions ?? this.preparationInstructions,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      vat: vat ?? this.vat,
      grandTotal: grandTotal ?? this.grandTotal,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }
}
