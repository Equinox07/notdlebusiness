
import 'package:notdle/models/customer.dart';
import 'package:notdle/models/dao/customer_dao.dart';

class CustomerRepository {
  final CustomerDao customerDao;

  CustomerRepository({required this.customerDao});

  Future<List<Customer>> getAllCustomers() {
    return customerDao.getAllCustomers();
  }

  Future<Customer?> getCustomerById(String id) {
    return customerDao.getCustomerById(id);
  }

  Future<void> insertCustomer(Customer customer) {
    return customerDao.insertCustomer(customer);
  }

  Future<void> updateCustomer(Customer customer) {
    return customerDao.updateCustomer(customer);
  }

  Future<void> deleteCustomer(Customer customer) {
    return customerDao.deleteCustomer(customer);
  }
}
