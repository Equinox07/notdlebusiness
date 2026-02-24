// lib/screens/create_order_screen.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/providers/dashboard_provider.dart';
import 'package:notdle/providers/invoice_provider.dart';
import 'package:notdle/providers/order_provider.dart';
import 'package:notdle/screens/invoice_details_screen.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

const _kPurple = Color(0xFF6200EE);
const _kBg = Color(0xFFF5F4F8);

class CreateOrderScreen extends StatefulWidget {
  final Customer? customer;
  const CreateOrderScreen({super.key, this.customer});
  static const String tag = "create_order";

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Form state ──────────────────────────────────────────────────────────
  String _orderTitle = "";
  Customer? _selectedCustomer;
  String _clientSearch = "";
  String _status = "In Progress";
  String _paymentStatus = "Unpaid";
  DateTime? _startDate;
  DateTime? _dueDate;
  String? _notes;
  String? _paymentAmount;
  String _outfitType = "Evening Gown";
  String _fabric = "";
  int _quantity = 1;
  List<XFile> _inspirationImages = [];

  // ── Pricing state ────────────────────────────────────────────────────────
  double _materialCost = 0;
  double _laborCost = 0;
  bool _depositReceived = false;
  double _depositAmount = 0;

  late Future<List<Customer>> _customersFuture;

  static const List<String> _outfitTypes = [
    "Evening Gown",
    "Wedding Dress",
    "Suit",
    "Casual Wear",
    "Traditional",
    "Other",
  ];

