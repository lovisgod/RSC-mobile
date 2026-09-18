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

  /// Id of the delivery zone, from the backend validate-address response.
  /// Preferred over [deliveryZoneName] when matching an outlet's
  /// `PER_LOCATION` delivery-fee overrides. Null until validated, and while
  /// addressOutOfZone is true.
  final String? deliveryZoneId;

  /// True while the validate-address call for the current selection is in
  /// flight — blocks the proceed button so the user can't check out with a
  /// not-yet-confirmed address.
  final bool isValidatingAddress;

  /// One-shot failure message from a failed resolve-address call, surfaced by
  /// the screen as a snackbar then cleared — not a persistent form error.
  final String? addressResolveError;

  /// True while fetching the device's GPS position and resolving it to an
  /// address — drives the "Use current location" button's spinner.
  final bool isResolvingCurrentLocation;

  /// Optional landmark to help the rider find the address (delivery only).
  final String landmark;
  final bool isOrderingForSomeoneElse;
  final String recipientPhone;
  final String preparationInstructions;
  final List<PreparationSuggestionEntity> suggestions;
  final bool isLoadingSuggestions;
  final double subtotal;
  final double deliveryFee;

  /// Exact delivery fee in minor units, computed per-outlet via
  /// CalculateDeliveryFeeUseCase. This is the single source of truth for the
  /// payment payload — [deliveryFee] is just this divided by 100 for display,
  /// so the two never drift and the backend's strict deliveryFeeMinor
  /// validation always matches what's shown to the user.
  final int deliveryFeeMinor;
  final double vat;

  /// The platform's cut of the outlet's payout — sent to the backend for its
  /// own bookkeeping. The backend's totalMinor validation includes it in
  /// what the customer pays, so it's included in [grandTotal] too (confirmed
  /// against /payments/initiate's "Total mismatch" response).
  final double platformCommission;
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
    this.deliveryZoneId,
    this.isValidatingAddress = false,
    this.addressResolveError,
    this.isResolvingCurrentLocation = false,
    this.landmark = '',
    this.isOrderingForSomeoneElse = false,
    this.recipientPhone = '',
    this.preparationInstructions = '',
    this.suggestions = const [],
    this.isLoadingSuggestions = false,
    this.subtotal = 0,
    this.deliveryFee = 0,
    this.deliveryFeeMinor = 0,
    this.vat = 0,
    this.platformCommission = 0,
    this.grandTotal = 0,
    this.isLoggedIn = false,
    this.isPrePopulated = false,
  });

  /// Minimum digits for a plausible recipient phone number.
  static const int minRecipientPhoneLength = 10;

  /// The delivery always goes to the address the ordering user entered —
  /// "someone else" only adds a recipient phone number on top of it.
  bool get isRecipientPhoneValid =>
      recipientPhone.length >= minRecipientPhoneLength;

  bool get isFormValid {
    if (selectedMode == DeliveryMode.takeout) return true;
    final addressValid =
        deliveryAddress.trim().isNotEmpty &&
        addressVerified &&
        !addressOutOfZone &&
        !isValidatingAddress;
    if (isOrderingForSomeoneElse) {
      return addressValid && isRecipientPhoneValid;
    }
    return addressValid;
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
    String? deliveryZoneId,
    bool clearDeliveryZoneId = false,
    bool? isValidatingAddress,
    String? addressResolveError,
    bool clearAddressResolveError = false,
    bool? isResolvingCurrentLocation,
    String? landmark,
    bool? isOrderingForSomeoneElse,
    String? recipientPhone,
    String? preparationInstructions,
    List<PreparationSuggestionEntity>? suggestions,
    bool? isLoadingSuggestions,
    double? subtotal,
    double? deliveryFee,
    int? deliveryFeeMinor,
    double? vat,
    double? platformCommission,
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
      deliveryZoneId: clearDeliveryZoneId
          ? null
          : (deliveryZoneId ?? this.deliveryZoneId),
      isValidatingAddress: isValidatingAddress ?? this.isValidatingAddress,
      addressResolveError: clearAddressResolveError
          ? null
          : (addressResolveError ?? this.addressResolveError),
      isResolvingCurrentLocation:
          isResolvingCurrentLocation ?? this.isResolvingCurrentLocation,
      landmark: landmark ?? this.landmark,
      isOrderingForSomeoneElse:
          isOrderingForSomeoneElse ?? this.isOrderingForSomeoneElse,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      preparationInstructions:
          preparationInstructions ?? this.preparationInstructions,
      suggestions: suggestions ?? this.suggestions,
      isLoadingSuggestions: isLoadingSuggestions ?? this.isLoadingSuggestions,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      deliveryFeeMinor: deliveryFeeMinor ?? this.deliveryFeeMinor,
      vat: vat ?? this.vat,
      platformCommission: platformCommission ?? this.platformCommission,
      grandTotal: grandTotal ?? this.grandTotal,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isPrePopulated: isPrePopulated ?? this.isPrePopulated,
    );
  }
}
