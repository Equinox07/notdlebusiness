// lib/screens/dashboard_home.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/providers/company_provider.dart';
import 'package:notdle/providers/dashboard_provider.dart';
import 'package:notdle/providers/notification_provider.dart';
import 'package:notdle/utils/session_helper.dart';
import 'package:provider/provider.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  // final _dbHelper = DatabaseHelper.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashBoardProvider>(context, listen: false).fetchCounts();
      Provider.of<CompanyProvider>(context, listen: false).fetchCompany();
      SessionHelper.checkCompanySession(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashBoardProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final companyProvider = Provider.of<CompanyProvider>(context);

    final companyName = companyProvider.company?.businessName ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: const _AbstractAppBarBackground(),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6200EE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.polyline_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Good Morning, ${companyName.isNotEmpty ? companyName.split(' ')[0] : 'Sarah'}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        "Notdle Designer",
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF311B92),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "Basic",
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          actions: [
            _NotificationBell(notificationProvider: notificationProvider),
            const SizedBox(width: 8),
            const _ProfileIcon(),
            const SizedBox(width: 12),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 24 : 16,
            vertical: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // Urgent Alerts Section
              const _UrgentAlerts(
                alerts: [
                  '2 Orders Overdue',
                  '1 Client has unpaid balance past 7 days',
                  'Fabric stock low (Lace White)',
                ],
              ),
              const SizedBox(height: 24),

              // Stats Overview (Horizontal Scrollable)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _DashboardStatCard(
                      title: 'Active Orders',
                      value: dashboardProvider.orderCount.toString(),
                      subtext: '${dashboardProvider.orderCount} due this week',
                      icon: Icons.settings, // Sewing machine closest match
                      color: Colors.purple,
                    ),
                    const _DashboardStatCard(
                      title: 'Upcoming Deadlines',
                      value: '0',
                      subtext: 'Next due in 2 days',
                      icon: Icons.calendar_today_outlined,
                      color: Colors.orange,
                    ),
                    const _DashboardStatCard(
                      title: 'Revenue (This Month)',
                      value: '\$0',
                      subtext: '+0% from last month',
                      icon: Icons.attach_money,
                      color: Colors.green,
                    ),
                    const _DashboardStatCard(
                      title: 'Outstanding Payments',
                      value: '\$0 unpaid',
                      subtext: '0 clients pending',
                      icon: Icons.payment,
                      color: Colors.red,
                    ),
                    const _DashboardStatCard(
                      title: 'Appointments Today',
                      value: '0 fittings',
                      subtext: '0 consultation',
                      icon: Icons.event,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Financial Overview Section
              const _FinancialOverview(),
              const SizedBox(height: 32),

              // Production Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionTitle(text: "Production Status"),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      "View All",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF6200EE),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _StatusCard(
                      count: 3,
                      label: "DESIGN",
                      color: Colors.purple.shade50,
                      textColor: Colors.purple,
                    ),
                    _StatusCard(
                      count: 5,
                      label: "CUTTING",
                      color: Colors.indigo.shade50,
                      textColor: Colors.indigo,
                    ),
                    _StatusCard(
                      count: 2,
                      label: "SEWING",
                      color: Colors.orange.shade50,
                      textColor: Colors.orange,
                    ),
                    _StatusCard(
                      count: 1,
                      label: "FINISHING",
                      color: Colors.green.shade50,
                      textColor: Colors.green,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Upcoming Deadlines Section
              _SectionTitle(text: "Upcoming Deadlines"),
              const SizedBox(height: 16),
              _DeadlineListItem(
                name: "Elena Rossi",
                item: "Silk Gala Gown",
                dueText: "Due in 2d",
                status: "SEWING",
                statusColor: Colors.orange.shade100,
                statusTextColor: Colors.orange.shade800,
                icon: Icons.checkroom,
              ),
              _DeadlineListItem(
                name: "Marcus J.",
                item: "Bespoke Suit",
                dueText: "Due in 5d",
                status: "FITTING",
                statusColor: Colors.purple.shade100,
                statusTextColor: Colors.purple.shade800,
                icon: Icons.checkroom,
              ),
              _DeadlineListItem(
                name: "Sophia Chen",
                item: "Cocktail Dress",
                dueText: "Due Tomorrow",
                status: "READY",
                statusColor: Colors.green.shade100,
                statusTextColor: Colors.green.shade800,
                icon: Icons.check_circle_outline,
              ),
              const SizedBox(height: 80), // Padding for FAB
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _QuickActionsBar(),
    );
  }
}

