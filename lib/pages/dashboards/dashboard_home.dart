// lib/screens/dashboard_home.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/providers/company_provider.dart';
import 'package:notdle/providers/dashboard_provider.dart';
import 'package:notdle/providers/notification_provider.dart';
import 'package:notdle/utils/session_helper.dart';
import 'package:provider/provider.dart';
import 'package:notdle/models/financial_overview_stats.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/models/production_status.dart';
import 'package:notdle/providers/financial_provider.dart';
import 'package:notdle/providers/order_provider.dart';

class DashboardHome extends StatefulWidget {
  const DashboardHome({super.key});

  @override
  State<DashboardHome> createState() => _DashboardHomeState();
}

class _DashboardHomeState extends State<DashboardHome> {
  late Future<ProductionStatus> _productionStatusFuture;
  late Future<FinancialOverviewStats> _financialOverviewFuture;
  late Future<List<Order>> _upcomingDeadlinesFuture;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DashBoardProvider>(context, listen: false).fetchCounts();
      Provider.of<CompanyProvider>(context, listen: false).fetchCompany();
      SessionHelper.checkCompanySession(context);
    });
  }

  void _loadDashboardData() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final financialProvider = Provider.of<FinancialProvider>(
      context,
      listen: false,
    );

    setState(() {
      _productionStatusFuture = orderProvider.getProductionStatusCounts();
      _financialOverviewFuture = financialProvider.getFinancialOverview();
      _upcomingDeadlinesFuture = orderProvider.fetchOrdersDueInNext7Days();
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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6200EE).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Image.asset(
                'assets/icon/app_ico.png',
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Hello, ${companyName.isNotEmpty ? companyName.split(' ')[0] : 'Designer'}',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      "Studio Manager",
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.black38,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6200EE).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "PRO",
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6200EE),
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
          const SizedBox(width: 4),
          const _ProfileIcon(),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: Colors.black.withValues(alpha: 0.02),
          ),
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
                    FutureBuilder<List<Order>>(
                      future: _upcomingDeadlinesFuture,
                      builder: (context, snapshot) {
                        final count = snapshot.data?.length ?? 0;
                        return _DashboardStatCard(
                          title: 'Upcoming Deadlines',
                          value: count.toString(),
                          subtext: 'Next due in 2 days',
                          icon: Icons.calendar_today_outlined,
                          color: Colors.orange,
                        );
                      },
                    ),
                    FutureBuilder<FinancialOverviewStats>(
                      future: _financialOverviewFuture,
                      builder: (context, snapshot) {
                        final stats = snapshot.data;
                        return _DashboardStatCard(
                          title: 'Revenue (This Month)',
                          value:
                              '\$${stats?.thisMonthIncome.toStringAsFixed(2) ?? '0.00'}',
                          subtext: '+0% from last month',
                          icon: Icons.attach_money,
                          color: Colors.green,
                        );
                      },
                    ),
                    FutureBuilder<FinancialOverviewStats>(
                      future: _financialOverviewFuture,
                      builder: (context, snapshot) {
                        final stats = snapshot.data;
                        return _DashboardStatCard(
                          title: 'Outstanding Payments',
                          value:
                              '\$${stats?.pendingPayments.toStringAsFixed(2) ?? '0.00'} unpaid',
                          subtext: '0 clients pending',
                          icon: Icons.payment,
                          color: Colors.red,
                        );
                      },
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
              _FinancialOverview(
                financialOverviewFuture: _financialOverviewFuture,
              ),
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
              FutureBuilder<ProductionStatus>(
                future: _productionStatusFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading stats'));
                  }
                  final status = snapshot.data;
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _StatusCard(
                          count: status?.measureCount ?? 0,
                          label: "DESIGN",
                          color: Colors.purple.shade50,
                          textColor: Colors.purple,
                        ),
                        _StatusCard(
                          count: status?.cuttingCount ?? 0,
                          label: "CUTTING",
                          color: Colors.indigo.shade50,
                          textColor: Colors.indigo,
                        ),
                        _StatusCard(
                          count: status?.sewingCount ?? 0,
                          label: "SEWING",
                          color: Colors.orange.shade50,
                          textColor: Colors.orange,
                        ),
                        _StatusCard(
                          count: status?.fittingCount ?? 0,
                          label: "FINISHING",
                          color: Colors.green.shade50,
                          textColor: Colors.green,
                        ),
                        _StatusCard(
                          count: status?.readyCount ?? 0,
                          label: "READY",
                          color: Colors.blue.shade50,
                          textColor: Colors.blue,
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),

              // Upcoming Deadlines Section
              _SectionTitle(text: "Upcoming Deadlines"),
              const SizedBox(height: 16),
              FutureBuilder<List<Order>>(
                future: _upcomingDeadlinesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return const Center(child: Text('Error loading deadlines'));
                  }
                  final deadlines = snapshot.data ?? [];
                  if (deadlines.isEmpty) {
                    return const Center(child: Text('No upcoming deadlines.'));
                  }
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: deadlines.length,
                    itemBuilder: (context, index) {
                      final order = deadlines[index];
                      return _DeadlineListItem(
                        name: order.title,
                        item: order.garmentType,
                        dueText: 'Due in ${order.daysLeft}d',
                        status: order.currentStage.name.toUpperCase(),
                        statusColor: Colors.orange.shade100,
                        statusTextColor: Colors.orange.shade800,
                        icon: Icons.checkroom,
                      );
                    },
                  );
                },
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

