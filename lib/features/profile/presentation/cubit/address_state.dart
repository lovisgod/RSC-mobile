import 'package:collection/collection.dart';

import '../../domain/entities/delivery_address_entity.dart';

class AddressState {
  final List<DeliveryAddressEntity> addresses;
  final bool isLoading;
  final bool isSubmitting;
  final String? settingDefaultId;
  final String? error;

  const AddressState({
    this.addresses = const [],
    this.isLoading = false,
    this.isSubmitting = false,
    this.settingDefaultId,
    this.error,
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
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      settingDefaultId: clearSettingDefaultId
          ? null
          : (settingDefaultId ?? this.settingDefaultId),
      error: error,
    );
  }
}
