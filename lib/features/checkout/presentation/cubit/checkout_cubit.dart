import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/address_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../profile/data/models/reorder_response_model.dart';
import '../../../profile/domain/entities/delivery_address_entity.dart';
import '../../data/models/address_suggestion_model.dart';
import '../../domain/enums/delivery_mode.dart';
import '../../domain/services/pending_reorder_holder.dart';
import '../../domain/usecases/get_platform_charges_usecase.dart';
import '../../domain/usecases/get_preparation_suggestions_usecase.dart';
import '../../domain/usecases/validate_address_usecase.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit(
    this._localStorage,
    this._addressService,
    this._validateAddressUseCase,
    this._getPreparationSuggestionsUsecase,
    this._getPlatformChargesUseCase,
    this._pendingReorderHolder,
  ) : super(const CheckoutState());

  final LocalStorage _localStorage;
  final AddressService _addressService;
  final ValidateAddressUseCase _validateAddressUseCase;
  final GetPreparationSuggestionsUsecase _getPreparationSuggestionsUsecase;
  final GetPlatformChargesUseCase _getPlatformChargesUseCase;
  final PendingReorderHolder _pendingReorderHolder;
  Timer? _debounceTimer;
  Timer? _suggestionsDebounceTimer;
  String? _outletId;

  // These will be overridden by the platform-charges API response.
  double _deliveryFeeAmount = 0.0;
  int _platformCommissionBps = 0;
  int _defaultVatBps = 0;
  int _serviceFeeMinor = 0;

  static const Duration _debounceDuration = Duration(milliseconds: 500);
  static const Duration _suggestionsDebounceDuration = Duration(
    milliseconds: 400,
  );

  Future<void> initCheckout(CartEntity cart) async {
    final user = await _localStorage.getUser();
    emit(state.copyWith(isLoggedIn: user != null));

    try {
      final charges = await _getPlatformChargesUseCase();
      _deliveryFeeAmount = charges.deliveryFeeMinor / 100.0;
      _platformCommissionBps = charges.platformCommissionBps;
      _defaultVatBps = charges.defaultVatBps;
      _serviceFeeMinor = charges.serviceFeeMinor;
    } catch (_) {
      // Fallback values if API fails
      _deliveryFeeAmount = 1500.0;
      _platformCommissionBps = 1000;
    }

    _updateTotals(cart.subtotal, state.selectedMode);

    final pendingReorder = _pendingReorderHolder.consume();
    if (pendingReorder != null) prePopulateFromReorder(pendingReorder);

    await loadSuggestions(cart);
  }

  void _updateTotals(double subtotal, DeliveryMode mode) {
    final isDelivery = mode == DeliveryMode.delivery;
    final deliveryFee = isDelivery ? _deliveryFeeAmount : 0.0;
    final serviceFee = _serviceFeeMinor / 100.0;

    // platformCommission = (platformCommissionBps / 10000) * subtotal
    final platformCommission = (subtotal * _platformCommissionBps / 10000);

    // vat = (defaultVatBps / 10000) * subtotal
    final vat = (subtotal * _defaultVatBps / 10000);

    final grandTotal =
        subtotal + deliveryFee + serviceFee + vat + platformCommission;

    emit(
      state.copyWith(
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        vat: vat,
        platformCommission: platformCommission,
        grandTotal: grandTotal,
      ),
    );
  }

  /// Fills mode/address/coordinates from a previous order right as checkout
  /// opens. Coordinates came from a previously successful order, so they're
  /// treated as already verified — no need to re-hit the validate-address
  /// endpoint before the user can proceed.
  void prePopulateFromReorder(ReorderResponseModel reorder) {
    final mode = reorder.deliveryMode == 'TAKEOUT'
        ? DeliveryMode.takeout
        : DeliveryMode.delivery;

    emit(state.copyWith(selectedMode: mode, isPrePopulated: true));
    _updateTotals(state.subtotal, mode);

    emit(
      state.copyWith(
        deliveryAddress: reorder.deliveryAddress,
        currentLatitude: reorder.deliveryLatitude,
        currentLongitude: reorder.deliveryLongitude,
        addressVerified: true,
        addressOutOfZone: false,
      ),
    );
  }

  Future<void> loadSuggestions(CartEntity cart) async {
    if (cart.items.isEmpty) return;
    _outletId = cart.items.first.outletId;

    emit(state.copyWith(isLoadingSuggestions: true));
    final suggestions = await _getPreparationSuggestionsUsecase(_outletId!);
    emit(state.copyWith(suggestions: suggestions, isLoadingSuggestions: false));
  }

  /// Called on every keystroke in the preparation-instructions field.
  /// Debounced so we don't fire an API call per keystroke.
  void filterSuggestions(String query) {
    _suggestionsDebounceTimer?.cancel();

    final outletId = _outletId;
    if (outletId == null) return;

    if (query.trim().length < 2) {
      _suggestionsDebounceTimer = Timer(_suggestionsDebounceDuration, () async {
        final suggestions = await _getPreparationSuggestionsUsecase(outletId);
        emit(state.copyWith(suggestions: suggestions));
      });
      return;
    }

    _suggestionsDebounceTimer = Timer(_suggestionsDebounceDuration, () async {
      final suggestions = await _getPreparationSuggestionsUsecase(
        outletId,
        q: query,
      );
      emit(state.copyWith(suggestions: suggestions));
    });
  }

  void switchMode(DeliveryMode mode) {
    emit(
      state.copyWith(
        selectedMode: mode,
        isPrePopulated: false,
      ),
    );
    _updateTotals(state.subtotal, mode);
  }

  /// Called on every keystroke in the delivery address field. Updates the
  /// typed text immediately, then debounces the address-suggestions lookup.
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
        isPrePopulated: false,
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

  Future<void> selectAddress(AddressSuggestionModel suggestion) async {
    emit(
      state.copyWith(
        showSuggestions: false,
        addressSuggestions: const [],
        addressVerified: false,
        addressOutOfZone: false,
        clearDeliveryZoneName: true,
        isValidatingAddress: true,
        isPrePopulated: false,
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
        deliveryAddress: resolved.displayName,
        currentLatitude: resolved.latitude,
        currentLongitude: resolved.longitude,
      ),
    );

    await _validateSelectedAddress(resolved.latitude, resolved.longitude);
  }

  void consumeAddressResolveError() {
    emit(state.copyWith(clearAddressResolveError: true));
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
        isPrePopulated: false,
      ),
    );

    await _validateSelectedAddress(address.latitude, address.longitude);
  }

  /// Backend is the single source of truth for the RSC delivery zone — every
  /// address selection (autocomplete pick or saved default) is checked here
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
        recipientPhone: value ? state.recipientPhone : '',
      ),
    );
  }

  void updateRecipientAddress(String address) {
    emit(state.copyWith(recipientAddress: address));
  }

  void updateRecipientPhone(String phone) {
    emit(state.copyWith(recipientPhone: phone));
  }

  void updatePreparationInstructions(String instructions) {
    emit(state.copyWith(preparationInstructions: instructions));
  }

  /// Guards the payment-initiate call: takeout carries no address so it's
  /// always valid; delivery requires a minimally plausible address, since the
  /// backend rejects a deliveryAddress shorter than 5 characters.
  String? validateBeforePayment() {
    if (state.selectedMode == DeliveryMode.takeout) return null;
    if (state.deliveryAddress.trim().length < 5) {
      return AppStrings.pleaseEnterValidDeliveryAddress;
    }
    return null;
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    _suggestionsDebounceTimer?.cancel();
    return super.close();
  }
}
