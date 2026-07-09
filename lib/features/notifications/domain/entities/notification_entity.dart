import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/formatters.dart';

class NotificationEntity {
  final String id;
  final String recipientId;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  const NotificationEntity({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.data = const {},
  });

  bool get isOrderStatus => type == 'ORDER_STATUS';

  String get displayTime {
    final now = DateTime.now();
    final isToday =
        createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
    if (isToday) return formatTime(createdAt);

    final yesterday = now.subtract(const Duration(days: 1));
    final isYesterday =
        createdAt.year == yesterday.year &&
        createdAt.month == yesterday.month &&
        createdAt.day == yesterday.day;
    if (isYesterday) return AppStrings.yesterday;

    return formatDate(createdAt.toIso8601String());
  }

  NotificationEntity copyWith({bool? isRead}) => NotificationEntity(
    id: id,
    recipientId: recipientId,
    type: type,
    title: title,
    body: body,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
    data: data,
  );
}
