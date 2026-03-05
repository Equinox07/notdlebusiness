// lib/screens/services_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/service_model.dart';
import 'package:notdle/screens/all_measurement_screen.dart';
import 'package:notdle/screens/customers_screen.dart';
import 'package:notdle/screens/orders_screen.dart';
// Your navigation destinations

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  static const String tag = "services";

  final List<ServiceModel> _services = const [
    ServiceModel(
      title: 'Customers',
      description: 'Manage clients profiles',
      icon: Icons.people_outline,
      iconColor: Colors.blue,
    ),
    ServiceModel(
      title: 'Measurements',
      description: 'Manage and update client measurements',
      icon: Icons.straighten,
      iconColor: Colors.orange,
    ),
    ServiceModel(
      title: 'Orders',
      description: 'Track progress and status of all orders',
      icon: Icons.shopping_bag_outlined,
      iconColor: Colors.green,
    ),
    ServiceModel(
      title: 'Designs',
      description: 'View and manage your design catalog',
      icon: Icons.palette_outlined,
      iconColor: Colors.purple,
      isComingSoon: true,
    ),
    ServiceModel(
      title: 'Repairs',
      description: 'Log and track clothing repair jobs',
      icon: Icons.handyman_outlined,
      iconColor: Colors.red,
      isComingSoon: true,
    ),
    ServiceModel(
      title: 'Appointments',
      description: 'Manage client bookings',
      icon: Icons.calendar_today_outlined,
      iconColor: Colors.teal,
      isComingSoon: true,
    ),
    ServiceModel(
      title: 'myStore',
      description: 'Manage your online shop',
      icon: Icons.storefront_outlined,
      iconColor: Colors.indigo,
      isComingSoon: true,
    ),
    ServiceModel(
      title: 'Fabrics',
      description: 'Catalogue of your materials',
      icon: Icons.texture_outlined,
      iconColor: Colors.amber,
      isComingSoon: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF6200EE).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.miscellaneous_services_rounded,
                color: Color(0xFF6200EE),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Services',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  'Manage your operations',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: Color(0xFF424242),
                size: 18,
              ),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
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
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isTablet ? 3 : 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final service = _services[index];
                return _ServiceCard(
                  service: service,
                  onTap: () {
                    if (service.isComingSoon) return;
                    switch (service.title) {
                      case 'Customers':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CustomersScreen(),
                          ),
                        );
                        break;
                      case 'Measurements':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AllMeasurementScreen(),
                          ),
                        );
                        break;
                      case 'Orders':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OrdersScreen(),
                          ),
                        );
                        break;
                      default:
                        debugPrint("Service clicked ${service.title}");
                    }
                  },
                );
              }, childCount: _services.length),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 16)),
        ],
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  final VoidCallback onTap;

  const _ServiceCard({required this.service, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: service.iconColor.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: service.isComingSoon ? null : onTap,
          borderRadius: BorderRadius.circular(20),
          child: Opacity(
            opacity: service.isComingSoon ? 0.6 : 1.0,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: service.iconColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          service.icon,
                          size: 18,
                          color: service.iconColor,
                        ),
                      ),
                      if (service.isComingSoon)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "Soon",
                            style: GoogleFonts.poppins(
                              fontSize: 7,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        )
                      else
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 10,
                          color: Colors.grey.shade300,
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    service.title,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1A1C1E),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    service.description,
                    style: GoogleFonts.poppins(
                      fontSize: 9,
                      color: Colors.grey.shade500,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

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
