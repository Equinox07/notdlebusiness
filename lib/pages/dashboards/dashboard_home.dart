// lib/screens/dashboard_home.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/providers/company_provider.dart';
import 'package:notdle/providers/dashboard_provider.dart';
import 'package:notdle/providers/notification_provider.dart';
import 'package:notdle/widgets/custom_app_bar.dart';
import 'package:notdle/widgets/deadline_card.dart';
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
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboardProvider = Provider.of<DashBoardProvider>(context);
    final notificationProvider = Provider.of<NotificationProvider>(context);
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;
    final order = dashboardProvider.soonestDueOrder;
    final companyProvider = Provider.of<CompanyProvider>(context);

    final companyName = companyProvider.company?.businessName ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: CustomAppBar(
        title: "Dashboard",
        automaticallyImplyLeading: false,
        actions: [
          _NotificationBell(notificationProvider: notificationProvider),
          const SizedBox(width: 8),
          const _ProfileIcon(),
          const SizedBox(width: 16),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isTablet ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.indigo.shade600, Colors.indigo.shade900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.shade200.withOpacity(0.5),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Welcome back, ',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                ),
                                TextSpan(
                                  text:
                                      companyName.isNotEmpty
                                          ? companyName
                                          : 'Your Business',
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.auto_graph,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Colors.white70,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Here's your daily overview",
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Insight Cards Section
              _SectionTitle(text: "Overview"),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 4,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isTablet ? 4 : 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.1,
                ),
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return _InsightCard(
                        title: 'Active Orders',
                        count: dashboardProvider.orderCount,
                        icon: Icons.shopping_bag_outlined,
                        color: Colors.blue,
                      );
                    case 1:
                      return _InsightCard(
                        title: 'Customers',
                        count: dashboardProvider.customerCount,
                        icon: Icons.people_outline,
                        color: Colors.green,
                      );
                    case 2:
                      return _InsightCard(
                        title: 'Pending Invoices',
                        count: 0, // Replace with actual data if available
                        icon: Icons.receipt_long_outlined,
                        color: Colors.orange,
                      );
                    case 3:
                      return _InsightCard(
                        title: 'Designs',
                        count: 0, // Replace with actual data if available
                        icon: Icons.palette_outlined,
                        color: Colors.purple,
                      );
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),

              const SizedBox(height: 32),

              // Quick Actions Section
              _SectionTitle(text: "Quick Actions"),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _ActionCard(
                      title: 'New Client',
                      icon: Icons.person_add_alt_1_rounded,
                      color: Colors.teal,
                      onTap: () => AppNavigator.toAddCustomer(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _ActionCard(
                      title: 'New Order',
                      icon: Icons.add_shopping_cart_rounded,
                      color: Colors.indigo,
                      onTap: () => AppNavigator.toCreateNewOrder(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Deadlines Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SectionTitle(text: "Upcoming Deadlines"),
                  TextButton(
                    onPressed: () {
                      AppNavigator.toDeadlines();
                    },
                    child: Text(
                      "View All",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.indigo,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (order != null)
                DeadlineCard(orderFuture: Future.value(order), onTap: () {})
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_available,
                        size: 48,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No upcoming deadlines',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ➡️ Reusable Widgets

class _NotificationBell extends StatelessWidget {
  final NotificationProvider notificationProvider;

  const _NotificationBell({required this.notificationProvider});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: Colors.white),
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
          radius: 16,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: const Icon(Icons.person, color: Colors.white, size: 20),
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

class _InsightCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _InsightCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {}, // Add navigation if needed
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      count.toString(),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
