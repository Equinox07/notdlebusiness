import 'package:notdle/models/client_model.dart';
import 'package:notdle/models/measurement_model.dart';
import 'package:notdle/models/order_model.dart';
import 'package:notdle/models/invoice_model.dart';
import 'package:notdle/services/api_client.dart';
import 'package:notdle/services/api_service.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/providers/measurement_provider.dart';
import 'package:notdle/providers/order_provider.dart';
import 'package:notdle/providers/invoice_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class SyncService {
  final ApiClient _apiClient;
  final ApiService _apiService;
  final BuildContext _context;
  String? _companyId;

  SyncService(this._context)
      : _apiClient = ApiClient(),
        _apiService = ApiService() {
    _initialize();
  }

  Future<void> _initialize() async {
    final user = await _apiService.getStoredUser();
    _companyId = user?.companyId;
  }

  Future<void> syncAll() async {
    await syncClients();
    await syncMeasurements();
    await syncOrders();
    await syncInvoices();
  }

  Future<void> syncClients() async {
    if (_companyId == null) {
      print('Company ID not found. Cannot sync clients.');
      return;
    }
    final customerProvider = Provider.of<CustomerProvider>(_context, listen: false);
    final customers = await customerProvider.customerDao.getAllCustomers();

    for (final customer in customers) {
      if (!customer.isSynced) { // Only sync unsynced items
        try {
          final clientDto = ClientDto(
            id: customer.id,
            externalId: customer.id,
            name: customer.name,
            email: customer.email!,
            phoneNumber: customer.phone,
            address: customer.address!,
            companyId: _companyId,
          );
          await _apiClient.createClient(_companyId!, clientDto.toJson());
          // Update local record after successful sync
          await customerProvider.customerDao.updateCustomer(
            customer.copyWith(isSynced: true, syncDate: DateTime.now()),
          );
        } catch (e) {
          print('Failed to sync client: ${customer.id}, error: $e');
        }
      }
    }
  }

  Future<void> syncMeasurements() async {
    final measurementProvider = Provider.of<MeasurementProvider>(_context, listen: false);
    final measurements = await measurementProvider.measurementDao.getAllMeasurements();

    for (final measurement in measurements) {
      if (!measurement.isSynced) { // Only sync unsynced items
        try {
          final measurementDto = CreateMeasurementRequestDto(
            externalId: measurement.id.toString(),
            name: measurement.name,
            measurementValues: measurement.measurementValues,
            clientId: measurement.customerId,
          );
          await _apiClient.createMeasurement(measurementDto.toJson());
          // Update local record after successful sync
          await measurementProvider.measurementDao.updateMeasurement(
            measurement.copyWith(isSynced: true, syncDate: DateTime.now()),
          );
        } catch (e) {
          print('Failed to sync measurement: ${measurement.id}, error: $e');
        }
      }
    }
  }

  Future<void> syncOrders() async {
    if (_companyId == null) {
      print('Company ID not found. Cannot sync orders.');
      return;
    }
    final orderProvider = Provider.of<OrderProvider>(_context, listen: false);
    final orders = await orderProvider.orderDao.getAllOrders();

    for (final order in orders) {
      if (!order.isSynced) { // Only sync unsynced items
        try {
          final orderDto = OrderDto(
            externalId: order.id,
            orderNumber: order.orderNumber!,
            orderDate:  DateTime.parse(order.createdDate),
            expectedDeliveryDate: order.expectedDeliveryDate!,
            notes: order.notes,
            status: order.status,
            subtotal: order.subtotal!,
            tax: order.tax!,
            total: order.total!,
            companyId: _companyId!,
            clientId: order.customerId,
            items: order.items.map((item) => OrderItemDto(
              externalId: item.id,
              productName: item.productName,
              productDescription: item.productDescription,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              taxRate: item.taxRate,
              amount: item.amount,
            )).toList(),
          );
          await _apiClient.createOrder(_companyId!, orderDto.toJson());
          // Update local record after successful sync
          await orderProvider.orderDao.updateOrder(
            order.copyWith(isSynced: true, syncDate: DateTime.now()),
          );
          // Update order items
          for (final item in order.items) {
            await orderProvider.orderDao.updateOrderItem(
              item.copyWith(isSynced: true, syncDate: DateTime.now()),
            );
          }
        } catch (e) {
          print('Failed to sync order: ${order.id}, error: $e');
        }
      }
    }
  }

  Future<void> syncInvoices() async {
    if (_companyId == null) {
      print('Company ID not found. Cannot sync invoices.');
      return;
    }
    final invoiceProvider = Provider.of<InvoiceProvider>(_context, listen: false);
    final invoices = await invoiceProvider.invoiceDao.getAllInvoices();

    for (final invoice in invoices) {
      if (!invoice.isSynced) { // Only sync unsynced items
        try {
          final invoiceDto = InvoiceDto(
            externalId: invoice.id,
            invoiceNumber: invoice.invoiceNumber!,
            issueDate: invoice.issueDate!,
            dueDate: invoice.dueDate!,
            notes: invoice.notes!,
            terms: invoice.terms!,
            subtotal: invoice.subtotal!,
            tax: invoice.tax!,
            total: invoice.total!,
            status: invoice.status,
            projectId: invoice.projectId!,
            items: invoice.items.map((item) => InvoiceItemDto(
              externalId: item.id,
              description: item.description,
              quantity: item.quantity,
              unitPrice: item.unitPrice,
              taxRate: item.taxRate,
              amount: item.amount,
            )).toList(),
            payments: invoice.payments.map((payment) => PaymentDto(
              externalId: payment.id,
              amount: payment.amount,
              paymentDate: payment.paymentDate,
              referenceNumber: payment.referenceNumber,
              notes: payment.notes,
              status: payment.status,
              invoiceId: payment.invoiceId,
              companyId: _companyId!,
            )).toList(),
          );
          await _apiClient.createInvoice(_companyId!, invoiceDto.toJson());
          // Update local record after successful sync
          await invoiceProvider.invoiceDao.updateInvoice(
            invoice.copyWith(isSynced: true, syncDate: DateTime.now()),
          );
          // Update invoice items
          for (final item in invoice.items) {
            await invoiceProvider.invoiceDao.updateInvoiceItem(
              item.copyWith(isSynced: true, syncDate: DateTime.now()),
            );
          }
          // Update payments
          for (final payment in invoice.payments) {
            await invoiceProvider.invoiceDao.updatePayment(
              payment.copyWith(isSynced: true, syncDate: DateTime.now()),
            );
          }
        } catch (e) {
          print('Failed to sync invoice: ${invoice.id}, error: $e');
        }
      }
    }
  }
}
