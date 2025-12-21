import 'package:flutter/material.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/screens/add_customer_screen.dart';
import 'package:notdle/screens/customer_detail_screen.dart';
import 'package:notdle/widgets/custom_app_bar.dart';
import 'package:provider/provider.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  static const String tag = "customers";

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Mock customers
  late List<Customer> customers = [];

  List<Customer> filteredCustomers = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   Provider.of<CustomerProvider>(context, listen: false).fetchCustomers();
    //   // Provider.of<CompanyProvider>(context, listen: false).fetchCompany();
    // });
    filteredCustomers = customers;
    _searchController.addListener(_filterCustomers);
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    // final data = context.read<CustomerProvider>().fetchCustomers(); //await DatabaseHelper.instance.fetchCustomers();
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );
    await customerProvider.fetchCustomers();
    setState(() {
      customers = customerProvider.customers;
      filteredCustomers = customerProvider.customers;
      _isLoading = false;
    });
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredCustomers =
          customers.where((c) {
            return c.name.toLowerCase().contains(query) ||
                c.phone.contains(query);
            // || c.email.toLowerCase().contains(query);
          }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);

    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth >= 600;
    final maxFormWidth = isTablet ? 500.0 : double.infinity;
    final horizontalPadding = isTablet ? 32.0 : 24.0;
    // final order = customerProvider.customerOrderCount(customerId);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: const CustomAppBar(title: "Customers"),
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
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: Text(
          "Add Customer",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
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
class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;

  const CustomerCard({super.key, required this.customer, required this.onTap});

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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.indigo.shade100,
                backgroundImage:
                    customer.imagePath != null
                        ? FileImage(File(customer.imagePath!))
                        : null,
                child:
                    customer.imagePath == null
                        ? Icon(
                          Icons.person,
                          color: Colors.indigo.shade600,
                          size: 24,
                        )
                        : null,
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
                      customer.email ?? "N/A",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Orders count using FutureBuilder
              FutureBuilder<int>(
                future: Provider.of<CustomerProvider>(
                  context,
                  listen: false,
                ).getOrderCountForCustomer(customer.id!),
                builder: (context, snapshot) {
                  final orderCount = snapshot.data ?? 0;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "$orderCount orders",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.indigo.shade700,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// class CustomerCard extends StatelessWidget {
//   final Customer customer;
//   final VoidCallback onTap;

//   const CustomerCard({super.key, required this.customer, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16), // ✅ rounded corners
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05), // ✅ subtle shadow
//               blurRadius: 10,
//               offset: const Offset(0, 4),
//             ),
//           ],
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Avatar placeholder
//               CircleAvatar(
//                 radius: 24,
//                 backgroundColor: Colors.indigo.shade100,
//                 child: Icon(
//                   Icons.person,
//                   color: Colors.indigo.shade600,
//                   size: 24,
//                 ),
//               ),
//               const SizedBox(width: 16),

//               // Customer info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       customer.name,
//                       style: GoogleFonts.poppins(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       customer.phone,
//                       style: GoogleFonts.poppins(
//                         fontSize: 13,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     Text(
//                       customer.email ?? "N/A",
//                       style: GoogleFonts.poppins(
//                         fontSize: 13,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),

//               // Orders count
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.indigo.shade50,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Text(
//                   "${customer.getTotalOrders()} orders",
//                   style: GoogleFonts.poppins(
//                     fontSize: 12,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.indigo.shade700,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