  static const List<String> _orderStatuses = [
    "Pending",
    "In Progress",
    "Ready",
    "Delivered",
    "Cancelled",
  ];
  static const List<String> _paymentStatuses = ["Unpaid", "Partial", "Paid"];

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) _selectedCustomer = widget.customer;
    _customersFuture = _loadCustomers();
  }

  Future<List<Customer>> _loadCustomers() async {
    final cp = Provider.of<CustomerProvider>(context, listen: false);
    await cp.fetchCustomers();
    final customers = cp.customers;
    if (widget.customer != null) {
      try {
        _selectedCustomer = customers.firstWhere(
          (c) => c.id == widget.customer!.id,
        );
      } catch (_) {
        _selectedCustomer = null;
      }
    } else if (customers.isNotEmpty && _selectedCustomer == null) {
      setState(() => _selectedCustomer = customers.first);
    }
    return customers;
  }

  Future<void> _selectDueDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2101),
      builder:
          (context, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: _kPurple,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black87,
              ),
              dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
            ),
            child: child!,
          ),
    );
    if (picked != null && picked != _dueDate) setState(() => _dueDate = picked);
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime(2101),
      builder:
          (context, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(
                primary: _kPurple,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: Colors.black87,
              ),
              dialogTheme: const DialogThemeData(backgroundColor: Colors.white),
            ),
            child: child!,
          ),
    );
    if (picked != null && picked != _startDate) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _inspirationImages.add(image);
      });
    }
  }

  Future<void> _pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        _inspirationImages.addAll(images);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _inspirationImages.removeAt(index);
    });
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (_selectedCustomer == null || _selectedCustomer!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a client", style: GoogleFonts.poppins()),
        ),
      );
      return;
    }

    final title =
        _orderTitle.isNotEmpty
            ? _orderTitle
            : "$_outfitType for ${_selectedCustomer!.name}";

    final totalAmount = _materialCost + _laborCost;
    final effectivePaymentAmount =
        _depositReceived
            ? _depositAmount
            : (totalAmount > 0
                ? totalAmount
                : double.tryParse(_paymentAmount ?? '0') ?? 0);

    final newOrder = Order(
      id: const Uuid().v4(),
      title: title,
      customerId: _selectedCustomer!.id!,
      status: _status,
      paymentStatus: _paymentStatus,
      paymentAmount:
          effectivePaymentAmount > 0
              ? effectivePaymentAmount
              : double.tryParse(_paymentAmount ?? '0'),
      dueDate:
          _dueDate != null ? DateFormat('yyyy-MM-dd').format(_dueDate!) : null,
      notes: _notes ?? '',
      createdDate: DateTime.now().toIso8601String(),
    );

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final dashProvider = Provider.of<DashBoardProvider>(context, listen: false);
    await orderProvider.addOrder(newOrder);
    dashProvider.fetchCounts();

    if (!mounted) return;

    showDialog(
      context: context,
      builder:
          (dialogContext) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              "Order Created",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            content: Text(
              "Would you like to generate an invoice for this order?",
              style: GoogleFonts.poppins(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Later",
                  style: GoogleFonts.poppins(color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  _generateInvoice(newOrder);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Create Invoice",
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void _generateInvoice(Order newOrder) async {
    final newInvoice = Invoice(
      id: const Uuid().v4(),
      title: 'Invoice for ${newOrder.title}',
      customerId: newOrder.customerId,
      status: 'Pending',
      total: newOrder.paymentAmount ?? 0.0,
      date: DateTime.now(),
      orderId: newOrder.id,
    );
    await Provider.of<InvoiceProvider>(
      context,
      listen: false,
    ).addInvoice(newInvoice);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => InvoiceDetailsScreen(invoice: newInvoice),
      ),
    );
  }

  // ── BUILD ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: FutureBuilder<List<Customer>>(
          future: _customersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.isEmpty) {
              return _buildNoCustomers();
            }
            return _buildPage(snapshot.data!);
          },
        ),
      ),
    );
  }

  Widget _buildNoCustomers() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_alt_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              "No Clients Found",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Add a client before creating an order.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(List<Customer> customers) {
    return Column(
      children: [
        _TopBar(),
        _StepHeader(step: 1, totalSteps: 4, label: "Client & Details"),
        Expanded(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SelectClientCard(
                    customers: customers,
                    selectedCustomer: _selectedCustomer,
                    clientSearch: _clientSearch,
                    canChange: widget.customer == null,
                    onSearchChanged: (v) => setState(() => _clientSearch = v),
                    onClientSelected:
                        (c) => setState(() => _selectedCustomer = c),
                  ),
                  const SizedBox(height: 16),
                  _OutfitDetailsCard(
                    outfitType: _outfitType,
                    outfitTypes: _outfitTypes,
                    fabric: _fabric,
                    quantity: _quantity,
                    onOutfitTypeChanged:
                        (v) => setState(() => _outfitType = v!),
                    onFabricChanged: (v) => _fabric = v ?? '',
                    onQuantityChanged: (v) => setState(() => _quantity = v),
                  ),
                  const SizedBox(height: 16),
                  _AdvancedDetailsCard(
                    status: _status,
                    paymentStatus: _paymentStatus,
                    paymentAmount: _paymentAmount,
                    orderStatuses: _orderStatuses,
                    paymentStatuses: _paymentStatuses,
                    onStatusChanged: (v) => setState(() => _status = v!),
                    onPaymentStatusChanged:
                        (v) => setState(() => _paymentStatus = v!),
                    onPaymentAmountSaved: (v) => _paymentAmount = v,
                    onTitleSaved: (v) => _orderTitle = v ?? '',
                    onNotesSaved: (v) => _notes = v,
                  ),
                  const SizedBox(height: 16),
                  _DesignInspirationCard(
                    inspirationImages: _inspirationImages,
                    onPickFromCamera: _pickImageFromCamera,
                    onPickFromGallery: _pickImageFromGallery,
                    onRemoveImage: _removeImage,
                  ),
                  const SizedBox(height: 16),
                  // ── Step 3: Pricing & Payments ─────────────────────────────
                  _SectionStepLabel(
                    step: 3,
                    totalSteps: 4,
                    label: 'Pricing & Payments',
                  ),
                  const SizedBox(height: 12),
                  _PricingPaymentsCard(
                    materialCost: _materialCost,
                    laborCost: _laborCost,
                    depositReceived: _depositReceived,
                    depositAmount: _depositAmount,
                    onMaterialCostChanged:
                        (v) => setState(() => _materialCost = v),
                    onLaborCostChanged: (v) => setState(() => _laborCost = v),
                    onDepositToggled:
                        (v) => setState(() => _depositReceived = v),
                    onDepositAmountChanged:
                        (v) => setState(() => _depositAmount = v),
                  ),
                  const SizedBox(height: 24),
                  // ── Step 4 preview label ────────────────────────────────────
                  _SectionStepLabel(
                    step: 4,
                    totalSteps: 4,
                    label: 'Production Timeline',
                  ),
                  const SizedBox(height: 12),
                  _ProductionTimelineCard(
                    startDate: _startDate,
                    dueDate: _dueDate,
                    onSelectStartDate: () => _selectStartDate(context),
                    onSelectDueDate: () => _selectDueDate(context),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),

        // ── Bottom CTA ────────────────────────────────────────────────────
        _BottomCTA(onTap: _submitForm),
      ],
    );
  }
}

