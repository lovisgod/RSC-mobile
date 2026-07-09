import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/address_service.dart';
import '../../../checkout/data/models/address_suggestion_model.dart';
import '../../../checkout/domain/usecases/validate_address_usecase.dart';
import '../../data/models/create_address_request_model.dart';
import '../../domain/entities/delivery_address_entity.dart';
import '../../domain/usecases/create_address_usecase.dart';
import '../../domain/usecases/delete_address_usecase.dart';
import '../../domain/usecases/get_addresses_usecase.dart';
import '../../domain/usecases/set_default_address_usecase.dart';
import '../../domain/usecases/update_address_usecase.dart';
import 'address_state.dart';

class AddressCubit extends Cubit<AddressState> {
  final GetAddressesUseCase _getAddressesUseCase;
  final CreateAddressUseCase _createAddressUseCase;
  final UpdateAddressUseCase _updateAddressUseCase;
  final DeleteAddressUseCase _deleteAddressUseCase;
  final SetDefaultAddressUseCase _setDefaultAddressUseCase;
  final ValidateAddressUseCase _validateAddressUseCase;
  final AddressService _addressService;
  Timer? _debounceTimer;

  static const Duration _debounceDuration = Duration(milliseconds: 500);

  AddressCubit(
    this._getAddressesUseCase,
    this._createAddressUseCase,
    this._updateAddressUseCase,
    this._deleteAddressUseCase,
    this._setDefaultAddressUseCase,
    this._validateAddressUseCase,
    this._addressService,
  ) : super(const AddressState());

  /// Checks the backend delivery zone for the coordinates about to be saved
  /// (the bottom sheet calls this once when it opens, for an existing
  /// address, or after a suggestion is resolved). Doesn't block saving;
  /// it's purely informational feedback shown in the sheet.
  Future<void> validateAddress(double latitude, double longitude) async {
    emit(
      state.copyWith(isValidatingAddress: true, clearDeliveryZoneName: true),
    );
    await _validateSelectedAddress(latitude, longitude);
  }

  /// Called on every keystroke in the address-line field. Updates the typed
  /// text immediately upstream (via the widget's own controller) and
  /// debounces the suggestions lookup.
  void onAddressLineChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().length < 3) {
      emit(
        state.copyWith(addressSuggestions: const [], showSuggestions: false),
      );
      return;
    }

    _debounceTimer = Timer(_debounceDuration, () async {
      emit(state.copyWith(isSearchingAddress: true));
      final results = await _addressService.searchAddress(query);
      emit(
        state.copyWith(
          addressSuggestions: results,
          isSearchingAddress: false,
          showSuggestions: results.isNotEmpty,
        ),
      );
    });
  }

  void dismissSuggestions() {
    emit(state.copyWith(showSuggestions: false));
  }

  Future<void> selectAddressSuggestion(
    AddressSuggestionModel suggestion,
  ) async {
    emit(
      state.copyWith(
        isValidatingAddress: true,
        showSuggestions: false,
        addressSuggestions: const [],
        clearDeliveryZoneName: true,
      ),
    );

    final resolved = await _addressService.resolveAddress(suggestion);
    if (resolved == null) {
      emit(
        state.copyWith(
          isValidatingAddress: false,
          addressResolveError: AppStrings.couldNotResolveAddress,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        resolvedAddressLine: resolved.addressLine,
        resolvedCity: resolved.city,
        resolvedState: resolved.state,
        selectedLatitude: resolved.latitude,
        selectedLongitude: resolved.longitude,
      ),
    );

    await _validateSelectedAddress(resolved.latitude, resolved.longitude);
  }

  void consumeAddressResolveError() {
    emit(state.copyWith(clearAddressResolveError: true));
  }

  Future<void> _validateSelectedAddress(
    double latitude,
    double longitude,
  ) async {
    final response = await _validateAddressUseCase(latitude, longitude);
    emit(
      state.copyWith(
        isValidatingAddress: false,
        addressOutOfZone: !response.deliverable,
        deliveryZoneName: response.zoneName,
        clearDeliveryZoneName: response.zoneName == null,
      ),
    );
  }

  Future<void> loadAddresses() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final addresses = await _getAddressesUseCase();
      emit(state.copyWith(addresses: _sorted(addresses), isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: _errorMessage(e)));
    }
  }

  Future<void> createAddress(CreateAddressRequestModel request) async {
    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      await _createAddressUseCase(request);
      await loadAddresses();
      emit(state.copyWith(isSubmitting: false));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: _errorMessage(e)));
    }
  }

  Future<void> updateAddress(
    String id,
    CreateAddressRequestModel request,
  ) async {
    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      await _updateAddressUseCase(id, request);
      await loadAddresses();
      emit(state.copyWith(isSubmitting: false));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: _errorMessage(e)));
    }
  }

  Future<void> deleteAddress(String id) async {
    emit(state.copyWith(isSubmitting: true, error: null));
    try {
      await _deleteAddressUseCase(id);
      final updated = state.addresses.where((a) => a.id != id).toList();
      emit(state.copyWith(addresses: updated, isSubmitting: false));
    } catch (e) {
      emit(state.copyWith(isSubmitting: false, error: _errorMessage(e)));
    }
  }

  Future<void> setDefaultAddress(String id) async {
    emit(state.copyWith(settingDefaultId: id, error: null));
    try {
      await _setDefaultAddressUseCase(id);
      final updated = state.addresses
          .map((a) => a.copyWith(isDefault: a.id == id))
          .toList();
      emit(state.copyWith(addresses: updated, clearSettingDefaultId: true));
    } catch (e) {
      emit(
        state.copyWith(clearSettingDefaultId: true, error: _errorMessage(e)),
      );
    }
  }

  List<DeliveryAddressEntity> _sorted(List<DeliveryAddressEntity> addresses) {
    final sorted = [...addresses];
    sorted.sort((a, b) {
      if (a.isDefault != b.isDefault) return a.isDefault ? -1 : 1;
      return b.createdAt.compareTo(a.createdAt);
    });
    return sorted;
  }

  String _errorMessage(Object e) => e is AuthException
      ? e.message
      : 'Something went wrong. Please try again.';

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
