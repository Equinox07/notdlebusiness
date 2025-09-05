// lib/models/order_event.dart

class OrderEvent {
  final String title;
  final String date;
  final bool isCurrent;

  OrderEvent({required this.title, required this.date, this.isCurrent = false});

  Map<String, dynamic> toMapWithOrderId(String orderId) {
    return {
      'orderId': orderId,
      'title': title,
      'date': date,
      'isCurrent': isCurrent ? 1 : 0,
    };
  }

  static OrderEvent fromMap(Map<String, dynamic> map) {
    return OrderEvent(
      title: map['title'],
      date: map['date'],
      isCurrent: map['isCurrent'] == 1,
    );
  }
}
