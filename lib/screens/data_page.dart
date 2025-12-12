import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/providers/invoice_provider.dart';
import 'package:notdle/providers/measurement_provider.dart';
import 'package:notdle/providers/order_provider.dart';
import 'package:notdle/services/sync_service.dart';
import 'package:provider/provider.dart';

class SyncStats {
  final int unsyncedCount;
  final DateTime? lastSyncDate;

  SyncStats({required this.unsyncedCount, this.lastSyncDate});
}

class DataPage extends StatefulWidget {
  static const String tag = "data_page";
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  late final SyncService _syncService;
  final Map<String, bool> _syncingStatus = {
    'clients': false,
    'measurements': false,
    'orders': false,
    'invoices': false,
  };

  Map<String, SyncStats> _stats = {};

  @override
  void initState() {
    super.initState();
    _syncService = SyncService(context);
    _loadSyncStats();
  }

  Future<void> _loadSyncStats() async {
    if (!mounted) return;

    // Clients
    final customerProvider = Provider.of<CustomerProvider>(
      context,
      listen: false,
    );
    final customers = await customerProvider.customerDao.getAllCustomers();
    final unsyncedClients = customers.where((c) => !c.isSynced).length;
    final lastSyncClient = customers
        .where((c) => c.syncDate != null)
        .map((c) => c.syncDate!)
        .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);

    // Measurements
    final measurementProvider = Provider.of<MeasurementProvider>(
      context,
      listen: false,
    );
    final measurements =
        await measurementProvider.measurementDao.getAllMeasurements();
    final unsyncedMeasurements = measurements.where((m) => !m.isSynced).length;
    final lastSyncMeasurement = measurements
        .where((m) => m.syncDate != null)
        .map((m) => m.syncDate!)
        .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);

    // Orders
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final orders = await orderProvider.orderDao.getAllOrders();
    final unsyncedOrders = orders.where((o) => !o.isSynced).length;
    final lastSyncOrder = orders
        .where((o) => o.syncDate != null)
        .map((o) => o.syncDate!)
        .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);

    // Invoices
    final invoiceProvider = Provider.of<InvoiceProvider>(
      context,
      listen: false,
    );
    final invoices = await invoiceProvider.invoiceDao.getAllInvoices();
    final unsyncedInvoices = invoices.where((i) => !i.isSynced).length;
    final lastSyncInvoice = invoices
        .where((i) => i.syncDate != null)
        .map((i) => i.syncDate!)
        .fold<DateTime?>(null, (a, b) => a == null || b.isAfter(a) ? b : a);

    setState(() {
      _stats = {
        'clients': SyncStats(
          unsyncedCount: unsyncedClients,
          lastSyncDate: lastSyncClient,
        ),
        'measurements': SyncStats(
          unsyncedCount: unsyncedMeasurements,
          lastSyncDate: lastSyncMeasurement,
        ),
        'orders': SyncStats(
          unsyncedCount: unsyncedOrders,
          lastSyncDate: lastSyncOrder,
        ),
        'invoices': SyncStats(
          unsyncedCount: unsyncedInvoices,
          lastSyncDate: lastSyncInvoice,
        ),
      };
    });
  }

  Future<void> _syncAll() async {
    setState(() {
      _syncingStatus.updateAll((key, value) => true);
    });
    await _syncService.syncAll();
    await _loadSyncStats();
    setState(() {
      _syncingStatus.updateAll((key, value) => false);
    });
  }

  Future<void> _sync(String model) async {
    setState(() {
      _syncingStatus[model] = true;
    });
    switch (model) {
      case 'clients':
        await _syncService.syncClients();
        break;
      case 'measurements':
        await _syncService.syncMeasurements();
        break;
      case 'orders':
        await _syncService.syncOrders();
        break;
      case 'invoices':
        await _syncService.syncInvoices();
        break;
    }
    await _loadSyncStats();
    setState(() {
      _syncingStatus[model] = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          'Data Synchronization',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSyncAllButton(),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildSyncItem('Clients', 'clients', Icons.people_outline),
                  _buildSyncItem(
                    'Measurements',
                    'measurements',
                    Icons.square_foot_outlined,
                  ),
                  _buildSyncItem(
                    'Orders',
                    'orders',
                    Icons.shopping_cart_outlined,
                  ),
                  _buildSyncItem(
                    'Invoices',
                    'invoices',
                    Icons.receipt_long_outlined,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncAllButton() {
    final isSyncing = _syncingStatus.values.any((s) => s);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, Colors.indigo.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSyncing ? null : _syncAll,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isSyncing)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                  )
                else
                  const Icon(Icons.sync, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Text(
                  isSyncing ? 'Syncing All Data...' : 'Sync All Data',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSyncItem(String title, String model, IconData icon) {
    final stats = _stats[model];
    final isSyncing = _syncingStatus[model] ?? false;
    final lastSync =
        stats?.lastSyncDate != null
            ? DateFormat('MMM d, h:mm a').format(stats!.lastSyncDate!)
            : 'Never synced';
    final unsyncedCount = stats?.unsyncedCount ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isSyncing ? null : () => _sync(model),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.indigo, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Last synced: $lastSync',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSyncing)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.indigo.shade600,
                      ),
                    ),
                  )
                else if (unsyncedCount > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sync_problem,
                          size: 14,
                          color: Colors.orange.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$unsyncedCount pending',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: Colors.green.shade600,
                    ),
                  ),
                if (!isSyncing) ...[
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _sync(model),
                    icon: Icon(Icons.sync, color: Colors.indigo.shade400),
                    tooltip: 'Sync $title',
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
