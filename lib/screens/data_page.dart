import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notdle/services/sync_service.dart';
import 'package:provider/provider.dart';

class DataPage extends StatefulWidget {
  const DataPage({super.key});

  @override
  State<DataPage> createState() => _DataPageState();
}

class _DataPageState extends State<DataPage> {
  late final SyncService _syncService;
  final Map<String, bool> _syncStatus = {
    'clients': false,
    'measurements': false,
    'orders': false,
    'invoices': false,
  };

  @override
  void initState() {
    super.initState();
    _syncService = SyncService(context);
  }

  Future<void> _syncAll() async {
    setState(() {
      _syncStatus.updateAll((key, value) => true);
    });
    await _syncService.syncAll();
    setState(() {
      _syncStatus.updateAll((key, value) => false);
    });
  }

  Future<void> _sync(String model) async {
    setState(() {
      _syncStatus[model] = true;
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
    setState(() {
      _syncStatus[model] = false;
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
            ElevatedButton.icon(
              onPressed: _syncAll,
              icon: const Icon(Icons.sync, color: Colors.white),
              label: Text(
                'Sync All',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.indigo.shade600,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: [
                  _buildSyncItem('Clients', 'clients', Icons.people_outline),
                  _buildSyncItem('Measurements', 'measurements', Icons.square_foot_outlined),
                  _buildSyncItem('Orders', 'orders', Icons.shopping_cart_outlined),
                  _buildSyncItem('Invoices', 'invoices', Icons.receipt_long_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSyncItem(String title, String model, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Icon(icon, color: Colors.indigo.shade600),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: _syncStatus[model]!
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade600),
                ),
              )
            : IconButton(
                icon: Icon(Icons.sync, color: Colors.grey.shade600),
                onPressed: () => _sync(model),
              ),
      ),
    );
  }
}
