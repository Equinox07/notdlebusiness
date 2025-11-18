import 'package:flutter/cupertino.dart';
import 'package:notdle/models/dao/customer_dao.dart';
import 'package:notdle/models/dao/order_dao.dart';
import 'package:notdle/models/order.dart';

class DashBoardProvider with ChangeNotifier {
  // final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final OrderDao orderDao;
  final CustomerDao customerDao;

  DashBoardProvider({required this.orderDao, required this.customerDao});



  int _orderCount = 0;
  int _customerCount = 0;
  Order? _soonestDueOrder;


  int get orderCount => _orderCount;
  int get customerCount => _customerCount;
  Order? get soonestDueOrder => _soonestDueOrder;


  Future<void> fetchCounts() async {
    _orderCount = (await orderDao.getActiveOrderCount())!;
    _customerCount = (await customerDao.getCustomerCount())!;
    _soonestDueOrder = await orderDao.getSoonestDueOrder();
    notifyListeners();
  }
}