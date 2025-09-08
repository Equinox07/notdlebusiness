import 'package:flutter/cupertino.dart';
import 'package:notdle/db/database_helper.dart';

class DashBoardProvider with ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  int _orderCount = 0;
  int _customerCount = 0;

  int get orderCount => _orderCount;
  int get customerCount => _customerCount;


  Future<void> fetchCounts() async {
    _orderCount = await _dbHelper.getActiveOrderCount();
    _customerCount = await _dbHelper.getCustomerCount();
    notifyListeners();
  }
}