
import 'package:notdle/models/dao/order_dao.dart';
import 'package:notdle/models/order.dart';

class OrderRepository {
  final OrderDao orderDao;

  OrderRepository({required this.orderDao});

  Future<List<Order>> getOrdersByCustomerId(String customerId) {
    return orderDao.getAllCustomerOrders(customerId);
  }

  Future<int?> countOrdersByCustomer(String customerId) {
    return orderDao.countCustomerOrder(customerId);
  }

  Future<void> insertOrder(Order order) {
    return orderDao.insertOrder(order);
  }

  Future<void> deleteOrder(Order order) {
    return orderDao.deleteOrder(order);
  }

  Future<void> updateOrder(Order order) {
    return orderDao.updateOrder(order);
  }

// Add other domain/business logic methods as needed
}
