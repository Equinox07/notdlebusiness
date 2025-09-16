import 'package:flutter/cupertino.dart';
import 'package:notdle/db/database_helper.dart';
import 'package:notdle/models/order.dart';

class DashBoardProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  int _orderCount = 0;
  int _customerCount = 0;
  Order? _soonestDueOrder;

  int get orderCount => _orderCount;
  int get customerCount => _customerCount;
  Order? get soonestDueOrder => _soonestDueOrder;


  Future<void> fetchCounts() async {
    _orderCount = await _dbHelper.getActiveOrderCount();
    _customerCount = await _dbHelper.getCustomerCount();
    _soonestDueOrder = await _dbHelper.getSoonestDueOrder();
    notifyListeners();
  }
}