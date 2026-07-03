import '../../../../core/models/nominatim_result.dart';
import '../../../profile/domain/entities/delivery_address_entity.dart';
import '../../domain/enums/delivery_mode.dart';

class CheckoutState {
  final DeliveryMode selectedMode;
  final String deliveryAddress;
  final bool isUsingDefaultAddress;
  final DeliveryAddressEntity? selectedAddress;
  final double? currentLatitude;
  final double? currentLongitude;
  final List<NominatimResult> addressSuggestions;
  final bool isSearchingAddress;
  final bool showSuggestions;

  /// True only when the address came from a Nominatim pick, GPS, or the
  /// saved default address — never from free-typed text.
  final bool addressVerified;
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
    this.selectedAddress,
    this.currentLatitude,
    this.currentLongitude,
    this.addressSuggestions = const [],
    this.isSearchingAddress = false,
    this.showSuggestions = false,
    this.addressVerified = false,
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
    return deliveryAddress.trim().isNotEmpty && addressVerified;
  }

  CheckoutState copyWith({
    DeliveryMode? selectedMode,
    String? deliveryAddress,
    bool? isUsingDefaultAddress,
    DeliveryAddressEntity? selectedAddress,
    bool clearSelectedAddress = false,
    double? currentLatitude,
    double? currentLongitude,
    bool clearCoordinates = false,
    List<NominatimResult>? addressSuggestions,
    bool? isSearchingAddress,
    bool? showSuggestions,
    bool? addressVerified,
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
      selectedAddress: clearSelectedAddress
          ? null
          : (selectedAddress ?? this.selectedAddress),
      currentLatitude: clearCoordinates
          ? null
          : (currentLatitude ?? this.currentLatitude),
      currentLongitude: clearCoordinates
          ? null
          : (currentLongitude ?? this.currentLongitude),
      addressSuggestions: addressSuggestions ?? this.addressSuggestions,
      isSearchingAddress: isSearchingAddress ?? this.isSearchingAddress,
      showSuggestions: showSuggestions ?? this.showSuggestions,
      addressVerified: addressVerified ?? this.addressVerified,
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
