import 'package:flutter/material.dart';
import 'package:notdle/models/dao/order_dao.dart';
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
    await orderDao.insertOrder(order);
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
