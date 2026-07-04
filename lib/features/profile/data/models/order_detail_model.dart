import '../../../track/data/models/order_event_model.dart';
import '../../domain/entities/order_history_entity.dart';
import 'line_item_model.dart';
import 'order_summary_model.dart';
import 'sub_order_model.dart';

class OrderDetailModel {
  final OrderSummaryModel order;
  final List<SubOrderModel> subOrders;
  final List<LineItemModel> lineItems;
  final List<OrderEventModel> events;

  const OrderDetailModel({
    required this.order,
    required this.subOrders,
    required this.lineItems,
    required this.events,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      order: OrderSummaryModel.fromJson(
        json['order'] as Map<String, dynamic>? ?? {},
      ),
      subOrders: ((json['subOrders'] as List?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(SubOrderModel.fromJson)
          .toList(),
      lineItems: ((json['lineItems'] as List?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(LineItemModel.fromJson)
          .toList(),
      events: ((json['events'] as List?) ?? [])
          .whereType<Map<String, dynamic>>()
          .map(OrderEventModel.fromJson)
          .toList(),
    );
  }

  OrderHistoryEntity toEntity() => order.toEntity(
    subOrders: subOrders.map((s) => s.toEntity()).toList(),
    lineItems: lineItems.map((l) => l.toEntity()).toList(),
    events: events.map((e) => e.toEntity()).toList(),
  );
}
