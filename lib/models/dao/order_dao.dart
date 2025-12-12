import 'package:floor/floor.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/models/order.dart';
import 'package:notdle/models/order_item.dart'; // Import OrderItem

@dao
abstract class OrderDao {
  // Order methods
  @Query('SELECT * FROM orders ORDER BY dueDate ASC')
  Future<List<Order>> getAllOrders();

  @Query('SELECT * FROM orders WHERE id = :id')
  Future<Order?> getOrderById(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertOrder(Order order);

  @update
  Future<void> updateOrder(Order order);

  @delete
  Future<void> deleteOrder(Order order);

  @Query('SELECT COUNT(*) FROM orders WHERE customerId = :customerId')
  Future<int?> countCustomerOrder(String customerId);

  @Query(
    'SELECT * FROM orders WHERE customerId = :customerId ORDER BY dueDate ASC',
  )
  Future<List<Order>> getAllCustomerOrders(String customerId);

  @Query('SELECT COUNT(*) FROM orders WHERE status != "Completed"')
  Future<int?> getActiveOrderCount();

  @Query('SELECT * FROM orders ORDER BY dueDate ASC LIMIT 1')
  Future<Order?> getSoonestDueOrder();

  // OrderItem methods
  @Insert(onConflict: OnConflictStrategy.replace)
  Future<void> insertOrderItem(OrderItem orderItem);

  @update
  Future<void> updateOrderItem(OrderItem orderItem);

  @Query('SELECT * FROM order_items WHERE orderId = :orderId')
  Future<List<OrderItem>> getOrderItems(String orderId);

  @Query('DELETE FROM order_items WHERE orderId = :orderId')
  Future<void> deleteOrderItems(String orderId);

  // Customer and Invoice related queries (already existing)
  @Query('SELECT * FROM customers WHERE id = :customerId')
  Future<Customer?> getCustomer(String customerId);

  @Query('SELECT * FROM invoices WHERE orderId = :orderId LIMIT 1')
  Future<Invoice?> getInvoiceByOrderId(String orderId);

  @Query('SELECT * FROM invoices WHERE orderId = :orderId')
  Future<List<Invoice>?> getInvoicesByOrderId(String orderId);

  @Query('SELECT * FROM invoices WHERE customerId = :customerId')
  Future<Invoice?> getInvoiceByCustomerId(String customerId);
}
