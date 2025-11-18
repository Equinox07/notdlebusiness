// lib/screens/invoice_details_screen.dart


// class _InvoiceHeaderCard extends StatelessWidget {
//   final Invoice invoice;

//   const _InvoiceHeaderCard({required this.invoice});

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
//             "Invoice #${invoice.id.substring(0, 8)}",
//             style: GoogleFonts.poppins(
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//               color: Colors.grey.shade800,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             DateFormat('MMMM d, y').format(invoice.date),
//             style: GoogleFonts.poppins(
//               fontSize: 14,
//               color: Colors.grey.shade600,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             "\$${invoice.totalAmount.toStringAsFixed(2)}",
//             style: GoogleFonts.poppins(
//               fontSize: 32,
//               fontWeight: FontWeight.bold,
//               color: Colors.indigo.shade600,
//             ),
//           ),
//           const SizedBox(height: 8),
//           _PaymentStatusChip(status: invoice.status),
//         ],
//       ),
//     );
//   }
// }
