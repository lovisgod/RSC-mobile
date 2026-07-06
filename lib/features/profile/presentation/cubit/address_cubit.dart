import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/exceptions.dart';
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

  AddressCubit(
    this._getAddressesUseCase,
    this._createAddressUseCase,
    this._updateAddressUseCase,
    this._deleteAddressUseCase,
    this._setDefaultAddressUseCase,
  ) : super(const AddressState());

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
