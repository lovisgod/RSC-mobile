import 'order_history_line_item.dart';

class OrderHistorySubOrder {
  final String outletName;
  final String outletEmoji;
  final List<OrderHistoryLineItem> items;

  const OrderHistorySubOrder({
    required this.outletName,
    required this.outletEmoji,
    required this.items,
  });
}
