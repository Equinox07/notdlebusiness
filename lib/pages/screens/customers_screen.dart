import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/pages/screens/add_customer_screen.dart';
import 'package:notdle/pages/screens/customer_details_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mock customers
  final List<Customer> customers = [
    Customer(
      id: '1',
      name: 'John Doe',
      phone: '+1 234 567 8900',
      email: 'john.doe@email.com',
      orders: 3,
      lastVisit: DateTime.now().subtract(const Duration(days: 5)),
    ),
    Customer(
      id: '2',
      name: 'Jane Smith',
      phone: '+1 234 567 8901',
      email: 'jane.smith@email.com',
      orders: 7,
      lastVisit: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Customer(
      id: '3',
      name: 'Michael Johnson',
      phone: '+1 234 567 8902',
      email: 'michael.j@email.com',
      orders: 12,
      lastVisit: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  List<Customer> filteredCustomers = [];

  @override
  void initState() {
    super.initState();
    filteredCustomers = customers;
    _searchController.addListener(_filterCustomers);
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredCustomers =
          customers.where((c) {
            return c.name.toLowerCase().contains(query) ||
                c.phone.contains(query) ||
                c.email.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final maxFormWidth = isTablet ? 500.0 : double.infinity;
    final horizontalPadding = isTablet ? 32.0 : 24.0;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Customers",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Column(
        children: [
          // 🔍 Search bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              style: GoogleFonts.poppins(),
              decoration: InputDecoration(
                hintText: 'Search customers...',
                hintStyle: GoogleFonts.poppins(color: Colors.grey.shade500),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
            ),
          ),

          // 📊 Count
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
            child: Text(
              '${filteredCustomers.length} customers found',
              style: GoogleFonts.poppins(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ),

          // 📋 List
          Expanded(
            child:
                filteredCustomers.isEmpty
                    ? _buildEmptyState()
                    : ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 24 : 16,
                        vertical: isTablet ? 20 : 12,
                      ),
                      itemCount: filteredCustomers.length,
                      itemBuilder: (context, index) {
                        final customer = filteredCustomers[index];
                        return CustomerCard(
                          customer: customer,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => CustomerDetailScreen(
                                      customer: customer,
                                    ),
                              ),
                            );
                          },
                        );
                      },
                      separatorBuilder:
                          (context, index) => SizedBox(
                            height: isTablet ? 16 : 12,
                          ), // ✅ space between cards
                    ),
          ),
        ],
      ),

      // ➕ Floating button
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newCustomer = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
          );

          if (newCustomer != null && newCustomer is Customer) {
            setState(() {
              customers.add(newCustomer);
              filteredCustomers = customers;
            });
          }
        },
        icon: const Icon(Icons.person_add, color: Colors.white,),
        label: Text(
          "Add Customer",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: Colors.indigo,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            "No customers found",
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start building your customer base",
            style: GoogleFonts.poppins(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// ---------------- Customer Card ---------------
// import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../models/customer.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16), // ✅ rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05), // ✅ subtle shadow
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar placeholder
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.indigo.shade100,
                child: Icon(Icons.person,
                    color: Colors.indigo.shade600, size: 24),
              ),
              const SizedBox(width: 16),

              // Customer info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.phone,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      customer.email,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Orders count
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${customer.orders} orders",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.indigo.shade700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
