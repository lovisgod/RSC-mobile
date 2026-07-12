import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/exceptions.dart';
import '../../data/models/reorder_response_model.dart';
import '../../domain/usecases/get_order_by_id_usecase.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/usecases/reorder_usecase.dart';
import 'order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  OrderHistoryCubit(
    this._getOrdersUseCase,
    this._getOrderByIdUseCase,
    this._reorderUseCase,
  ) : super(const OrderHistoryState());

  final GetOrdersUseCase _getOrdersUseCase;
  final GetOrderByIdUseCase _getOrderByIdUseCase;
  final ReorderUseCase _reorderUseCase;

  Future<void> loadOrders() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final orders = await _getOrdersUseCase();
      emit(state.copyWith(orders: orders, isLoading: false));
    } on AuthException catch (e) {
      emit(state.copyWith(orders: [], isLoading: false, error: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Failed to load orders. Please try again.',
        ),
      );
    }
  }

  Future<void> loadOrderDetail(String orderId) async {
    emit(state.copyWith(isLoadingDetail: true, clearError: true));
    try {
      final order = await _getOrderByIdUseCase(orderId);
      emit(state.copyWith(selectedOrder: order, isLoadingDetail: false));
    } on AuthException catch (e) {
      emit(state.copyWith(isLoadingDetail: false, error: e.message));
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingDetail: false,
          error: 'Failed to load order details. Please try again.',
        ),
      );
    }
  }

  /// Fetches reorder details for [orderId] from the backend, rebuilds the
  /// cart from them, and returns the response so the caller can pre-fill
  /// checkout with its delivery mode/address/coordinates. Null on failure —
  /// [OrderHistoryState.reorderError] carries the message. The flag lives
  /// here (not on a widget) so it can't get stuck once a card is hidden
  /// — rather than disposed — inside the shell's IndexedStack after
  /// navigating to the Cart tab.
  Future<ReorderResponseModel?> reorder(String orderId) async {
    emit(
      state.copyWith(
        isReordering: true,
        reorderingOrderId: orderId,
        clearReorderError: true,
      ),
    );
    try {
      final result = await _reorderUseCase(orderId);
      emit(state.copyWith(isReordering: false, clearReorderingOrderId: true));
      return result;
    } on AuthException catch (e) {
      emit(
        state.copyWith(
          isReordering: false,
          clearReorderingOrderId: true,
          reorderError: e.message,
        ),
      );
      return null;
    } catch (_) {
      emit(
        state.copyWith(
          isReordering: false,
          clearReorderingOrderId: true,
          reorderError: AppStrings.reorderFailed,
        ),
      );
      return null;
    }
  }
}
