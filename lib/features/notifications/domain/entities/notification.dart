class AppNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String? orderId;
  final bool isRead;
  final String createdAt; // ISO 8601

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.orderId,
    required this.isRead,
    required this.createdAt,
  });
}