// ➡️ Reusable Widgets

class _AbstractAppBarBackground extends StatelessWidget {
  const _AbstractAppBarBackground();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF6200EE).withOpacity(0.05),
            Colors.grey.shade50,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -50,
            top: -20,
            child: _AbstractBlob(
              color: const Color(0xFF6200EE).withOpacity(0.03),
              size: 150,
            ),
          ),
          Positioned(
            left: -30,
            bottom: -40,
            child: _AbstractBlob(
              color: Colors.amber.withOpacity(0.02),
              size: 120,
            ),
          ),
          CustomPaint(size: Size.infinite, painter: _AppBarPatternPainter()),
        ],
      ),
    );
  }
}

class _AbstractBlob extends StatelessWidget {
  final Color color;
  final double size;

  const _AbstractBlob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _AppBarPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = const Color(0xFF6200EE).withOpacity(0.05)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    final path = Path();
    // Subtle organic wave mimicking thread
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.4,
      size.width * 0.5,
      size.height * 0.7,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 1.0,
      size.width,
      size.height * 0.7,
    );

    canvas.drawPath(path, paint);

    // Another intersecting curve
    final path2 = Path();
    path2.moveTo(size.width * 0.1, 0);
    path2.quadraticBezierTo(
      size.width * 0.4,
      size.height * 0.5,
      size.width * 0.1,
      size.height,
    );
    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _NotificationBell extends StatelessWidget {
  final NotificationProvider notificationProvider;

  const _NotificationBell({required this.notificationProvider});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
          onPressed: () => AppNavigator.toNotifications(),
        ),
        if (notificationProvider.unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.redAccent,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
              child: Text(
                notificationProvider.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class _ProfileIcon extends StatelessWidget {
  const _ProfileIcon();

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withOpacity(0.5), width: 1.5),
        ),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: Colors.grey.shade200,
          child: const Icon(Icons.person, color: Colors.black54, size: 24),
        ),
      ),
      onPressed: () => AppNavigator.toProfile(),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtext;
  final IconData icon;
  final Color color;

  const _DashboardStatCard({
    required this.title,
    required this.value,
    required this.subtext,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtext,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeadlineListItem extends StatelessWidget {
  final String name;
  final String item;
  final String dueText;
  final String status;
  final Color statusColor;
  final Color statusTextColor;
  final IconData icon;

  const _DeadlineListItem({
    required this.name,
    required this.item,
    required this.dueText,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6200EE).withOpacity(0.7),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "$item • $dueText",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              status,
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final Color textColor;

  const _StatusCard({
    required this.count,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textColor.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _UrgentAlerts extends StatelessWidget {
  final List<String> alerts;

  const _UrgentAlerts({required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 20),
              const SizedBox(width: 8),
              Text(
                "Urgent Alerts",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...alerts.map(
            (alert) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      alert,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.red.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FinancialOverview extends StatelessWidget {
  const _FinancialOverview();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "💰 Financial Overview",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text(
                "View Full Analytics",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6200EE),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
          children: const [
            _FinancialCard(
              label: "Today's Income",
              value: "\$0",
              color: Colors.green,
            ),
            _FinancialCard(
              label: "This Week",
              value: "\$0",
              color: Colors.blue,
            ),
            _FinancialCard(
              label: "This Month",
              value: "\$0",
              color: Colors.orange,
            ),
            _FinancialCard(
              label: "Pending Payments",
              value: "\$0",
              color: Colors.red,
            ),
          ],
        ),
      ],
    );
  }
}

class _FinancialCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _FinancialCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsBar extends StatelessWidget {
  const _QuickActionsBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: () => AppNavigator.toCreateNewOrder(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6200EE),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add),
                label: Text(
                  "New Order",
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Icons.person_add_outlined,
              label: "Client",
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Icons.receipt_long_outlined,
              label: "Payment",
              onTap: () {},
            ),
            const SizedBox(width: 8),
            _ActionButton(
              icon: Icons.calendar_month_outlined,
              label: "Fitting",
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.black87, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
