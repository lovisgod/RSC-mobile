import 'package:collection/collection.dart';

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

  const AddressState({
    this.addresses = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.settingDefaultId,
    this.error,
    this.isValidatingAddress = false,
    this.deliveryZoneName,
    this.addressOutOfZone = false,
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
    );
  }
}
