import 'package:collection/collection.dart';

import '../../../checkout/data/models/address_suggestion_model.dart';
import '../../domain/entities/delivery_address_entity.dart';

class AddressState {
  final List<DeliveryAddressEntity> addresses;
  final bool isLoading;
  final bool isSubmitting;
  final String? settingDefaultId;
  final String? error;

  /// True while the bottom sheet's backend validate-address check is in
  /// flight for the address about to be saved.
  final bool isValidatingAddress;

  /// Zone name from the backend when the address-being-composed is
  /// deliverable (e.g. "Banana Island"). Null when not yet validated or
  /// out of zone.
  final String? deliveryZoneName;

  /// True when the backend reported the address-being-composed as
  /// non-deliverable. Doesn't block saving — only checkout delivery cares.
  final bool addressOutOfZone;

  /// Address-line autocomplete suggestions, from [AddressSuggestionModel].
  final List<AddressSuggestionModel> addressSuggestions;
  final bool isSearchingAddress;
  final bool showSuggestions;

  /// Coordinates from the last resolved suggestion — submitted with the
  /// create/update request in place of the old placeholder lat/lng.
  final double? selectedLatitude;
  final double? selectedLongitude;

  /// Address line/city/state auto-populated from the resolve-address
  /// response — the form never asks the user to type these once a
  /// suggestion is resolved.
  final String? resolvedAddressLine;
  final String? resolvedCity;
  final String? resolvedState;

  /// One-shot failure message from a failed resolve-address call, surfaced
  /// by the sheet as a snackbar then cleared.
  final String? addressResolveError;

  const AddressState({
    this.addresses = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.settingDefaultId,
    this.error,
    this.isValidatingAddress = false,
    this.deliveryZoneName,
    this.addressOutOfZone = false,
    this.addressSuggestions = const [],
    this.isSearchingAddress = false,
    this.showSuggestions = false,
    this.selectedLatitude,
    this.selectedLongitude,
    this.resolvedAddressLine,
    this.resolvedCity,
    this.resolvedState,
    this.addressResolveError,
  });

  DeliveryAddressEntity? get defaultAddress =>
      addresses.firstWhereOrNull((a) => a.isDefault);

  AddressState copyWith({
    List<DeliveryAddressEntity>? addresses,
    bool? isLoading,
    bool? isSubmitting,
    String? settingDefaultId,
    bool clearSettingDefaultId = false,
    String? error,
    bool? isValidatingAddress,
    String? deliveryZoneName,
    bool clearDeliveryZoneName = false,
    bool? addressOutOfZone,
    List<AddressSuggestionModel>? addressSuggestions,
    bool? isSearchingAddress,
    bool? showSuggestions,
    double? selectedLatitude,
    double? selectedLongitude,
    String? resolvedAddressLine,
    String? resolvedCity,
    String? resolvedState,
    String? addressResolveError,
    bool clearAddressResolveError = false,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      settingDefaultId: clearSettingDefaultId
          ? null
          : (settingDefaultId ?? this.settingDefaultId),
      error: error,
      isValidatingAddress: isValidatingAddress ?? this.isValidatingAddress,
      deliveryZoneName: clearDeliveryZoneName
          ? null
          : (deliveryZoneName ?? this.deliveryZoneName),
      addressOutOfZone: addressOutOfZone ?? this.addressOutOfZone,
      addressSuggestions: addressSuggestions ?? this.addressSuggestions,
      isSearchingAddress: isSearchingAddress ?? this.isSearchingAddress,
      showSuggestions: showSuggestions ?? this.showSuggestions,
      selectedLatitude: selectedLatitude ?? this.selectedLatitude,
      selectedLongitude: selectedLongitude ?? this.selectedLongitude,
      resolvedAddressLine: resolvedAddressLine ?? this.resolvedAddressLine,
      resolvedCity: resolvedCity ?? this.resolvedCity,
      resolvedState: resolvedState ?? this.resolvedState,
      addressResolveError: clearAddressResolveError
          ? null
          : (addressResolveError ?? this.addressResolveError),
    );
  }
}
