// lib/providers/notification_provider.dart

import 'package:flutter/material.dart';
import 'package:notdle/models/notification.dart';

class NotificationProvider with ChangeNotifier {
  List<AppNotification> _notifications = [];
  String _selectedFilter = 'All';

  List<AppNotification> get notifications => _notifications;
  String get selectedFilter => _selectedFilter;

  // Mock data for demonstration
  NotificationProvider() {
    _notifications = [
      // AppNotification(
      //     id: '1',
      //     title: 'New Order Received',
      //     body: 'Order #ORD123 from John Doe has been placed.',
      //     type: 'Order',
      //     timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      //     isRead: false),
      // AppNotification(
      //     id: '2',
      //     title: 'Invoice Sent',
      //     body: 'Invoice for order #INV456 has been sent to Jane Smith.',
      //     type: 'Invoice',
      //     timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      //     isRead: false),
      // AppNotification(
      //     id: '3',
      //     title: 'New Customer',
      //     body: 'Michael is now one of your customers.',
      //     type: 'Customer',
      //     timestamp: DateTime.now().subtract(const Duration(days: 1)),
      //     isRead: true),
      // AppNotification(
      //     id: '4',
      //     title: 'Order Status Updated',
      //     body: 'Order #ORD123 is now in progress.',
      //     type: 'Order',
      //     timestamp: DateTime.now().subtract(const Duration(days: 2)),
      //     isRead: true),
      // AppNotification(
      //     id: '5',
      //     title: 'Payment Received',
      //     body: 'Payment for #INV456 has been completed.',
      //     type: 'Invoice',
      //     timestamp: DateTime.now().subtract(const Duration(days: 2)),
      //     isRead: false),
    ];
  }

  // Method to filter notifications based on type
  List<AppNotification> get filteredNotifications {
    if (_selectedFilter == 'All') {
      return _notifications;
    }
    return _notifications
        .where((notification) => notification.type == _selectedFilter)
        .toList();
  }

  // Method to set the filter and notify listeners
  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  // Method to mark a notification as read
  void markAsRead(String id) {
    final notification = _notifications.firstWhere(
      (element) => element.id == id,
    );
    if (!notification.isRead) {
      notification.isRead = true;
      notifyListeners();
    }
  }

  // Method to get unread count
  int get unreadCount =>
      _notifications.where((notification) => !notification.isRead).length;
}
