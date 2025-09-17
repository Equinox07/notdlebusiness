import 'package:notdle/models/order.dart';

import '../dao/order_dao.dart';
import '../dao/customer_dao.dart';

class DashboardRepository {
  final OrderDao orderDao;
  final CustomerDao customerDao;

  DashboardRepository({
    required this.orderDao,
    required this.customerDao,
  });

  Future<int> getActiveOrderCount() {
    return orderDao.getActiveOrderCount();
  }

  Future<int> getCustomerCount() {
    return customerDao.getCustomerCount();
  }

  Future<Order?> getSoonestDueOrder() {
    return orderDao.getSoonestDueOrder();
  }

  /// Returns a map of day abbreviations to order counts for last 7 days
  Future<List<WeeklyOrderStats>> getWeeklyOrderStats() async {
    final rawList = await orderDao.getWeeklyOrderCounts();

    // Map rawList to WeeklyOrderStats
    return rawList.map((row) {
      return WeeklyOrderStats(
        row['day'] as String? ?? '',
        (row['count'] as int?) ?? 0,
      );
    }).toList();
  }

  List<WeeklyOrderStats> fillMissingDays(List<WeeklyOrderStats> rawData) {
    final days = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    final Map<String, int> map = { for (var d in days) d: 0 };

    for (var stat in rawData) {
      map[stat.day] = stat.orderCount;
    }

    return days.map((d) => WeeklyOrderStats(d, map[d]!)).toList();
  }

// Future<void> fetchCounts() async {
  //   _orderCount = await dashboardRepository.getActiveOrderCount();
  //   _customerCount = await dashboardRepository.getCustomerCount();
  //   _soonestDueOrder = await dashboardRepository.getSoonestDueOrder();
  //   notifyListeners();
  // }
}

class WeeklyOrderStats {
  final String day;
  final int orderCount;

  WeeklyOrderStats(this.day, this.orderCount);
}

