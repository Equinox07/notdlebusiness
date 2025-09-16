// lib/screens/notification_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:notdle/providers/notification_provider.dart';
import 'package:notdle/models/notification.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  static const String tag = "notifications";

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<NotificationProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          'Notifications',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement mark all as read
            },
            child: Text(
              'Mark all as read',
              style: GoogleFonts.poppins(
                color: Colors.indigo.shade600,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter Buttons
          _buildFilterChips(context, provider),

          // Notification List
          Expanded(
            child: ListView.separated(
              itemCount: provider.filteredNotifications.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: Colors.black12,
              ),
              itemBuilder: (context, index) {
                final notification = provider.filteredNotifications[index];
                return _buildNotificationTile(context, notification);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips(
      BuildContext context, NotificationProvider provider) {
    final filterOptions = ['All', 'Order', 'Invoice', 'Customer'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: filterOptions.map((filter) {
          final isSelected = provider.selectedFilter == filter;
          return FilterChip(
            label: Text(filter, style: GoogleFonts.poppins()),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                provider.setFilter(filter);
              }
            },
            backgroundColor: Colors.grey.shade200,
            selectedColor: Colors.indigo.shade100,
            checkmarkColor: Colors.indigo.shade600,
            labelStyle: GoogleFonts.poppins(
              color: isSelected ? Colors.indigo.shade600 : Colors.black87,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: isSelected
                  ? BorderSide(color: Colors.indigo.shade600)
                  : BorderSide.none,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNotificationTile(
      BuildContext context, AppNotification notification) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: notification.isRead ? Colors.white : Colors.indigo.shade50,
      child: ListTile(
        onTap: () {
          // TODO: Navigate to the relevant screen (order details, etc.)
          Provider.of<NotificationProvider>(context, listen: false)
              .markAsRead(notification.id);
        },
        leading: CircleAvatar(
          backgroundColor: _getIconColor(notification.type),
          child: Icon(
            _getIconForType(notification.type),
            color: Colors.white,
          ),
        ),
        title: Text(
          notification.title,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: notification.isRead ? Colors.black54 : Colors.black87,
          ),
        ),
        subtitle: Text(
          notification.body,
          style: GoogleFonts.poppins(
            color: Colors.grey.shade600,
          ),
        ),
        trailing: Text(
          _formatTimestamp(notification.timestamp),
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
      ),
    );
  }
}

// Helper functions for icons and formatting
IconData _getIconForType(String type) {
  switch (type) {
    case 'Order':
      return Icons.shopping_cart_outlined;
    case 'Invoice':
      return Icons.receipt_long;
    case 'Customer':
      return Icons.person_add_alt;
    default:
      return Icons.notifications_none;
  }
}

Color _getIconColor(String type) {
  switch (type) {
    case 'Order':
      return Colors.indigo.shade600;
    case 'Invoice':
      return Colors.green.shade600;
    case 'Customer':
      return Colors.orange.shade600;
    default:
      return Colors.blueGrey;
  }
}

String _formatTimestamp(DateTime timestamp) {
  final now = DateTime.now();
  final difference = now.difference(timestamp);
  if (difference.inMinutes < 60) {
    return '${difference.inMinutes}m ago';
  } else if (difference.inHours < 24) {
    return '${difference.inHours}h ago';
  } else {
    return '${difference.inDays}d ago';
  }
}