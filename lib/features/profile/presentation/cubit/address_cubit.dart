import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/exceptions.dart';
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

  AddressCubit(
    this._getAddressesUseCase,
    this._createAddressUseCase,
    this._updateAddressUseCase,
    this._deleteAddressUseCase,
    this._setDefaultAddressUseCase,
    this._validateAddressUseCase,
  ) : super(const AddressState());

  /// Checks the backend delivery zone for the coordinates about to be saved
  /// (the bottom sheet calls this once when it opens, since there's no live
  /// geocoding on the manual address form yet — see
  /// CreateAddressRequestModel's placeholder lat/lng). Doesn't block saving;
  /// it's purely informational feedback shown in the sheet.
  Future<void> validateAddress(double latitude, double longitude) async {
    emit(
      state.copyWith(isValidatingAddress: true, clearDeliveryZoneName: true),
    );
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
}
