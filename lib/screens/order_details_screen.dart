import 'package:flutter/material.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:notdle/models/app_image.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/models/image_owner_types.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/models/payment.dart';
import 'package:notdle/providers/image_provider.dart';
import 'package:notdle/providers/order_provider.dart';
import 'package:provider/provider.dart';

// Private data model to hold all fetched details
class _OrderDetailsData {
  final Order order;
  final Customer? customer;
  final Invoice? invoice;
  _OrderDetailsData({required this.order, this.customer, this.invoice});
}

class OrderDetailsScreen extends StatefulWidget {
  static const String tag = "order_details_screen";

  const OrderDetailsScreen({
    super.key,
    required this.order,
    required this.orderId,
  });

  final Order order;
  final String orderId;

  static const primaryPurple = Color(0xFF6A1B9A);
  static const lightBackground = Color(0xFFF8F9FE);
  static const successGreen = Color(0xFF2E7D32);

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  int _currentStepIndex = 2; // 0: Measure, 1: Cutting, 2: Sewing, etc.
  late Future<_OrderDetailsData?> _orderDetailsFuture;
  Future<List<AppImage>>? _customerImagesFuture;
  late Future<List<AppImage>> _orderImagesFuture;

  List<AppImage> _images = [];

  bool _loadingImages = true;

  double paidAmount = 0;
  double totalQuotation = 0;

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

  @override
  void initState() {
    super.initState();
    _orderDetailsFuture = _fetchOrderDetails();
    _orderImagesFuture = _fetchOrderImages();
    _fetchImages();
    _currentStepIndex = _stageToIndex(widget.order.currentStage);
    totalQuotation =
        widget.order.totalQuotation > 0
            ? widget.order.totalQuotation
            : (widget.order.total ?? 0);
    paidAmount = widget.order.paidAmount;
  }

  Future<void> _fetchImages() async {
    final provider = Provider.of<AppImageProvider>(context, listen: false);
    final images = await provider.getImages(
      widget.order.id,
      ImageOwnerTypes.order,
    );
    if (mounted) {
      setState(() {
        _images = images;
        _loadingImages = false;
      });
    }
  }

  Future<List<AppImage>> _fetchCustomerImages(String customerId) async {
    final imageProvider = Provider.of<AppImageProvider>(context, listen: false);
    return imageProvider.getImages(customerId, ImageOwnerTypes.customer);
  }

  Future<List<AppImage>> _fetchOrderImages() async {
    final imageProvider = Provider.of<AppImageProvider>(context, listen: false);

    debugPrint("Fetching order images for order ID: ${widget.order.id}");

    return imageProvider.getImages(widget.order.id, ImageOwnerTypes.order);
  }

  Future<_OrderDetailsData?> _fetchOrderDetails() async {
    if (!mounted) return null;
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final data = await orderProvider.getOrderWithDetails(widget.orderId);
    if (data == null) {
      return _OrderDetailsData(order: widget.order);
    }

    return _OrderDetailsData(
      order: data.order,
      customer: data.customer,
      invoice: data.invoice,
    );
  }

