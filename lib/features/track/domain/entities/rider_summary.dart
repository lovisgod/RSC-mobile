import '../enums/order_tracking_status.dart';

class RiderSummary {
  final String name;
  final double rating;
  final String partnerType;
  final RiderActiveStatus activeStatus;

  const RiderSummary({
    required this.name,
    required this.rating,
    required this.partnerType,
    required this.activeStatus,
  });

  RiderSummary copyWith({RiderActiveStatus? activeStatus}) => RiderSummary(
        name: name,
        rating: rating,
        partnerType: partnerType,
        activeStatus: activeStatus ?? this.activeStatus,
      );
}
