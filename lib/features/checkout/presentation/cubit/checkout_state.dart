import '../../../profile/domain/entities/delivery_address_entity.dart';
import '../../data/models/address_suggestion_model.dart';
import '../../domain/entities/preparation_suggestion_entity.dart';
import '../../domain/enums/delivery_mode.dart';

class CheckoutState {
  final DeliveryMode selectedMode;
  final String deliveryAddress;
  final bool isUsingDefaultAddress;
  final DeliveryAddressEntity? selectedAddress;
  final double? currentLatitude;
  final double? currentLongitude;
  final List<AddressSuggestionModel> addressSuggestions;
  final bool isSearchingAddress;
  final bool showSuggestions;

  /// True only when the address came from an autocomplete pick, GPS, or the
  /// saved default address — never from free-typed text.
  final bool addressVerified;

  /// True when the backend's validate-address check came back
  /// non-deliverable for the selected coordinates. Coordinates are still
  /// kept in state — the user just can't proceed to checkout with them.
  final bool addressOutOfZone;

  /// Name of the delivery zone the address falls in (e.g. "Banana Island"),
  /// from the backend validate-address response. Null until validated, and
  /// while addressOutOfZone is true.
  final String? deliveryZoneName;

  /// True while the validate-address call for the current selection is in
  /// flight — blocks the proceed button so the user can't check out with a
  /// not-yet-confirmed address.
  final bool isValidatingAddress;

  /// One-shot failure message from a failed resolve-address call, surfaced by
  /// the screen as a snackbar then cleared — not a persistent form error.
  final String? addressResolveError;
  final bool isOrderingForSomeoneElse;
  final String recipientAddress;
  final String recipientPhone;
  final String preparationInstructions;
  final List<PreparationSuggestionEntity> suggestions;
  final bool isLoadingSuggestions;
  final double subtotal;
  final double deliveryFee;
  final double vat;
  final double grandTotal;
  final bool isLoggedIn;

  /// True right after [CheckoutCubit.prePopulateFromReorder] fills the mode/
  /// address/coordinates from a previous order — drives the reorder banner.
  /// Cleared as soon as the user edits the address or switches mode.
  final bool isPrePopulated;

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
    this.addressOutOfZone = false,
    this.deliveryZoneName,
    this.isValidatingAddress = false,
    this.addressResolveError,
    this.isOrderingForSomeoneElse = false,
    this.recipientAddress = '',
    this.recipientPhone = '',
    this.preparationInstructions = '',
    this.suggestions = const [],
    this.isLoadingSuggestions = false,
    this.subtotal = 0,
    this.deliveryFee = 0,
    this.vat = 0,
    this.grandTotal = 0,
    this.isLoggedIn = false,
    this.isPrePopulated = false,
  });

  bool get isFormValid {
    if (selectedMode == DeliveryMode.takeout) return true;
    if (isOrderingForSomeoneElse) {
      return recipientAddress.isNotEmpty && recipientPhone.isNotEmpty;
    }
    return deliveryAddress.trim().isNotEmpty &&
        addressVerified &&
        !addressOutOfZone &&
        !isValidatingAddress;
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
    List<AddressSuggestionModel>? addressSuggestions,
    bool? isSearchingAddress,
    bool? showSuggestions,
    bool? addressVerified,
    bool? addressOutOfZone,
    String? deliveryZoneName,
    bool clearDeliveryZoneName = false,
    bool? isValidatingAddress,
    String? addressResolveError,
    bool clearAddressResolveError = false,
    bool? isOrderingForSomeoneElse,
    String? recipientAddress,
    String? recipientPhone,
    String? preparationInstructions,
    List<PreparationSuggestionEntity>? suggestions,
    bool? isLoadingSuggestions,
    double? subtotal,
    double? deliveryFee,
    double? vat,
    double? grandTotal,
    bool? isLoggedIn,
    bool? isPrePopulated,
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
      addressOutOfZone: addressOutOfZone ?? this.addressOutOfZone,
      deliveryZoneName: clearDeliveryZoneName
          ? null
          : (deliveryZoneName ?? this.deliveryZoneName),
      isValidatingAddress: isValidatingAddress ?? this.isValidatingAddress,
      addressResolveError: clearAddressResolveError
          ? null
          : (addressResolveError ?? this.addressResolveError),
      isOrderingForSomeoneElse:
          isOrderingForSomeoneElse ?? this.isOrderingForSomeoneElse,
      recipientAddress: recipientAddress ?? this.recipientAddress,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      preparationInstructions:
          preparationInstructions ?? this.preparationInstructions,
      suggestions: suggestions ?? this.suggestions,
      isLoadingSuggestions: isLoadingSuggestions ?? this.isLoadingSuggestions,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      vat: vat ?? this.vat,
      grandTotal: grandTotal ?? this.grandTotal,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isPrePopulated: isPrePopulated ?? this.isPrePopulated,
    );
  }
}
