import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/widgets/custom_app_bar.dart';

class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({super.key});

  static const String tag = "notification_list_screen";

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBFBFB),
      appBar: CustomAppBar(
        title: "Notifications",
        centerTitle: true,
        isLight: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildNotificationList("New"),
                _buildNotificationList("Earlier"),
                _buildNotificationList("Archived"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100, width: 1),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: const Color(0xFF6200EE),
        indicatorWeight: 3,
        labelColor: const Color(0xFF6200EE),
        unselectedLabelColor: Colors.black45,
        labelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
        unselectedLabelStyle: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
          fontSize: 15,
        ),
        tabs: const [
          Tab(text: "New"),
          Tab(text: "Earlier"),
          Tab(text: "Archived"),
        ],
      ),
    );
  }

  Widget _buildNotificationList(String type) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _buildDateHeader("TODAY"),
        const SizedBox(height: 16),
        _buildNotificationTile(
          icon: Icons.shopping_bag,
          iconBgColor: const Color(0xFFF3E5F5),
          iconColor: const Color(0xFF6200EE),
          title: "New Order Confirmed",
          subtitle: "Order #4592 — Bespoke Silk Gown",
          time: "2m ago",
          isUnread: true,
        ),
        const SizedBox(height: 16),
        _buildNotificationTile(
          icon: Icons.event_note,
          iconBgColor: const Color(0xFFF3E5F5),
          iconColor: const Color(0xFF6200EE),
          title: "Fitting in 2 hours",
          subtitle: "Client: Isabella Rossi — Final fitting",
          time: "45m ago",
          isUnread: true,
        ),
        const SizedBox(height: 32),
        _buildDateHeader("YESTERDAY"),
        const SizedBox(height: 16),
        _buildNotificationTile(
          icon: Icons.payments_outlined,
          iconBgColor: const Color(0xFFE3F2FD),
          iconColor: const Color(0xFF1976D2),
          title: "Payment Received",
          subtitle: "\$1,250.00 from Elena V.",
          time: "Yesterday",
        ),
        const SizedBox(height: 16),
        _buildNotificationTile(
          icon: Icons.priority_high,
          iconBgColor: const Color(0xFFFFF3E0),
          iconColor: const Color(0xFFF57C00),
          title: "Deadline Overdue",
          subtitle: "Velvet Blazer - Prototype stage",
          time: "Yesterday",
          titleColor: Colors.redAccent,
        ),
        const SizedBox(height: 16),
        _buildNotificationTile(
          icon: Icons.chat_bubble_outline,
          iconBgColor: const Color(0xFFE8EAF6),
          iconColor: const Color(0xFF3F51B5),
          title: "New Message",
          subtitle: "Julian: \"Can we move the fitting to Friday?\"",
          time: "2d ago",
        ),
      ],
    );
  }

  Widget _buildDateHeader(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.black45,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildNotificationTile({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required String time,
    bool isUnread = false,
    Color? titleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: titleColor ?? Colors.black87,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.black38,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          if (isUnread) ...[
            const SizedBox(width: 8),
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(top: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF6200EE),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
