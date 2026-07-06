import '../../domain/entities/order_history_entity.dart';

class OrderHistoryState {
  final List<OrderHistoryEntity> orders;
  final bool isLoading;
  final String? error;
  final OrderHistoryEntity? selectedOrder;
  final bool isLoadingDetail;

  /// Whether a re-order is currently in flight, and for which order — lives
  /// here (not on the card widget) so the flag survives the card being kept
  /// alive off-screen in the shell's IndexedStack across tab switches.
  final bool isReordering;
  final String? reorderingOrderId;

  const OrderHistoryState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
    this.selectedOrder,
    this.isLoadingDetail = false,
    this.isReordering = false,
    this.reorderingOrderId,
  });

  OrderHistoryState copyWith({
    List<OrderHistoryEntity>? orders,
    bool? isLoading,
    String? error,
    bool clearError = false,
    OrderHistoryEntity? selectedOrder,
    bool clearSelectedOrder = false,
    bool? isLoadingDetail,
    bool? isReordering,
    String? reorderingOrderId,
    bool clearReorderingOrderId = false,
  }) => OrderHistoryState(
    orders: orders ?? this.orders,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    selectedOrder: clearSelectedOrder
        ? null
        : (selectedOrder ?? this.selectedOrder),
    isLoadingDetail: isLoadingDetail ?? this.isLoadingDetail,
    isReordering: isReordering ?? this.isReordering,
    reorderingOrderId: clearReorderingOrderId
        ? null
        : (reorderingOrderId ?? this.reorderingOrderId),
  );
}
