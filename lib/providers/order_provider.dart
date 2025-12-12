import 'package:flutter/material.dart';
import 'package:notdle/models/dao/order_dao.dart';
import 'package:notdle/models/order_with_details.dart';
import 'package:notdle/utils/helpers.dart';
import '../models/order.dart';

class OrderProvider extends ChangeNotifier {
  final OrderDao orderDao;

  OrderProvider({required this.orderDao});

  List<Order> _orders = [];
  List<Order> get orders => _orders;

  List<Order> _customerOrders = [];
  List<Order> get customerOrders => _customerOrders;

  Order? _order;
  Order? get order => _order;

  Future<void> fetchOrders() async {
    _orders = await orderDao.getAllOrders();
    notifyListeners();
  }

  Future<Order?> getOrderById(String orderId) async {
    return await orderDao.getOrderById(orderId);
  }

  Future<void> addOrder(Order order) async {
    final newOrder = order.copyWith(orderNumber: generateOrderNumber());
    await orderDao.insertOrder(newOrder);
    await fetchOrders();
  }

  Future<void> updateOrder(Order order) async {
    await orderDao.updateOrder(order);
    await fetchOrders();
  }

  Future<void> deleteOrder(Order order) async {
    await orderDao.deleteOrder(order);
    await fetchOrders();
  }

  /// Fetches an order and its associated details like customer and invoice.
  ///
  /// The invoice is considered optional. If an order and customer are found,
  /// this method will succeed even if no invoice exists yet.
  Future<OrderWithDetails?> getOrderWithDetails(String orderId) async {
    debugPrint("PROVIDER: Fetching details for order ID: $orderId");

    // 1. Fetch the core Order object.
    final order = await orderDao.getOrderById(orderId);
    if (order == null) {
      debugPrint("PROVIDER: ❌ Order not found for ID: $orderId. Aborting.");
      return null;
    }
    debugPrint("PROVIDER: ✅ Order found: ${order.id}");

    // 2. Fetch the associated Customer. This is required.
    debugPrint("PROVIDER: 🔍 Looking up customer with ID: ${order.customerId}");
    final customer = await orderDao.getCustomer(order.customerId);
    if (customer == null) {
      debugPrint("PROVIDER: ❌ Customer not found for ID: ${order.customerId}. Aborting.");
      return null;
    }
    debugPrint("PROVIDER: ✅ Customer found: ${customer.name}");

    // 3. Fetch the associated Invoice. This is OPTIONAL.
    // It's better to fetch by orderId to avoid ambiguity.
    // Please ensure you have a `getInvoiceByOrderId` method in your OrderDao.
    debugPrint("PROVIDER: 🔍 Looking up invoice for order ID: ${order.id}");
    final invoice = await orderDao.getInvoiceByOrderId(order.id);
    if (invoice == null) {
      debugPrint("PROVIDER: ℹ️ No invoice found for this order. This is acceptable.");
    } else {
      debugPrint("PROVIDER: ✅ Invoice found: ${invoice.id}");
    }

    // 4. Construct the details object.
    // The invoice can be null, and the UI will handle it correctly.
    return OrderWithDetails(order, customer, invoice);
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchOrdersForCustomer(String customerId) async {
    _isLoading = true;
    notifyListeners();

    _customerOrders = await orderDao.getAllCustomerOrders(customerId);

    _isLoading = false;
    notifyListeners();
  }
}
