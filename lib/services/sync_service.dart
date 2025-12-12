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
      try {
        // Assuming customer model needs to be converted to ClientDto
        final clientDto = ClientDto(
          name: customer.name,
          email: customer.email!,
          phoneNumber: customer.phone,
          address: customer.address!,
          companyId: _companyId,
        );
        await _apiClient.createClient(_companyId!, clientDto.toJson());
        await customerProvider.customerDao.insertCustomer(customer.copyWith(isSynced: true));
      } catch (e) {
        // Handle error
        print('Failed to sync client: ${customer.id}, error: $e');
      }
    }
  }

  Future<void> syncMeasurements() async {
    final measurementProvider = Provider.of<MeasurementProvider>(_context, listen: false);
    final measurements = await measurementProvider.measurementDao.getAllMeasurements();

    for (final measurement in measurements) {
      try {
        // Assuming measurement model needs to be converted to CreateMeasurementRequestDto
        final measurementDto = CreateMeasurementRequestDto(
          name: measurement.name,
          measurementValues: measurement.measurementValues,
          clientId: measurement.customerId,
        );
        await _apiClient.createMeasurement(measurementDto.toJson());
        await measurementProvider.measurementDao.insertMeasurement(measurement.copyWith(isSynced: true));
      } catch (e) {
        // Handle error
        print('Failed to sync measurement: ${measurement.id}, error: $e');
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
      try {
        // Assuming order model needs to be converted to OrderDto
        final orderDto = OrderDto(
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
            productName: item.productName,
            productDescription: item.productDescription,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            taxRate: item.taxRate,
            amount: item.amount,
          )).toList(),
        );
        await _apiClient.createOrder(_companyId!, orderDto.toJson());
      } catch (e) {
        // Handle error
        print('Failed to sync order: ${order.id}, error: $e');
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
      try {
        // Assuming invoice model needs to be converted to InvoiceDto
        final invoiceDto = InvoiceDto(
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
            description: item.description,
            quantity: item.quantity,
            unitPrice: item.unitPrice,
            taxRate: item.taxRate,
            amount: item.amount,
          )).toList(),
          payments: invoice.payments.map((payment) => PaymentDto(
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
      } catch (e) {
        // Handle error
        print('Failed to sync invoice: ${invoice.id}, error: $e');
      }
    }
  }
}
