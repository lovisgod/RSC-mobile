import 'order_line_item.dart';

class SubOrder {
  final String id;
  final String masterOrderId;
  final String outletId;
  final String outletName;
  // PENDING | ACCEPTED | PREPARING | READY | COLLECTED | DISPATCHED
  final String status;
  final double subtotal;
  final List<OrderLineItem> lineItems;

  const SubOrder({
    required this.id,
    required this.masterOrderId,
    required this.outletId,
    required this.outletName,
    required this.status,
    required this.subtotal,
    required this.lineItems,
  });
}
