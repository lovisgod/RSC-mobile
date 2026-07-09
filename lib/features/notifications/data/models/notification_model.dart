import '../../domain/entities/notification_entity.dart';

class NotificationModel {
  final String id;
  final String recipientId;
  final String type;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic> data;

  const NotificationModel({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
    this.data = const {},
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String? ?? '',
      recipientId: json['recipientId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      isRead: json['isRead'] as bool? ?? false,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      data: (json['data'] as Map<String, dynamic>?) ?? const {},
    );
  }

  NotificationEntity toEntity() => NotificationEntity(
    id: id,
    recipientId: recipientId,
    type: type,
    title: title,
    body: body,
    isRead: isRead,
    createdAt: createdAt,
    data: data,
  );
}
