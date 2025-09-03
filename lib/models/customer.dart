class Customer {
  final String id;
  final String name;
  final String phone;
  final String email;
  final int orders;
  final DateTime lastVisit;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.orders,
    required this.lastVisit,
  });
}
