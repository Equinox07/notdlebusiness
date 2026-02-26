// lib/models/notification.dart

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String type; // 'Order', 'Invoice', 'Customer'
  final DateTime timestamp;
  bool isRead;
  final String? companyId;
  final String? userId;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.companyId,
    this.userId,
  });
}