  int _stageToIndex(ProductionStage stage) {
    switch (stage) {
      case ProductionStage.measure:
        return 0;
      case ProductionStage.cutting:
        return 1;
      case ProductionStage.sewing:
        return 2;
      case ProductionStage.fitting:
        return 3;
      case ProductionStage.ready:
        return 4;
    }
  }

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
    return FutureBuilder<_OrderDetailsData?>(
      future: _orderDetailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final details = snapshot.data ?? _OrderDetailsData(order: widget.order);
        final order = details.order;

        if (_customerImagesFuture == null && details.customer != null) {
          _customerImagesFuture = _fetchCustomerImages(
            details.customer!.id ?? '',
          );
        }

        return Scaffold(
          backgroundColor: OrderDetailsScreen.lightBackground,
          appBar: AppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            scrolledUnderElevation: 0,
            elevation: 0,
            leadingWidth: 64,
            leading: Padding(
              padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                  color: Colors.black87,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            titleSpacing: 4,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Order Details",
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "Order #${order.orderNumber ?? order.id.substring(0, 6).toUpperCase()}",
                  style: TextStyle(color: Colors.blueGrey[500], fontSize: 12),
                ),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12, top: 8, bottom: 8),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: OrderDetailsScreen.primaryPurple.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    tooltip: 'Edit order',
                    onPressed: () {},
                    icon: const Icon(
                      Icons.edit_note_rounded,
                      color: OrderDetailsScreen.primaryPurple,
                    ),
                  ),
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Divider(
                height: 1,
                thickness: 1,
                color: Colors.grey.shade200,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),
                _buildProfileHeader(details.customer),
                const SizedBox(height: 25),
                _buildProductionStatus(),
                const SizedBox(height: 20),
                _buildOutfitDetails(),
                const SizedBox(height: 20),
                _buildDeliveryDeadline(),
                const SizedBox(height: 25),
                _buildDesignReferences(order),
                const SizedBox(height: 25),
                _buildPaymentSummary(order),
                const SizedBox(height: 30),
                _buildActionButtons(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  // --- UI Sections ---
  Widget _buildProfileHeader(Customer? customer) {
    final displayName = customer?.name ?? "Unknown Customer";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          FutureBuilder<List<AppImage>>(
            future: _customerImagesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircleAvatar(
                  radius: 32,
                  child: CircularProgressIndicator(),
                );
              }
              final images = snapshot.data ?? const <AppImage>[];
              final imagePath =
                  images.isNotEmpty ? images.first.localPath : null;
              final initial =
                  displayName.trim().isNotEmpty
                      ? displayName.trim().substring(0, 1).toUpperCase()
                      : "?";

              return CircleAvatar(
                radius: 32,
                backgroundColor: OrderDetailsScreen.primaryPurple.withOpacity(
                  0.1,
                ),
                backgroundImage:
                    imagePath != null && imagePath.isNotEmpty
                        ? FileImage(File(imagePath))
                        : null,
                child:
                    (imagePath == null || imagePath.isEmpty)
                        ? Text(
                          initial,
                          style: const TextStyle(
                            color: OrderDetailsScreen.primaryPurple,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                        : null,
              );
            },
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.order.title,
                  style: const TextStyle(
                    color: OrderDetailsScreen.primaryPurple,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E5F5),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Text(
                    "Priority Client",
                    style: TextStyle(
                      color: OrderDetailsScreen.primaryPurple,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Current stage:",
                  style: TextStyle(
                    color: OrderDetailsScreen.primaryPurple,
                    fontSize: 13,
                  ),
                ),
                Text(
                  _steps[_currentStepIndex]['label'] as String,
                  style: const TextStyle(
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
          _detailRow(
            "Garment Type",
            widget.order.garmentType.isNotEmpty
                ? widget.order.garmentType
                : "Not specified",
          ),
          _detailRow(
            "Fabric",
            widget.order.fabric.isNotEmpty
                ? widget.order.fabric
                : "Not specified",
          ),
          _detailRow(
            "Lining",
            widget.order.lining.isNotEmpty
                ? widget.order.lining
                : "Not specified",
          ),
          _detailRow(
            "Style Notes",
            (widget.order.notes != null &&
                    widget.order.notes!.trim().isNotEmpty)
                ? widget.order.notes!
                : "No style notes provided.",
            isItalic: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryDeadline() {
    final due = widget.order.dueAt;
    final dueDateText =
        due != null ? DateFormat('MMMM d, y').format(due) : "No due date set";
    final daysLeft = due != null ? due.difference(DateTime.now()).inDays : null;

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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "DELIVERY DEADLINE",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                dueDateText,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            children: [
              Text(
                daysLeft?.toString() ?? '--',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: OrderDetailsScreen.primaryPurple,
                ),
              ),
              Text(
                daysLeft == null ? "NO DATE" : "DAYS LEFT",
                style: const TextStyle(
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

  Widget _buildDesignReferences(Order order) {
    final references = order.designReferences;

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
        FutureBuilder<List<AppImage>>(
          future: _orderImagesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting &&
                references.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final orderImages = snapshot.data ?? const <AppImage>[];
            final allImagePaths = [
              ...orderImages.map((img) => img.localPath),
              ...references,
            ];

            if (allImagePaths.isEmpty) {
              return _buildCard(
                child: const Center(
                  child: Text(
                    "No design references added",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            final widgets =
                allImagePaths.map((path) => _referenceImage(path)).toList();

            return SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: widgets,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPaymentSummary(Order order) {
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
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
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
            side: BorderSide(
              color: OrderDetailsScreen.primaryPurple.withOpacity(0.35),
              width: 1.2,
            ),
            backgroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          onPressed: () => _showPaymentSheet(context),
          icon: const Icon(
            Icons.payments_outlined,
            color: OrderDetailsScreen.primaryPurple,
          ),
          label: const Text(
            "Record Payment",
            style: TextStyle(
              color: OrderDetailsScreen.primaryPurple,
              fontSize: 17,
              fontWeight: FontWeight.w700,
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
    debugPrint("Loading reference image from: $url");

    final isNetwork =
        url.startsWith('http://') ||
        url.startsWith('https://') ||
        url.startsWith('file://');
    final isLocalFile = !isNetwork;

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image:
              isNetwork
                  ? NetworkImage(url)
                  : (isLocalFile && File(url).existsSync()
                      ? FileImage(File(url))
                      : AssetImage(url) as ImageProvider),
          fit: BoxFit.cover,
        ),
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
                Align(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Record Payment",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  "Enter the amount received for this order",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: "Amount Received",
                    prefixText: "\$ ",
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(14)),
                      borderSide: BorderSide(
                        color: OrderDetailsScreen.primaryPurple,
                        width: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: OrderDetailsScreen.primaryPurple,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final val = double.tryParse(controller.text);
                          if (val != null && val > 0) {
                            _addPayment(val);
                            Navigator.pop(context); // Close the sheet
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Enter a valid payment amount greater than 0',
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          "Confirm",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
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