// ── TOP BAR ──────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, size: 22, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          Text(
            "New Order",
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: Text(
              "Drafts",
              style: GoogleFonts.poppins(
                color: _kPurple,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── STEP PROGRESS HEADER ─────────────────────────────────────────────────────

class _StepHeader extends StatelessWidget {
  final int step;
  final int totalSteps;
  final String label;
  const _StepHeader({
    required this.step,
    required this.totalSteps,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "STEP $step OF $totalSteps",
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: _kPurple,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(totalSteps, (i) {
              final active = i < step;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < totalSteps - 1 ? 6 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    color: active ? _kPurple : Colors.grey.shade200,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── SELECT CLIENT CARD ───────────────────────────────────────────────────────

class _SelectClientCard extends StatelessWidget {
  final List<Customer> customers;
  final Customer? selectedCustomer;
  final String clientSearch;
  final bool canChange;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<Customer> onClientSelected;

  const _SelectClientCard({
    required this.customers,
    required this.selectedCustomer,
    required this.clientSearch,
    required this.canChange,
    required this.onSearchChanged,
    required this.onClientSelected,
  });

  List<Customer> get _filtered =>
      clientSearch.isEmpty
          ? customers.take(5).toList()
          : customers
              .where(
                (c) =>
                    c.name.toLowerCase().contains(clientSearch.toLowerCase()),
              )
              .take(5)
              .toList();

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Select Client",
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (canChange)
                _PillButton(
                  label: "Quick Add",
                  icon: Icons.person_add_alt_1,
                  onTap: () {},
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Who is this order for?",
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 12),
          // Search field
          if (canChange) ...[
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF0EFF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: onSearchChanged,
                style: GoogleFonts.poppins(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Search existing clients...",
                  hintStyle: GoogleFonts.poppins(
                    color: Colors.grey.shade400,
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: Colors.grey.shade400,
                    size: 20,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          // Client avatars
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  _filtered.map((c) {
                    final isSelected = selectedCustomer?.id == c.id;
                    final initials =
                        c.name
                            .trim()
                            .split(' ')
                            .where((w) => w.isNotEmpty)
                            .take(2)
                            .map((w) => w[0].toUpperCase())
                            .join();
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: GestureDetector(
                        onTap: canChange ? () => onClientSelected(c) : null,
                        child: Column(
                          children: [
                            Container(
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    isSelected
                                        ? _kPurple.withValues(alpha: 0.12)
                                        : Colors.grey.shade100,
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? _kPurple
                                          : Colors.transparent,
                                  width: 2.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  initials,
                                  style: GoogleFonts.poppins(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        isSelected
                                            ? _kPurple
                                            : Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c.name.split(' ').first +
                                  (c.name.split(' ').length > 1
                                      ? ' ${c.name.split(' ').last[0]}.'
                                      : ''),
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── OUTFIT DETAILS CARD ───────────────────────────────────────────────────────

class _OutfitDetailsCard extends StatelessWidget {
  final String outfitType;
  final List<String> outfitTypes;
  final String fabric;
  final int quantity;
  final ValueChanged<String?> onOutfitTypeChanged;
  final FormFieldSetter<String?> onFabricChanged;
  final ValueChanged<int> onQuantityChanged;

  const _OutfitDetailsCard({
    required this.outfitType,
    required this.outfitTypes,
    required this.fabric,
    required this.quantity,
    required this.onOutfitTypeChanged,
    required this.onFabricChanged,
    required this.onQuantityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Outfit Details",
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Outfit Type",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: outfitType,
            style: GoogleFonts.poppins(color: Colors.black87, fontSize: 14),
            decoration: _inputDeco(null),
            items:
                outfitTypes
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text(
                          t,
                          style: GoogleFonts.poppins(fontSize: 14),
                        ),
                      ),
                    )
                    .toList(),
            onChanged: onOutfitTypeChanged,
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Fabric",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: _inputDeco("e.g. Silk Charmeuse"),
                      onSaved: onFabricChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Quantity",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  _QuantityStepper(
                    value: quantity,
                    onChanged: onQuantityChanged,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── ADVANCED DETAILS CARD ────────────────────────────────────────────────────

class _AdvancedDetailsCard extends StatelessWidget {
  final String status;
  final String paymentStatus;
  final String? paymentAmount;
  final List<String> orderStatuses;
  final List<String> paymentStatuses;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onPaymentStatusChanged;
  final FormFieldSetter<String?> onPaymentAmountSaved;
  final FormFieldSetter<String?> onTitleSaved;
  final FormFieldSetter<String?> onNotesSaved;

  const _AdvancedDetailsCard({
    required this.status,
    required this.paymentStatus,
    required this.paymentAmount,
    required this.orderStatuses,
    required this.paymentStatuses,
    required this.onStatusChanged,
    required this.onPaymentStatusChanged,
    required this.onPaymentAmountSaved,
    required this.onTitleSaved,
    required this.onNotesSaved,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Order Details",
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // Title
          _FieldLabel("Order Title (Optional)"),
          const SizedBox(height: 6),
          TextFormField(
            style: GoogleFonts.poppins(fontSize: 14),
            decoration: _inputDeco("e.g. Custom Wedding Dress"),
            onSaved: onTitleSaved,
          ),
          const SizedBox(height: 14),
          // Status + Payment row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel("Order Status"),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: status,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      decoration: _inputDeco(null),
                      items:
                          orderStatuses
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: onStatusChanged,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _FieldLabel("Payment"),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: paymentStatus,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 14,
                      ),
                      decoration: _inputDeco(null),
                      items:
                          paymentStatuses
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s,
                                  child: Text(
                                    s,
                                    style: GoogleFonts.poppins(fontSize: 13),
                                  ),
                                ),
                              )
                              .toList(),
                      onChanged: onPaymentStatusChanged,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (paymentStatus != "Unpaid") ...[
            const SizedBox(height: 14),
            _FieldLabel("Amount Paid"),
            const SizedBox(height: 6),
            TextFormField(
              style: GoogleFonts.poppins(fontSize: 14),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: _inputDeco("e.g. 250.00"),
              onSaved: onPaymentAmountSaved,
              validator: (v) {
                if (v == null || v.isEmpty) return "Required";
                if (double.tryParse(v) == null) return "Invalid number";
                return null;
              },
            ),
          ],
          const SizedBox(height: 14),
          _FieldLabel("Notes (Optional)"),
          const SizedBox(height: 6),
          TextFormField(
            style: GoogleFonts.poppins(fontSize: 14),
            maxLines: 3,
            decoration: _inputDeco("Specific details or requests..."),
            onSaved: onNotesSaved,
            validator: (_) => null,
          ),
        ],
      ),
    );
  }
}

// ── DESIGN INSPIRATION CARD ───────────────────────────────────────────────────

// ── PRICING & PAYMENTS CARD ──────────────────────────────────────────────────

class _SectionStepLabel extends StatelessWidget {
  final int step;
  final int totalSteps;
  final String label;
  const _SectionStepLabel({
    required this.step,
    required this.totalSteps,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3D0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'STEP $step OF $totalSteps',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFB8860B),
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _PricingPaymentsCard extends StatefulWidget {
  final double materialCost;
  final double laborCost;
  final bool depositReceived;
  final double depositAmount;
  final ValueChanged<double> onMaterialCostChanged;
  final ValueChanged<double> onLaborCostChanged;
  final ValueChanged<bool> onDepositToggled;
  final ValueChanged<double> onDepositAmountChanged;

  const _PricingPaymentsCard({
    required this.materialCost,
    required this.laborCost,
    required this.depositReceived,
    required this.depositAmount,
    required this.onMaterialCostChanged,
    required this.onLaborCostChanged,
    required this.onDepositToggled,
    required this.onDepositAmountChanged,
  });

  @override
  State<_PricingPaymentsCard> createState() => _PricingPaymentsCardState();
}

class _PricingPaymentsCardState extends State<_PricingPaymentsCard> {
  late final TextEditingController _materialCtrl;
  late final TextEditingController _laborCtrl;
  late final TextEditingController _depositCtrl;

  @override
  void initState() {
    super.initState();
    _materialCtrl = TextEditingController(
      text:
          widget.materialCost > 0 ? widget.materialCost.toStringAsFixed(2) : '',
    );
    _laborCtrl = TextEditingController(
      text: widget.laborCost > 0 ? widget.laborCost.toStringAsFixed(2) : '',
    );
    _depositCtrl = TextEditingController(
      text:
          widget.depositAmount > 0
              ? widget.depositAmount.toStringAsFixed(2)
              : '',
    );
  }

  @override
  void dispose() {
    _materialCtrl.dispose();
    _laborCtrl.dispose();
    _depositCtrl.dispose();
    super.dispose();
  }

  double get _total => widget.materialCost + widget.laborCost;
  double get _remaining =>
      _total - (widget.depositReceived ? widget.depositAmount : 0);

  @override
  Widget build(BuildContext context) {
    final currencyFmt = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Material Cost
          _FieldLabel('Material Cost'),
          const SizedBox(height: 6),
          _CurrencyField(
            controller: _materialCtrl,
            hint: '0.00',
            onChanged:
                (v) => widget.onMaterialCostChanged(double.tryParse(v) ?? 0),
          ),
          const SizedBox(height: 14),
          // Labor Cost
          _FieldLabel('Labor Cost'),
          const SizedBox(height: 6),
          _CurrencyField(
            controller: _laborCtrl,
            hint: '0.00',
            onChanged:
                (v) => widget.onLaborCostChanged(double.tryParse(v) ?? 0),
          ),
          const SizedBox(height: 16),
          // Dashed divider
          _DashedDivider(),
          const SizedBox(height: 14),
          // Total Amount row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                ),
              ),
              Text(
                currencyFmt.format(_total),
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          // Deposit Received row
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Deposit Received',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Enable to record partial payment',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: widget.depositReceived,
                onChanged: widget.onDepositToggled,
                activeColor: Colors.white,
                activeTrackColor: _kPurple,
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
                trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              ),
            ],
          ),
          // Deposit Amount + Remaining Balance (shown when toggle on)
          if (widget.depositReceived) ...[
            const SizedBox(height: 14),
            _CurrencyField(
              controller: _depositCtrl,
              hint: '0.00',
              highlighted: true,
              onChanged:
                  (v) => widget.onDepositAmountChanged(double.tryParse(v) ?? 0),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F0FF),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Remaining Balance',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    currencyFmt.format(_remaining < 0 ? 0 : _remaining),
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _kPurple,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A text field with a $ prefix icon for currency input.
class _CurrencyField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool highlighted;
  final ValueChanged<String> onChanged;

  const _CurrencyField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color:
            highlighted
                ? _kPurple.withValues(alpha: 0.07)
                : const Color(0xFFF0EFF4),
        borderRadius: BorderRadius.circular(14),
        border:
            highlighted
                ? Border.all(color: _kPurple.withValues(alpha: 0.4), width: 1.5)
                : null,
      ),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        onChanged: onChanged,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: highlighted ? FontWeight.w600 : FontWeight.normal,
          color: highlighted ? _kPurple : Colors.black87,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color:
                highlighted
                    ? _kPurple.withValues(alpha: 0.5)
                    : Colors.grey.shade400,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            Icons.attach_money_rounded,
            size: 18,
            color: highlighted ? _kPurple : Colors.grey.shade400,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }
}

/// A simple dashed divider drawn via a CustomPaint.
class _DashedDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 1,
      width: double.infinity,
      child: CustomPaint(painter: _DashedLinePainter()),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final paint =
        Paint()
          ..color = const Color(0xFFD0CDE8)
          ..strokeWidth = 1.2
          ..style = PaintingStyle.stroke;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => false;
}

class _DesignInspirationCard extends StatelessWidget {
  final List<XFile> inspirationImages;
  final VoidCallback onPickFromCamera;
  final VoidCallback onPickFromGallery;
  final Function(int) onRemoveImage;

  const _DesignInspirationCard({
    required this.inspirationImages,
    required this.onPickFromCamera,
    required this.onPickFromGallery,
    required this.onRemoveImage,
  });

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            "Add Inspiration",
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _kPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.camera_alt_outlined, color: _kPurple),
                ),
                title: Text(
                  "Take Photo",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  "Use camera to capture inspiration",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onPickFromCamera();
                },
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _kPurple.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.photo_library_outlined, color: _kPurple),
                ),
                title: Text(
                  "Choose from Gallery",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  "Select multiple photos from gallery",
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
                ),
                onTap: () {
                  Navigator.of(context).pop();
                  onPickFromGallery();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.grey.shade600),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Design Inspiration",
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Add fabric swatches, design sketches, or mood board photos",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 14),
          
          // Upload zone or image grid
          if (inspirationImages.isEmpty)
            GestureDetector(
              onTap: () => _showImageSourceDialog(context),
              child: Container(
                width: double.infinity,
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _kPurple.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  color: _kPurple.withValues(alpha: 0.03),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                        color: _kPurple,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Add Inspiration Photos",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Tap to choose from camera or gallery",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Column(
              children: [
                // Image grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1,
                  ),
                  itemCount: inspirationImages.length + 1, // +1 for add button
                  itemBuilder: (context, index) {
                    if (index == inspirationImages.length) {
                      // Add more button
                      return GestureDetector(
                        onTap: () => _showImageSourceDialog(context),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade100,
                            border: Border.all(color: Colors.grey.shade300, width: 1.5),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Colors.grey.shade600, size: 28),
                              const SizedBox(height: 4),
                              Text(
                                "Add More",
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    // Image thumbnail
                    return Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey.shade200,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(inspirationImages[index].path),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.grey.shade400,
                                    size: 30,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        // Remove button
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () => onRemoveImage(index),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 12),
                // Quick add button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showImageSourceDialog(context),
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(
                      "Add More Photos",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: BorderSide(color: _kPurple.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

void _imageErrorHandler(Object exception, StackTrace? stackTrace) {}

// ── BOTTOM CTA ────────────────────────────────────────────────────────────────

class _BottomCTA extends StatelessWidget {
  final VoidCallback onTap;
  const _BottomCTA({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: _kBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF7B2FFF), _kPurple],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: _kPurple.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Create Order",
                style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

// ── SHARED HELPERS ────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        fontSize: 12,
        color: Colors.grey.shade500,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _PillButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: _kPurple.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: _kPurple),
            const SizedBox(width: 5),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: _kPurple,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _QuantityStepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0EFF4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepBtn(
            icon: Icons.remove,
            onTap: () => onChanged(value > 1 ? value - 1 : 1),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "$value",
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _StepBtn(icon: Icons.add, onTap: () => onChanged(value + 1)),
        ],
      ),
    );
  }
}

class _StepBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.black87),
      ),
    );
  }
}

InputDecoration _inputDeco(String? hint) {
  return InputDecoration(
    hintText: hint,
    hintStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
    filled: true,
    fillColor: const Color(0xFFF0EFF4),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: _kPurple, width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  );
}

class _ProductionTimelineCard extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? dueDate;
  final VoidCallback onSelectStartDate;
  final VoidCallback onSelectDueDate;

  const _ProductionTimelineCard({
    required this.startDate,
    required this.dueDate,
    required this.onSelectStartDate,
    required this.onSelectDueDate,
  });

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: _kPurple.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.timer_outlined, color: _kPurple, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                "Production Timeline",
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _DateTile(
                  label: "Start Date",
                  date: startDate,
                  onTap: onSelectStartDate,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _DateTile(
                  label: "Due Date",
                  date: dueDate,
                  onTap: onSelectDueDate,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _FieldLabel("Production Phases"),
          const SizedBox(height: 12),
          _ProductionPhasesTimeline(startDate: startDate, dueDate: dueDate),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateTile({required this.label, this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(
              color: const Color(0xFFF0EFF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null
                        ? DateFormat('MMM d, yyyy').format(date!)
                        : "Select",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color:
                          date != null ? Colors.black87 : Colors.grey.shade400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductionPhasesTimeline extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? dueDate;

  const _ProductionPhasesTimeline({this.startDate, this.dueDate});

  List<Map<String, dynamic>> _getPhases() {
    if (startDate == null || dueDate == null) {
      return [
        {'name': 'Design', 'icon': Icons.design_services, 'status': 'pending'},
        {'name': 'Cutting', 'icon': Icons.content_cut, 'status': 'pending'},
        {'name': 'Sewing', 'icon': Icons.mode_edit, 'status': 'pending'},
        {'name': 'Fittings', 'icon': Icons.accessibility, 'status': 'pending'},
        {'name': 'Final Touches', 'icon': Icons.auto_fix_high, 'status': 'pending'},
        {'name': 'Quality Check', 'icon': Icons.verified, 'status': 'pending'},
      ];
    }

    final totalDays = dueDate!.difference(startDate!).inDays;
    final currentPhase = _getCurrentPhase(totalDays);
    
    return [
      {'name': 'Design', 'icon': Icons.design_services, 'status': currentPhase >= 0 ? 'completed' : 'pending'},
      {'name': 'Cutting', 'icon': Icons.content_cut, 'status': currentPhase >= 1 ? 'completed' : currentPhase == 0 ? 'active' : 'pending'},
      {'name': 'Sewing', 'icon': Icons.mode_edit, 'status': currentPhase >= 2 ? 'completed' : currentPhase == 1 ? 'active' : 'pending'},
      {'name': 'Fittings', 'icon': Icons.accessibility, 'status': currentPhase >= 3 ? 'completed' : currentPhase == 2 ? 'active' : 'pending'},
      {'name': 'Final Touches', 'icon': Icons.auto_fix_high, 'status': currentPhase >= 4 ? 'completed' : currentPhase == 3 ? 'active' : 'pending'},
      {'name': 'Quality Check', 'icon': Icons.verified, 'status': currentPhase >= 5 ? 'completed' : currentPhase == 4 ? 'active' : 'pending'},
    ];
  }

  int _getCurrentPhase(int totalDays) {
    if (totalDays <= 0) return -1;
    final daysPerPhase = (totalDays / 6).floor();
    final elapsedDays = DateTime.now().difference(startDate!).inDays;
    return (elapsedDays / daysPerPhase).floor().clamp(0, 5);
  }

  String _getPhaseDate(int phaseIndex) {
    if (startDate == null || dueDate == null) return '';
    final totalDays = dueDate!.difference(startDate!).inDays;
    final daysPerPhase = (totalDays / 6).ceil();
    final phaseDate = startDate!.add(Duration(days: phaseIndex * daysPerPhase));
    return DateFormat('MMM d').format(phaseDate);
  }

  @override
  Widget build(BuildContext context) {
    if (startDate == null || dueDate == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(Icons.calendar_today_outlined, size: 32, color: Colors.grey.shade400),
            const SizedBox(height: 8),
            Text(
              "Select dates to see production phases",
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    final phases = _getPhases();
    final totalDays = dueDate!.difference(startDate!).inDays;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kPurple.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _kPurple.withValues(alpha: 0.08)),
      ),
      child: Column(
        children: [
          // Duration info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Duration",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                "$totalDays Days",
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: _kPurple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          
          // Phases timeline
          Column(
            children: phases.asMap().entries.map((entry) {
              final index = entry.key;
              final phase = entry.value;
              final isLast = index == phases.length - 1;
              final status = phase['status'] as String;
              
              return _PhaseItem(
                name: phase['name'] as String,
                icon: phase['icon'] as IconData,
                status: status,
                date: _getPhaseDate(index),
                showConnector: !isLast,
                isActive: status == 'active',
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _PhaseItem extends StatelessWidget {
  final String name;
  final IconData icon;
  final String status;
  final String date;
  final bool showConnector;
  final bool isActive;

  const _PhaseItem({
    required this.name,
    required this.icon,
    required this.status,
    required this.date,
    required this.showConnector,
    required this.isActive,
  });

  Color get _statusColor {
    switch (status) {
      case 'completed':
        return _kPurple;
      case 'active':
        return const Color(0xFF6200EE);
      default:
        return Colors.grey.shade300;
    }
  }

  Color get _textColor {
    switch (status) {
      case 'completed':
        return Colors.black87;
      case 'active':
        return _kPurple;
      default:
        return Colors.grey.shade500;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon with connector
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: status == 'pending' ? 0.1 : 0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _statusColor,
                  width: status == 'active' ? 2 : 1.5,
                ),
              ),
              child: Icon(
                icon,
                size: 16,
                color: _statusColor,
              ),
            ),
            if (showConnector)
              Container(
                width: 2,
                height: 32,
                margin: const EdgeInsets.only(top: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        
        // Phase info
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _textColor,
                      ),
                    ),
                    if (isActive)
                      Text(
                        "In Progress",
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: _kPurple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                Text(
                  date,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
