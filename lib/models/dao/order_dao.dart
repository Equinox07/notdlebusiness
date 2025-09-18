
import 'package:floor/floor.dart';
import 'package:notdle/models/company.dart';
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/invoice.dart';
import 'package:notdle/models/order.dart';

@dao
abstract class OrderDao{

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

  @Query('SELECT * FROM orders WHERE customerId = :customerId ORDER BY dueDate ASC')
  Future<List<Order>> getAllCustomerOrders(String customerId);

  @Query('SELECT COUNT(*) FROM orders WHERE status != "Completed"')
  Future<int> getActiveOrderCount();

  @Query('SELECT * FROM orders ORDER BY dueDate ASC LIMIT 1')
  Future<Order?> getSoonestDueOrder();

  @Query('''
  SELECT 
    strftime('%w', createdDate) AS dayIndex,
    CASE strftime('%w', createdDate)
      WHEN '0' THEN 'Sun'
      WHEN '1' THEN 'Mon'
      WHEN '2' THEN 'Tue'
      WHEN '3' THEN 'Wed'
      WHEN '4' THEN 'Thu'
      WHEN '5' THEN 'Fri'
      WHEN '6' THEN 'Sat'
    END AS day,
    COUNT(*) AS count
  FROM orders
  WHERE DATE(createdDate) >= DATE('now', '-6 days')
  GROUP BY dayIndex
  ORDER BY dayIndex;
''')
  Future<List<Map<String, Object?>>> getWeeklyOrderCounts();


  @Query('SELECT * FROM customers WHERE id = :customerId')
  Future<Customer?> getCustomer(String customerId);

  @Query('SELECT * FROM invoices WHERE orderId = :orderId LIMIT 1')
  Future<Invoice?> getInvoiceByOrderId(String orderId);

  @Query('SELECT * FROM invoices WHERE orderId = :orderId')
  Future<List<Invoice>?> getInvoicesByOrderId(String orderId);

  @Query('SELECT * FROM invoices WHERE customerId = :customerId')
  Future<Invoice?> getInvoiceByCustomerId(String customerId);

}