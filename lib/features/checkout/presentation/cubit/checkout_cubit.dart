import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/nominatim_result.dart';
import '../../../../core/services/nominatim_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../profile/domain/entities/delivery_address_entity.dart';
import '../../domain/enums/delivery_mode.dart';
import '../../domain/usecases/validate_address_usecase.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(
    this._localStorage,
    this._nominatimService,
    this._validateAddressUseCase,
  ) : super(const CheckoutState());

  final LocalStorage _localStorage;
  final NominatimService _nominatimService;
  final ValidateAddressUseCase _validateAddressUseCase;
  Timer? _debounceTimer;

  static const double _deliveryFeeAmount = 500.0;
  static const double _vatRate = 0.075;
  static const Duration _debounceDuration = Duration(milliseconds: 500);

  Future<void> initCheckout(CartEntity cart) async {
    const deliveryFee = _deliveryFeeAmount;
    final subtotal = cart.subtotal;
    final vat = subtotal * _vatRate;
    final grandTotal = subtotal + deliveryFee + vat;

    emit(
      state.copyWith(
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        vat: vat,
        grandTotal: grandTotal,
      ),
    );

    final user = await _localStorage.getUser();
    emit(state.copyWith(isLoggedIn: user != null));
  }

  void switchMode(DeliveryMode mode) {
    final deliveryFee = mode == DeliveryMode.delivery
        ? _deliveryFeeAmount
        : 0.0;
    final grandTotal = state.subtotal + deliveryFee + state.vat;
    emit(
      state.copyWith(
        selectedMode: mode,
        deliveryFee: deliveryFee,
        grandTotal: grandTotal,
      ),
    );
  }

  /// Called on every keystroke in the delivery address field. Updates the
  /// typed text immediately, then debounces the Nominatim lookup so we don't
  /// exceed its 1 request/second rate limit.
  void onAddressChanged(String query) {
    emit(
      state.copyWith(
        deliveryAddress: query,
        isUsingDefaultAddress: false,
        clearSelectedAddress: true,
        clearCoordinates: true,
        addressVerified: false,
        addressOutOfZone: false,
        clearDeliveryZoneName: true,
        isValidatingAddress: false,
      ),
    );

    _debounceTimer?.cancel();

    if (query.trim().length < 3) {
      emit(
        state.copyWith(addressSuggestions: const [], showSuggestions: false),
      );
      return;
    }

    _debounceTimer = Timer(_debounceDuration, () async {
      emit(state.copyWith(isSearchingAddress: true));
      final results = await _nominatimService.searchAddress(query);
      emit(
        state.copyWith(
          addressSuggestions: results,
          isSearchingAddress: false,
          showSuggestions: results.isNotEmpty,
        ),
      );
    });
  }

  Future<void> selectAddress(NominatimResult result) async {
    emit(
      state.copyWith(
        deliveryAddress: result.shortAddress,
        currentLatitude: result.latitude,
        currentLongitude: result.longitude,
        showSuggestions: false,
        addressSuggestions: const [],
        addressVerified: false,
        addressOutOfZone: false,
        clearDeliveryZoneName: true,
        isValidatingAddress: true,
      ),
    );

    await _validateSelectedAddress(result.latitude, result.longitude);
  }

  void dismissSuggestions() {
    emit(state.copyWith(showSuggestions: false));
  }

  Future<void> useDefaultAddress(DeliveryAddressEntity address) async {
    _debounceTimer?.cancel();
    emit(
      state.copyWith(
        deliveryAddress: address.displayAddress,
        isUsingDefaultAddress: true,
        selectedAddress: address,
        clearCoordinates: true,
        showSuggestions: false,
        addressSuggestions: const [],
        addressVerified: false,
        addressOutOfZone: false,
        clearDeliveryZoneName: true,
        isValidatingAddress: true,
      ),
    );

    await _validateSelectedAddress(address.latitude, address.longitude);
  }

  /// Backend is the single source of truth for the RSC delivery zone — every
  /// address selection (Nominatim pick or saved default) is checked here
  /// before the user can proceed to checkout.
  Future<void> _validateSelectedAddress(double lat, double lng) async {
    final response = await _validateAddressUseCase(lat, lng);
    emit(
      state.copyWith(
        addressVerified: response.deliverable,
        addressOutOfZone: !response.deliverable,
        deliveryZoneName: response.zoneName,
        clearDeliveryZoneName: response.zoneName == null,
        isValidatingAddress: false,
      ),
    );
  }

  void toggleOrderForSomeoneElse(bool value) {
    emit(
      state.copyWith(
        isOrderingForSomeoneElse: value,
        recipientAddress: value ? state.recipientAddress : '',
        recipientName: value ? state.recipientName : '',
      ),
    );
  }

  void updateRecipientAddress(String address) {
    emit(state.copyWith(recipientAddress: address));
  }

  void updateRecipientName(String name) {
    emit(state.copyWith(recipientName: name));
  }

  void updatePreparationInstructions(String instructions) {
    emit(state.copyWith(preparationInstructions: instructions));
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
