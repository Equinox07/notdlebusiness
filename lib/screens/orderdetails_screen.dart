import 'package:flutter/material.dart';
import 'package:notdle/models/payment.dart';

class OrderDetailsScreen extends StatefulWidget {
  static const String tag = "OrderDetailsScreen";

  // const OrderDetailsScreen({super.key, required this.order, required this.orderId});

  // final Order order;
  // final String orderId;

  static const primaryPurple = Color(0xFF6A1B9A);
  static const lightBackground = Color(0xFFF8F9FE);
  static const successGreen = Color(0xFF2E7D32);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  int _currentStepIndex = 2; // 0: Measure, 1: Cutting, 2: Sewing, etc.

  double totalQuotation = 1250.00;
  double paidAmount = 650.00;

  List<Payment> paymentHistory = [];

  double get totalPaid =>
      paymentHistory.fold(0, (sum, item) => sum + item.amount);
  double get remainingBalance => totalQuotation - totalPaid;

  final List<Map<String, dynamic>> _steps = [
    {'label': 'Measure', 'icon': Icons.check},
    {'label': 'Cutting', 'icon': Icons.content_cut},
    {'label': 'Sewing', 'icon': Icons.straighten}, // Changed icon for variety
    {'label': 'Fitting', 'icon': Icons.person_outline},
    {'label': 'Ready', 'icon': Icons.inventory_2_outlined},
  ];

