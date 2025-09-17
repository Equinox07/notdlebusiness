import 'package:flutter/material.dart';
import 'package:notdle/models/dao/customer_dao.dart';
import 'package:notdle/models/dao/order_dao.dart';
import '../models/customer.dart';

class CustomerProvider extends ChangeNotifier {
  final CustomerDao customerDao;
  final OrderDao orderDao;

  CustomerProvider({required this.customerDao, required this.orderDao });

  List<Customer> _customers = [];
  List<Customer> get customers => _customers;

  Customer? _customer;
  Customer? get customer => _customer;

  Future<void> fetchCustomers() async {
    _customers = await customerDao.getAllCustomers();
    notifyListeners();
  }

  Future<void> addCustomer(Customer customer) async {
    await customerDao.insertCustomer(customer);
    await fetchCustomers(); // refresh
  }

  Future<void> updateCustomer(Customer customer) async {
    await customerDao.updateCustomer(customer);
    await fetchCustomers();
  }

  Future<Customer?> getCustomerById(String customerId) async {
    return await customerDao.getCustomerById(customerId);
  }

  Future<void> deleteCustomer(Customer customer) async {
    await customerDao.deleteCustomer(customer);
    await fetchCustomers();
  }

  Future<int> getOrderCountForCustomer(String customerId) async {
    final count = await orderDao.countCustomerOrder(customerId);
    return count ?? 0;
  }

  Future<Customer> addNewCustomer(Customer customer) async {
    // final savedCustomer = await repository.insertCustomer(customer);
    final savedCustomer = await customerDao.insertCustomer(customer);
    customer = (await customerDao.getCustomerById(savedCustomer as String))!;
    _customers.add(customer);
    notifyListeners();
    return customer;
  }

}
