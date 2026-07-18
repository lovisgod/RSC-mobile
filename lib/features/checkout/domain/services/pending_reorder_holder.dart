import '../../../profile/data/models/reorder_response_model.dart';

/// Bridges reorder data across the gap between "reorder succeeded, still on
/// the Cart tab" and "user tapped Proceed to Checkout, a new CheckoutCubit
/// was just created" — CheckoutCubit is a `registerFactory`, so a fresh
/// instance is built per checkout visit and can't be pre-filled directly at
/// reorder time. Registered as a singleton; staged by the reorder trigger
/// points, consumed once by CheckoutCubit.initCheckout().
class PendingReorderHolder {
  ReorderResponseModel? _pending;

  void stage(ReorderResponseModel reorder) => _pending = reorder;

  /// Reads and clears in one step so it's applied at most once.
  ReorderResponseModel? consume() {
    final value = _pending;
    _pending = null;
    return value;
  }
}
