import '../../domain/entities/order_history_entity.dart';

class OrderHistoryState {
  final List<OrderHistoryEntity> orders;
  final bool isLoading;
  final String? error;
  final OrderHistoryEntity? selectedOrder;
  final bool isLoadingDetail;

  const OrderHistoryState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.selectedOrder,
    this.isLoadingDetail = false,
  });

  OrderHistoryState copyWith({
    List<OrderHistoryEntity>? orders,
    bool? isLoading,
    String? error,
    bool clearError = false,
    OrderHistoryEntity? selectedOrder,
    bool clearSelectedOrder = false,
    bool? isLoadingDetail,
  }) => OrderHistoryState(
    orders: orders ?? this.orders,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    selectedOrder: clearSelectedOrder
        ? null
        : (selectedOrder ?? this.selectedOrder),
    isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
  );
}
