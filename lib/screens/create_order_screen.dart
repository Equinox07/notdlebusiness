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
  DateTime? _dueDate;
  String? _notes;
  String? _paymentAmount;
  String _outfitType = "Evening Gown";
  String _fabric = "";
  int _quantity = 1;

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
      initialDate: _dueDate ?? DateTime.now(),
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

    final newOrder = Order(
      id: const Uuid().v4(),
      title: title,
      customerId: _selectedCustomer!.id!,
      status: _status,
      paymentStatus: _paymentStatus,
      paymentAmount: double.tryParse(_paymentAmount ?? '0'),
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
                    dueDate: _dueDate,
                    status: _status,
                    paymentStatus: _paymentStatus,
                    paymentAmount: _paymentAmount,
                    orderStatuses: _orderStatuses,
                    paymentStatuses: _paymentStatuses,
                    onDueDateTap: () => _selectDueDate(context),
                    onStatusChanged: (v) => setState(() => _status = v!),
                    onPaymentStatusChanged:
                        (v) => setState(() => _paymentStatus = v!),
                    onPaymentAmountSaved: (v) => _paymentAmount = v,
                    onTitleSaved: (v) => _orderTitle = v ?? '',
                    onNotesSaved: (v) => _notes = v,
                  ),
                  const SizedBox(height: 16),
                  _DesignInspirationCard(),
                  const SizedBox(height: 16),
                  _FabricSamplesCard(),
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
  final DateTime? dueDate;
  final String status;
  final String paymentStatus;
  final String? paymentAmount;
  final List<String> orderStatuses;
  final List<String> paymentStatuses;
  final VoidCallback onDueDateTap;
  final ValueChanged<String?> onStatusChanged;
  final ValueChanged<String?> onPaymentStatusChanged;
  final FormFieldSetter<String?> onPaymentAmountSaved;
  final FormFieldSetter<String?> onTitleSaved;
  final FormFieldSetter<String?> onNotesSaved;

  const _AdvancedDetailsCard({
    required this.dueDate,
    required this.status,
    required this.paymentStatus,
    required this.paymentAmount,
    required this.orderStatuses,
    required this.paymentStatuses,
    required this.onDueDateTap,
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
          // Due date
          _FieldLabel("Due Date"),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: onDueDateTap,
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
                  const SizedBox(width: 10),
                  Text(
                    dueDate != null
                        ? DateFormat('MMMM d, yyyy').format(dueDate!)
                        : "Select a date",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color:
                          dueDate != null
                              ? Colors.black87
                              : Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
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

// ── FABRIC SAMPLES CARD ─────────────────────────────────────────────────────

class _FabricSamplesCard extends StatelessWidget {
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
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.colorize_outlined,
                  color: Colors.amber.shade700,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                "Fabric Samples",
                style: GoogleFonts.poppins(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            "Attach physical fabric swatches or colour references",
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 14),
          // Upload zone
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade300, width: 1.5),
                color: Colors.amber.shade50.withValues(alpha: 0.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.amber.shade600,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.upload_file_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Upload Fabric Sample",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "JPG, PNG or PDF · Max 10 MB",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          // Thumbnail strip
          Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.amber.shade100,
                ),
                child: Icon(
                  Icons.texture,
                  color: Colors.amber.shade700,
                  size: 30,
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: const Icon(Icons.add, color: Colors.grey, size: 28),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DesignInspirationCard extends StatelessWidget {
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
          const SizedBox(height: 14),
          // Dashed upload zone
          GestureDetector(
            onTap: () {},
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _kPurple.withValues(alpha: 0.3),
                  width: 1.5,
                  // Flutter doesn't support dashed borders natively; use a
                  // solid thin border with a very light fill as an approximation.
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
                      Icons.cloud_upload_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Upload Reference",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Add fabric swatches, design sketches,\nor mood board photos",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Placeholder thumbnail
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                  image: const DecorationImage(
                    image: AssetImage('assets/images/fabric_sample.png'),
                    fit: BoxFit.cover,
                    onError: _imageErrorHandler,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Add more button
              GestureDetector(
                onTap: () {},
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade100,
                    border: Border.all(color: Colors.grey.shade300, width: 1.5),
                  ),
                  child: const Icon(Icons.add, color: Colors.grey, size: 28),
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
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
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
