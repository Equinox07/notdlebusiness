import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/pages/sections/appointment_card.dart';
import 'package:notdle/pages/sections/insight_card.dart';
import 'package:notdle/widgets/home_menu_card.dart';

class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Good morning, Sarah!',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Welcome back to your workspace',
              style: GoogleFonts.poppins(fontSize: 12),
            ),
          ],
        ),
        actions: const [Icon(Icons.more_vert)],
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTablet = constraints.maxWidth > 600;
            final padding = isTablet ? 32.0 : 20.0;

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(padding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isTablet ? 32 : 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.blue.shade600, Colors.blue.shade400],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isTablet ? 28 : 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: isTablet ? 12 : 8),
                          Text(
                            'Ready to create beautiful garments?',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: isTablet ? 18 : 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: isTablet ? 40 : 32),

                    // Quick stats
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(isTablet ? 20 : 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '24',
                                  style: TextStyle(
                                    fontSize: isTablet ? 32 : 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                                Text(
                                  'Active Orders',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: isTablet ? 14 : 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(width: isTablet ? 20 : 16),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(isTablet ? 20 : 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Text(
                                  '156',
                                  style: TextStyle(
                                    fontSize: isTablet ? 32 : 28,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade600,
                                  ),
                                ),
                                Text(
                                  'Total Customers',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: isTablet ? 14 : 12,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isTablet ? 40 : 32),

                    // Menu options
                    Text(
                      'Services',
                      style: TextStyle(
                        fontSize: isTablet ? 24 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    SizedBox(height: isTablet ? 20 : 16),

                    // Grid with responsive columns
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isTablet ? 3 : 2,
                      childAspectRatio: isTablet ? 1.2 : 1.1,
                      crossAxisSpacing: isTablet ? 20 : 16,
                      mainAxisSpacing: isTablet ? 20 : 16,
                      children: [
                        HomeMenuCard(
                          title: 'Customers',
                          subtitle: 'Manage clients',
                          icon: Icons.people_outline,
                          color: Colors.blue.shade600,
                          onTap: () => AppNavigator.toCustomers(),
                        ),
                        HomeMenuCard(
                          title: 'Measurements',
                          subtitle: 'Take & update',
                          icon: Icons.straighten,
                          color: Colors.orange.shade600,
                          onTap: () => AppNavigator.toMeasurement(),
                        ),
                        HomeMenuCard(
                          title: 'Orders',
                          subtitle: 'Track progress',
                          icon: Icons.shopping_bag_outlined,
                          color: Colors.green.shade600,
                          onTap: () => AppNavigator.toOrders(),
                        ),
                        HomeMenuCard(
                          title: 'Designs',
                          subtitle: 'Style catalog',
                          icon: Icons.palette_outlined,
                          color: Colors.purple.shade600,
                          onTap: () => AppNavigator.toDesigns(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

//
// ----------------- SHARED WIDGETS -----------------
//
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }
}

class ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const ActionButton({required this.icon, required this.label, super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.grey[100],
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      onPressed: () {},
      icon: Icon(icon),
      label: Text(label),
    );
  }
}
