import 'package:floor/floor.dart';
import 'package:notdle/models/customer.dart';

@dao
abstract class CustomerDao {
  @Query('SELECT * FROM customers ORDER BY name ASC')
  Future<List<Customer>> getAllCustomers();

  @Query('SELECT * FROM customers WHERE id = :id')
  Future<Customer?> getCustomerById(String id);

  @Insert(onConflict: OnConflictStrategy.replace)
  Future<int> insertCustomer(Customer customer);

  @update
  Future<void> updateCustomer(Customer customer);

  @delete
  Future<void> deleteCustomer(Customer customer);

  @Query('SELECT COUNT(*) FROM customers')
  Future<int> getCustomerCount();

}
