import '../../domain/entities/order_history_entity.dart';

class OrderHistoryState {
  final List<OrderHistoryEntity> orders;

  const OrderHistoryState({this.orders = const []});

  OrderHistoryState copyWith({List<OrderHistoryEntity>? orders}) =>
      OrderHistoryState(orders: orders ?? this.orders);
}
