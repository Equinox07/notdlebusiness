// lib/screens/invoice_details_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/models/customer.dart';

// class _CustomerInfoCard extends StatelessWidget {
//   final Customer customer;

//   const _CustomerInfoCard({required this.customer});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(24),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             "Customer Details",
//             style: GoogleFonts.poppins(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: Colors.grey.shade800,
//             ),
//           ),
//           const SizedBox(height: 12),
//           _InfoRow(
//               icon: Icons.person_outline, label: customer.name),
//           const SizedBox(height: 8),
//           _InfoRow(
//               icon: Icons.phone_outlined, label: customer.phone),
//           const SizedBox(height: 8),
//           _InfoRow(
//               icon: Icons.email_outlined, label: customer.email ?? "N/A"),
//         ],
//       ),
//     );
//   }
// }
