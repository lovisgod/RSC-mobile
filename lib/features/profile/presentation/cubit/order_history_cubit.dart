import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/usecases/get_order_by_id_usecase.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import 'order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  OrderHistoryCubit(this._getOrdersUseCase, this._getOrderByIdUseCase)
    : super(const OrderHistoryState());

  final GetOrdersUseCase _getOrdersUseCase;
  final GetOrderByIdUseCase _getOrderByIdUseCase;

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

  void startReorder(String orderId) {
    emit(state.copyWith(isReordering: true, reorderingOrderId: orderId));
  }

  void finishReorder() {
    emit(state.copyWith(isReordering: false, clearReorderingOrderId: true));
  }
}
