import '../enums/order_tracking_status.dart';

class SubOrderSummary {
  final String outletEmoji;
  final String outletName;
  final List<String> itemSummaries;
  final SubOrderStatus status;

  const SubOrderSummary({
    required this.outletEmoji,
    required this.outletName,
    required this.itemSummaries,
    required this.status,
  });

  SubOrderSummary copyWith({SubOrderStatus? status}) => SubOrderSummary(
        outletEmoji: outletEmoji,
        outletName: outletName,
        itemSummaries: itemSummaries,
        status: status ?? this.status,
      );
}
