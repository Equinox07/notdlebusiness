import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/navigation/app_navigation.dart';
import 'package:notdle/pages/screens/create_order_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/pages/screens/order_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  static const String tag = "orders";

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final List<Customer> customers = [
    Customer(
      id: 001,
      gender: "Male",
      name: "Emma Johnson",
      phone: "+1 (555) 123-4567",
      email: "emma.j@example.com",
    ),
    Customer(
      id: 002,
      gender: "Male",
      name: "Michael Chen",
      phone: "+1 (555) 987-6543",
      email: "michael.c@example.com",
    ),
    Customer(
      id: 003,
      gender: "Male",
      name: "Lisa Rodriguez",
      phone: "+1 (555) 555-1111",
      email: "lisa.r@example.com",
    ),
  ];

  late final List<Order> orders = [
    Order(
      id: "1",
      title: "Wedding Dress",
      customer: customers[0],
      status: "In Progress",
    ),
    Order(
      id: "2",
      title: "Business Suit",
      customer: customers[1],
      status: "Completed",
    ),
    Order(id: "3", title: "Blazer", customer: customers[2], status: "Pending"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          "Orders",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _OrderCard(
            order: order,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => OrderDetailsScreen(order: order),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // **CORRECTED:** Pass the customers list to the CreateOrderScreen
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => CreateOrderScreen(customers: customers),
            ),
          );
        },
        label: Text(
          "New Order",
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}

// Reusable Order Card Widget
class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Order Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shopping_bag_outlined,
                  color: _getStatusColor(order.status),
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              // Order Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.title,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      order
                          .customer
                          .name, // Display the customer's name from the model
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Status Chip
              _StatusChip(status: order.status),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green.shade600;
      case "In Progress":
        return Colors.blue.shade600;
      case "Pending":
        return Colors.orange.shade600;
      default:
        return Colors.grey;
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final Color statusColor = _getStatusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: GoogleFonts.poppins(
          color: statusColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case "Completed":
        return Colors.green;
      case "In Progress":
        return Colors.blue;
      case "Pending":
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

// Part of OrdersScreen widget
// ...

// late final List<Customer> customers = [
//   Customer(
//     id: 001,
//     gender: "Male",
//     name: "Emma Johnson",
//     phone: "+1 (555) 123-4567",
//     email: "emma.j@example.com",
//   ),
//   Customer(
//     id: 002,
//     gender: "Male",
//     name: "Michael Chen",
//     phone: "+1 (555) 987-6543",
//     email: "michael.c@example.com",
//   ),
//   Customer(
//     id: 003,
//     gender: "Male",
//     name: "Lisa Rodriguez",
//     phone: "+1 (555) 555-1111",
//     email: "lisa.r@example.com",
//   ),
// ];

// ...

// Update the `FloatingActionButton`'s onPressed callback
// onPressed: () {
//     Navigator.of(context).push(
//         MaterialPageRoute(
//             builder: (context) => CreateOrderScreen(customers: customers), // Pass the customers list
//         ),
//     );
// }

// ...
