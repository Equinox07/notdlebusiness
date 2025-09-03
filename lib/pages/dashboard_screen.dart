import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/pages/screens/services_screen.dart';
import 'package:notdle/pages/sections/appointment_card.dart';
import 'package:notdle/pages/sections/insight_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  static const String tag = "dashboard";

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardHome(),
    ClientsScreen(),
    ProjectsScreen(),
    FabricsScreen(),
    InvoicesScreen(),
    ServicesScreen(),
  ];

  void _onNavTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavTapped,
        type: BottomNavigationBarType.fixed, // ✅ allows 6 tabs
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Clients"),
          BottomNavigationBarItem(icon: Icon(Icons.folder), label: "Projects"),
          BottomNavigationBarItem(icon: Icon(Icons.texture), label: "Fabrics"),
          BottomNavigationBarItem(icon: Icon(Icons.receipt), label: "Invoices"),
          BottomNavigationBarItem(
              icon: Icon(Icons.design_services), label: "Services"),
        ],
      ),
    );
  }
}

//
// ----------------- DASHBOARD HOME -----------------
//
class DashboardHome extends StatelessWidget {
  const DashboardHome({super.key});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.shortestSide >= 600;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Good morning, Sarah!',
                style: GoogleFonts.poppins(fontSize: 18)),
            Text('Welcome back to your workspace',
                style: GoogleFonts.poppins(fontSize: 12)),
          ],
        ),
        actions: const [Icon(Icons.more_vert)],
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Actions
            Row(
              children: const [
                Expanded(
                  child: ActionButton(
                      icon: Icons.person_add, label: "Add Client"),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ActionButton(
                      icon: Icons.add_circle, label: "New Project"),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Next Appointment
            const SectionTitle("Your Next Appointment"),
            const SizedBox(height: 12),
            const AppointmentCard(
              "Fitting - Wedding Dress",
              "Emma Johnson",
              "Today",
              "2:30 PM",
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => print("Go to Appointments"),
                child: const Text("See All"),
              ),
            ),
            const SizedBox(height: 24),

            // Key Insights
            const SectionTitle("Key Insights"),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: isTablet ? 4 : 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              children: const [
                InsightCard(
                  title: "Total Revenue",
                  value: "\$12,450",
                  subtitle: "+8.2%",
                  icon: Icons.attach_money,
                  iconColor: Colors.green,
                ),
                InsightCard(
                  title: "Active Projects",
                  value: "18",
                  subtitle: "3 due soon",
                  icon: Icons.work_outline,
                  iconColor: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
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

class HomeMenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const HomeMenuCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//
// ----------------- OTHER MAIN SCREENS -----------------
//
class ClientsScreen extends StatelessWidget {
  const ClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clients")),
      body: const Center(child: Text("Clients list & appointments here")),
    );
  }
}

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Projects")),
      body: const Center(child: Text("Projects overview here")),
    );
  }
}

class FabricsScreen extends StatelessWidget {
  const FabricsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fabrics")),
      body: const Center(child: Text("Fabric catalog here")),
    );
  }
}

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Invoices")),
      body: const Center(child: Text("Invoices & billing here")),
    );
  }
}

//
// ----------------- SERVICES DETAIL SCREENS -----------------


