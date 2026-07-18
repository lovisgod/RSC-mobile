import '../../../track/data/models/order_event_model.dart';
import '../../../track/data/models/rider_info_model.dart';
import '../../../track/data/models/rider_location_model.dart';
import '../../domain/entities/order_history_entity.dart';
import 'line_item_model.dart';
import 'order_summary_model.dart';
import 'sub_order_model.dart';

class OrderDetailModel {
  final OrderSummaryModel order;
  final List<SubOrderModel> subOrders;
  final List<LineItemModel> lineItems;
  final List<OrderEventModel> events;
  final RiderInfoModel? rider;
  final RiderLocationModel? latestRiderLocation;

  const OrderDetailModel({
    required this.order,
    required this.subOrders,
    required this.lineItems,
    required this.events,
    this.rider,
    this.latestRiderLocation,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    final riderJson = json['rider'] as Map<String, dynamic>?;
    final riderLocationJson =
        json['latestRiderLocation'] as Map<String, dynamic>?;

    return OrderDetailModel(
      // Confirmed shape: the detail endpoint always nests the master order
      // under data.order.
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
      rider: riderJson != null ? RiderInfoModel.fromJson(riderJson) : null,
      latestRiderLocation: riderLocationJson != null
          ? RiderLocationModel.fromJson(riderLocationJson)
          : null,
    );
  }

  OrderHistoryEntity toEntity() => order.toEntity(
    subOrders: subOrders.map((s) => s.toEntity()).toList(),
    lineItems: lineItems.map((l) => l.toEntity()).toList(),
    events: events.map((e) => e.toEntity()).toList(),
    rider: rider?.toEntity(),
    latestRiderLocation: latestRiderLocation?.toEntity(),
  );
}