  // 2. Logic: Move to the next stage
  void _updateStatus() {
    setState(() {
      if (_currentStepIndex < _steps.length - 1) {
        _currentStepIndex++;
      } else {
        // Reset or show completion message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order is Ready for Pickup!")),
        );
      }
    });
  }

  void _addPayment(double amount) {
    setState(() {
      paidAmount += amount;
      // Optional: Add logic to cap paidAmount at totalQuotation
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: OrderDetailsScreen.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: OrderDetailsScreen.primaryPurple,
            size: 20,
          ),
          onPressed: () {},
        ),
        title: Column(
          children: [
            const Text(
              "ORDER DETAILS",
              style: TextStyle(
                color: OrderDetailsScreen.primaryPurple,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              "ID: #SF-8802",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              "Edit",
              style: TextStyle(
                color: OrderDetailsScreen.primaryPurple,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            _buildProfileHeader(),
            const SizedBox(height: 25),
            _buildProductionStatus(),
            const SizedBox(height: 20),
            _buildOutfitDetails(),
            const SizedBox(height: 20),
            _buildDeliveryDeadline(),
            const SizedBox(height: 25),
            _buildDesignReferences(),
            const SizedBox(height: 25),
            _buildPaymentSummary(),
            const SizedBox(height: 30),
            _buildActionButtons(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // --- UI Sections ---
  Widget _buildProfileHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 42,
          backgroundColor: Colors.white,
          child: CircleAvatar(
            radius: 38,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?u=eleanor',
            ),
          ),
        ),
        const SizedBox(width: 15),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Eleanor Vance",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Custom Evening Gown",
              style: TextStyle(
                color: OrderDetailsScreen.primaryPurple,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFF3E5F5),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Text(
                "Priority Client",
                style: TextStyle(
                  color: OrderDetailsScreen.primaryPurple,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductionStatus() {
    return _buildCard(
      child: Column(
        children: [
          const Text(
            "PRODUCTION STATUS",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: List.generate(_steps.length, (index) {
              bool isDone = index < _currentStepIndex;
              bool isCurrent = index == _currentStepIndex;

              return Expanded(
                child: Row(
                  children: [
                    _stepItem(
                      _steps[index]['label'],
                      _steps[index]['icon'],
                      isDone,
                      isCurrent: isCurrent,
                    ),
                    if (index < _steps.length - 1)
                      _stepLine(index < _currentStepIndex),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFBF4FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Estimated completion for Sewing:",
                  style: TextStyle(
                    color: OrderDetailsScreen.primaryPurple,
                    fontSize: 13,
                  ),
                ),
                Text(
                  "Oct 18",
                  style: TextStyle(
                    color: OrderDetailsScreen.primaryPurple,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutfitDetails() {
    return _buildCard(
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Outfit Details",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Icon(
                Icons.checkroom,
                color: OrderDetailsScreen.primaryPurple,
                size: 28,
              ),
            ],
          ),
          const Divider(height: 30),
          _detailRow("Garment Type", "Floor-length Evening Gown"),
          _detailRow("Fabric", "Silk Chiffon with\nEmbroidered Lace"),
          _detailRow("Lining", "Stretch Satin (Nude)"),
          _detailRow(
            "Style Notes",
            "Open back, sweetheart\nneckline with boning.",
            isItalic: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDeadline() {
    return _buildCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF3E5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month,
              color: OrderDetailsScreen.primaryPurple,
            ),
          ),
          const SizedBox(width: 15),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "DELIVERY DEADLINE",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "October 24, 2023",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          const Column(
            children: [
              Text(
                "5",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: OrderDetailsScreen.primaryPurple,
                ),
              ),
              Text(
                "DAYS LEFT",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesignReferences() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Design References",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.camera_alt,
                size: 18,
                color: OrderDetailsScreen.primaryPurple,
              ),
              label: const Text(
                "Add",
                style: TextStyle(
                  color: OrderDetailsScreen.primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _referenceImage('assets/placeholder/placeholder_fabric1.jpeg'),
              _referenceImage('assets/placeholder/placeholder_fabric2.jpg'),
              _referenceImage('assets/placeholder/placeholder_fabric3.jpeg'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary() {
    double balance = totalQuotation - paidAmount;
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "PAYMENT SUMMARY",
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _summaryRow(
            "Total Quotation",
            "\$${totalQuotation.toStringAsFixed(2)}",
            isBold: true,
          ),
          const SizedBox(height: 8),
          _summaryRow(
            "Paid Amount",
            "-\$${paidAmount.toStringAsFixed(2)}",
            color: Colors.green,
          ),
          const Divider(height: 24),
          _summaryRow(
            "Remaining Balance",
            "\$${balance.toStringAsFixed(2)}",
            color: balance > 0 ? Colors.red : Colors.grey,
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: OrderDetailsScreen.primaryPurple,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            elevation: 4,
          ),
          onPressed: _updateStatus,
          icon: const Icon(Icons.sync, color: Colors.white),
          label: const Text(
            "Update Status",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFE6A23C), width: 1.5),
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
          ),
          onPressed: () => _showPaymentSheet(context),
          icon: const Icon(Icons.payments_outlined, color: Color(0xFFE6A23C)),
          label: const Text(
            "Record Payment",
            style: TextStyle(
              color: Color(0xFFE6A23C),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  // --- Helper Components ---
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _stepItem(
    String label,
    IconData icon,
    bool isDone, {
    bool isCurrent = false,
  }) {
    final color =
        isCurrent || isDone
            ? OrderDetailsScreen.primaryPurple
            : Colors.grey[300];
    return Column(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color,
          child: Icon(
            icon,
            size: 14,
            color: isDone || isCurrent ? Colors.white : Colors.grey[400],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color:
                isCurrent ? OrderDetailsScreen.primaryPurple : Colors.grey[600],
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _stepLine(bool active) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(top: 15),
        color: active ? OrderDetailsScreen.primaryPurple : Colors.grey[300],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isItalic = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const Spacer(),
          Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(
    String label,
    String value, {
    bool isBold = false,
    Color color = Colors.black,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 15)),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _referenceImage(String url) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: AssetImage(url), fit: BoxFit.cover),
      ),
    );
  }

  void _showPaymentSheet(BuildContext context) {
    final TextEditingController controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows the sheet to move up with the keyboard
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom:
                  MediaQuery.of(context).viewInsets.bottom, // Keyboard padding
              left: 20,
              right: 20,
              top: 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Record Payment",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: "Amount Received",
                    prefixText: "\$ ",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    final val = double.tryParse(controller.text);
                    if (val != null) {
                      _addPayment(val);
                      Navigator.pop(context); // Close the sheet
                    }
                  },
                  child: const Text(
                    "Confirm Payment",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
    );
  }

  Widget _buildTransactionHistory() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "PAYMENT HISTORY",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 10),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: paymentHistory.length,
          separatorBuilder: (context, index) => const Divider(),
          itemBuilder: (context, index) {
            final payment = paymentHistory[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.receipt_long, color: Colors.green),
              title: Text("\$${payment.amount.toStringAsFixed(2)}"),
              subtitle: Text(
                "via ${payment.method} • ${payment.paymentDate.day}/${payment.paymentDate.month}",
              ),
              trailing:
                  payment.referenceNumber != null
                      ? Text(
                        "Ref: ${payment.referenceNumber}",
                        style: const TextStyle(fontSize: 10),
                      )
                      : null,
            );
          },
        ),
      ],
    );
  }
}
