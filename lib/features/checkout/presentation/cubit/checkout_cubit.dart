import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/services/address_service.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../cart/domain/entities/cart_entity.dart';
import '../../../home/domain/repositories/home_repository.dart';
import '../../../menu/domain/entities/outlet.dart';
import '../../../profile/data/models/reorder_response_model.dart';
import '../../../profile/domain/entities/delivery_address_entity.dart';
import '../../data/models/address_suggestion_model.dart';
import '../../domain/enums/delivery_mode.dart';
import '../../domain/services/pending_reorder_holder.dart';
import '../../domain/usecases/calculate_delivery_fee_usecase.dart';
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
    this._homeRepository,
    this._calculateDeliveryFeeUseCase,
    this._pendingReorderHolder,
  ) : super(const CheckoutState());

  final LocalStorage _localStorage;
  final AddressService _addressService;
  final ValidateAddressUseCase _validateAddressUseCase;
  final GetPreparationSuggestionsUsecase _getPreparationSuggestionsUsecase;
  final GetPlatformChargesUseCase _getPlatformChargesUseCase;
  final HomeRepository _homeRepository;
  final CalculateDeliveryFeeUseCase _calculateDeliveryFeeUseCase;
  final PendingReorderHolder _pendingReorderHolder;
  Timer? _debounceTimer;
  Timer? _suggestionsDebounceTimer;
  String? _outletId;

  // Outlets in the cart, used to compute the per-outlet delivery fee. Comes
  // from HomeRepository's in-memory cache, so this costs no extra network
  // call in the normal Home → Cart → Checkout flow.
  List<Outlet> _outlets = const [];
  Set<String> _cartOutletIds = const {};

  // These will be overridden by the platform-charges API response. Delivery
  // fee itself is NOT one of these anymore — it's computed per-outlet by
  // _calculateDeliveryFeeUseCase (see _updateTotals).
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

    _cartOutletIds = cart.itemsGroupedByOutlet.keys.toSet();
    try {
      _outlets = await _homeRepository.getOutlets();
    } catch (_) {
      _outlets = const [];
    }

    try {
      final charges = await _getPlatformChargesUseCase();
      _platformCommissionBps = charges.platformCommissionBps;
      _defaultVatBps = charges.defaultVatBps;
      _serviceFeeMinor = charges.serviceFeeMinor;
    } catch (_) {
      // Fallback values if API fails
      _platformCommissionBps = 1000;
    }

    _updateTotals(cart.subtotal, state.selectedMode);

    final pendingReorder = _pendingReorderHolder.consume();
    if (pendingReorder != null) prePopulateFromReorder(pendingReorder);

    await loadSuggestions(cart);
  }

  /// Sums the backend's per-outlet delivery-fee formula (FLAT/PER_KM/
  /// PER_LOCATION) across every outlet in the cart. Before an address is
  /// resolved this is only an estimate for outlets on distance/zone-based
  /// pricing (falls back to their flat fee); it's recomputed with real
  /// coordinates/zone as soon as the address is validated, so the value sent
  /// to /payments/initiate always matches what the backend itself computes.
  int _computeDeliveryFeeMinor(DeliveryMode mode) {
    if (mode == DeliveryMode.takeout || _cartOutletIds.isEmpty) return 0;
    return _calculateDeliveryFeeUseCase(
      outletIds: _cartOutletIds,
      outlets: _outlets,
      deliveryLatitude: state.currentLatitude,
      deliveryLongitude: state.currentLongitude,
      zoneId: state.deliveryZoneId,
      zoneName: state.deliveryZoneName,
    );
  }

  void _updateTotals(double subtotal, DeliveryMode mode) {
    final deliveryFeeMinor = _computeDeliveryFeeMinor(mode);
    final deliveryFee = deliveryFeeMinor / 100.0;
    final serviceFee = _serviceFeeMinor / 100.0;

    // platformCommission = (platformCommissionBps / 10000) * subtotal
    // Included in grandTotal — see CheckoutState.platformCommission doc.
    final platformCommission = (subtotal * _platformCommissionBps / 10000);

    // vat = (defaultVatBps / 10000) * subtotal
    final vat = (subtotal * _defaultVatBps / 10000);

    final grandTotal =
        subtotal + deliveryFee + serviceFee + vat + platformCommission;

    emit(
      state.copyWith(
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        deliveryFeeMinor: deliveryFeeMinor,
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

    // Coordinates must land before _updateTotals runs — the delivery fee is
    // now computed from them (PER_KM/PER_LOCATION outlets), so recomputing
    // before they're set would use stale/absent coordinates.
    emit(
      state.copyWith(
        selectedMode: mode,
        isPrePopulated: true,
        deliveryAddress: reorder.deliveryAddress,
        currentLatitude: reorder.deliveryLatitude,
        currentLongitude: reorder.deliveryLongitude,
        addressVerified: true,
        addressOutOfZone: false,
      ),
    );
    _updateTotals(state.subtotal, mode);
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
    emit(state.copyWith(selectedMode: mode, isPrePopulated: false));
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

  /// Resolves the device's current GPS position to a delivery address via
  /// the backend's raw-input resolve-address path (no autocomplete
  /// suggestion needed), then runs it through the same validate-address
  /// check as any other address selection.
  Future<void> useCurrentLocation() async {
    emit(
      state.copyWith(
        isResolvingCurrentLocation: true,
        showSuggestions: false,
        addressSuggestions: const [],
        isPrePopulated: false,
      ),
    );

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(
          state.copyWith(
            isResolvingCurrentLocation: false,
            addressResolveError: AppStrings.locationServiceDisabled,
          ),
        );
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        emit(
          state.copyWith(
            isResolvingCurrentLocation: false,
            addressResolveError: AppStrings.locationPermissionDenied,
          ),
        );
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final resolved = await _addressService.resolveCurrentLocation(
        position.latitude,
        position.longitude,
      );
      if (resolved == null) {
        emit(
          state.copyWith(
            isResolvingCurrentLocation: false,
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
          isResolvingCurrentLocation: false,
          addressVerified: false,
          addressOutOfZone: false,
          clearDeliveryZoneName: true,
          isValidatingAddress: true,
        ),
      );

      await _validateSelectedAddress(resolved.latitude, resolved.longitude);
    } catch (_) {
      emit(
        state.copyWith(
          isResolvingCurrentLocation: false,
          addressResolveError: AppStrings.couldNotGetCurrentLocation,
        ),
      );
    }
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
        // Saved addresses carry the coordinates resolved when they were
        // created — they ARE the address pipeline's output for this pick.
        currentLatitude: address.latitude,
        currentLongitude: address.longitude,
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
        deliveryZoneId: response.zoneId,
        clearDeliveryZoneId: response.zoneId == null,
        isValidatingAddress: false,
      ),
    );
    // Coordinates/zone are only known for certain once validated — recompute
    // the delivery fee now so PER_KM/PER_LOCATION outlets get their real
    // fee instead of the pre-address estimate.
    _updateTotals(state.subtotal, state.selectedMode);
  }

  void toggleOrderForSomeoneElse(bool value) {
    emit(
      state.copyWith(
        isOrderingForSomeoneElse: value,
        recipientPhone: value ? state.recipientPhone : '',
      ),
    );
  }

  void updateRecipientPhone(String phone) {
    emit(state.copyWith(recipientPhone: phone));
  }

  void updateLandmark(String landmark) {
    emit(state.copyWith(landmark: landmark));
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
