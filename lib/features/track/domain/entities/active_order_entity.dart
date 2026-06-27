import '../enums/order_tracking_status.dart';
import 'rider_summary.dart';
import 'sub_order_summary.dart';

class ActiveOrderEntity {
  final String orderId;
  final String deliveryCode;
  final OrderTrackingStatus status;
  final int? estimatedMinutes;
  final List<SubOrderSummary> subOrders;
  final RiderSummary? rider;

  const ActiveOrderEntity({
    required this.orderId,
    required this.deliveryCode,
    required this.status,
    this.estimatedMinutes,
    required this.subOrders,
    this.rider,
  });

  ActiveOrderEntity copyWith({
    OrderTrackingStatus? status,
    int? estimatedMinutes,
    List<SubOrderSummary>? subOrders,
    RiderSummary? rider,
  }) {
    return ActiveOrderEntity(
      orderId: orderId,
      deliveryCode: deliveryCode,
      status: status ?? this.status,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      subOrders: subOrders ?? this.subOrders,
      rider: rider ?? this.rider,
    );
  }
}