// Removed _AbstractAppBarBackground and sub-widgets as the AppBar is now simplified.

class _NotificationBell extends StatelessWidget {
  final NotificationProvider notificationProvider;

  const _NotificationBell({required this.notificationProvider});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.notifications_rounded,
              color: Color(0xFF424242),
              size: 20,
            ),
            onPressed: () => AppNavigator.toNotificationList(),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          ),
        ),
        if (notificationProvider.unreadCount > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: Color(0xFFFF5252),
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
              child: Text(
                notificationProvider.unreadCount > 9
                    ? '9+'
                    : notificationProvider.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
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
    return GestureDetector(
      onTap: () => AppNavigator.toBusinessProfile(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [
              const Color(0xFF6200EE).withValues(alpha: 0.15),
              const Color(0xFF6200EE).withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: const Color(0xFF6200EE).withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: const Icon(
          Icons.person_rounded,
          color: Color(0xFF6200EE),
          size: 20,
        ),
      ),
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
            color: Colors.black.withValues(alpha: 0.04),
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
              color: color.withValues(alpha: 0.1),
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
            color: Colors.black.withValues(alpha: 0.03),
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
              color: const Color(0xFF6200EE).withValues(alpha: 0.7),
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
              color: textColor.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor.withValues(alpha: 0.6),
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
  final Future<FinancialOverviewStats> financialOverviewFuture;

  const _FinancialOverview({required this.financialOverviewFuture});

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
        FutureBuilder<FinancialOverviewStats>(
          future: financialOverviewFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading financials'));
            }
            final stats = snapshot.data;
            return GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _FinancialCard(
                  label: "Today's Income",
                  value:
                      "\$${stats?.todaysIncome.toStringAsFixed(2) ?? '0.00'}",
                  color: Colors.green,
                ),
                _FinancialCard(
                  label: "This Week",
                  value:
                      "\$${stats?.thisWeekIncome.toStringAsFixed(2) ?? '0.00'}",
                  color: Colors.blue,
                ),
                _FinancialCard(
                  label: "This Month",
                  value:
                      "\$${stats?.thisMonthIncome.toStringAsFixed(2) ?? '0.00'}",
                  color: Colors.orange,
                ),
                _FinancialCard(
                  label: "Pending Payments",
                  value:
                      "\$${stats?.pendingPayments.toStringAsFixed(2) ?? '0.00'}",
                  color: Colors.red,
                ),
              ],
            );
          },
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
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.1)),
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
            color: Colors.black.withValues(alpha: 0.05),
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
