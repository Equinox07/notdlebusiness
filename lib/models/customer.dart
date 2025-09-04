class Customer {
  final int? id; // 🔹 Auto-generated
  final String name;
  final String phone;
  final String? email;
  final int orders;
  final DateTime lastVisit;
  final String gender;
  final String? address;
  String? imagePath;
  final DateTime createdDate;

  Customer({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.orders = 0,
    DateTime? lastVisit,
    required this.gender,
    this.address,
    this.imagePath,
    DateTime? createdDate,
  })  : lastVisit = lastVisit ?? DateTime.now(),
        createdDate = createdDate ?? DateTime.now();

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String,
      email: map['email'] as String?,
      orders: map['orders'] as int? ?? 0,
      lastVisit: map['lastVisit'] != null
          ? DateTime.parse(map['lastVisit'])
          : DateTime.now(),
      gender: map['gender'] as String,
      address: map['address'] as String?,
      imagePath: map['imagePath'] as String?,
      createdDate: map['createdDate'] != null
          ? DateTime.parse(map['createdDate'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'phone': phone,
      'email': email,
      'orders': orders,
      'lastVisit': lastVisit.toIso8601String(),
      'gender': gender,
      'address': address,
      'imagePath': imagePath,
      'createdDate': createdDate.toIso8601String(),
    };
    if (id != null) map['id'] = id;
    return map;
  }
}

// class Customer {
//   final String id;
//   final String name;
//   final String phone;
//   final String email;
//   final int orders;
//   final DateTime lastVisit;
//   final String gender;
//   final String address;
//   late final String? imagePath;
//   final DateTime createdDate; // 🔹 New

//   Customer({
//     required this.id,
//     required this.name,
//     required this.phone,
//     required this.email,
//     required this.orders,
//     required this.lastVisit,
//     required this.gender,
//     required this.address,
//     this.imagePath,
//     required this.createdDate,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'phone': phone,
//       'email': email,
//       'orders': orders,
//       'lastVisit': lastVisit.toIso8601String(),
//       'gender': gender,
//       'address': address,
//       'imagePath': imagePath,
//       'createdDate': createdDate.toIso8601String(), // 🔹 Save
//     };
//   }

//   factory Customer.fromMap(Map<String, dynamic> map) {
//     return Customer(
//       id: map['id'],
//       name: map['name'],
//       phone: map['phone'],
//       email: map['email'],
//       orders: map['orders'] ?? 0,
//       lastVisit: DateTime.parse(map['lastVisit']),
//       gender: map['gender'] ?? '',
//       address: map['address'] ?? '',
//       imagePath: map['imagePath'],
//       createdDate: DateTime.parse(map['createdDate']), // 🔹 Load
//     );
//   }
// }
