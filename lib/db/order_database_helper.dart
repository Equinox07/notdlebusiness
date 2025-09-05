// // lib/db/order_database_helper.dart

// import 'dart:async';
// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:notdle/models/order.dart';
// import 'package:notdle/models/order_details.dart';
// import 'package:notdle/models/customer.dart';
// import 'package:notdle/models/order_event.dart';

// class OrderDatabaseHelper {
//   static final OrderDatabaseHelper _instance = OrderDatabaseHelper._internal();
//   static Database? _database;

//   factory OrderDatabaseHelper() {
//     return _instance;
//   }

//   OrderDatabaseHelper._internal();

//   Future<Database> get database async {
//     if (_database != null) return _database!;
//     _database = await _initDatabase();
//     return _database!;
//   }

//   Future<Database> _initDatabase() async {
//     final databasePath = await getDatabasesPath();
//     final path = join(databasePath, 'orders.db');

//     return await openDatabase(path, version: 1, onCreate: _onCreate);
//   }

//   Future<void> _onCreate(Database db, int version) async {
//     await db.execute('''
//       CREATE TABLE orders(
//         id TEXT PRIMARY KEY,
//         title TEXT,
//         customerId TEXT,
//         status TEXT
//       )
//     ''');

//     await db.execute('''
//       CREATE TABLE order_details(
//         orderId TEXT PRIMARY KEY,
//         customerPhone TEXT,
//         customerEmail TEXT,
//         paymentStatus TEXT,
//         dueDate TEXT,
//         notes TEXT,
//         FOREIGN KEY (orderId) REFERENCES orders (id)
//       )
//     ''');

//     await db.execute('''
//       CREATE TABLE order_events(
//         id INTEGER PRIMARY KEY AUTOINCREMENT,
//         orderId TEXT,
//         title TEXT,
//         date TEXT,
//         isCurrent INTEGER,
//         FOREIGN KEY (orderId) REFERENCES orders (id)
//       )
//     ''');
//   }

//   // Helper method to insert a new order and its details.
//   Future<void> createOrder(Order order, OrderDetails details) async {
//     final db = await database;
//     await db.transaction((txn) async {
//       await txn.insert(
//         'orders',
//         order.toMap(),
//         conflictAlgorithm: ConflictAlgorithm.replace,
//       );
//       await txn.insert(
//         'order_details',
//         details.toMap(),
//         conflictAlgorithm: ConflictAlgorithm.replace,
//       );
//       for (var event in details.timeline) {
//         await txn.insert('order_events', event.toMapWithOrderId(order.id));
//       }
//     });
//   }

//   // Helper method to update an order's status.
//   Future<int> updateOrderStatus(String orderId, String newStatus) async {
//     final db = await database;
//     return await db.update(
//       'orders',
//       {'status': newStatus},
//       where: 'id = ?',
//       whereArgs: [orderId],
//     );
//   }

//   // Helper method to update an order's payment status.
//   Future<int> updatePaymentStatus(
//     String orderId,
//     String newPaymentStatus,
//   ) async {
//     final db = await database;
//     return await db.update(
//       'order_details',
//       {'paymentStatus': newPaymentStatus},
//       where: 'orderId = ?',
//       whereArgs: [orderId],
//     );
//   }

//   // Helper method to add a new event to the timeline.
//   Future<int> addOrderEvent(String orderId, OrderEvent newEvent) async {
//     final db = await database;
//     return await db.insert('order_events', newEvent.toMapWithOrderId(orderId));
//   }

//   // Helper method to get a single order's full details.
//   Future<OrderDetails?> getOrderDetails(String orderId) async {
//     final db = await database;

//     final List<Map<String, dynamic>> ordersResult = await db.query(
//       'orders',
//       where: 'id = ?',
//       whereArgs: [orderId],
//     );

//     if (ordersResult.isEmpty) {
//       return null;
//     }

//     final order = Order.fromMap(ordersResult.first);

//     final List<Map<String, dynamic>> detailsResult = await db.query(
//       'order_details',
//       where: 'orderId = ?',
//       whereArgs: [orderId],
//     );

//     final List<Map<String, dynamic>> eventsResult = await db.query(
//       'order_events',
//       where: 'orderId = ?',
//       whereArgs: [orderId],
//       orderBy: 'date ASC', // Assuming date is sortable or you have a timestamp.
//     );

//     final detailsMap = detailsResult.first;
//     final timeline = eventsResult.map((e) => OrderEvent.fromMap(e)).toList();

//     return OrderDetails.fromMap(detailsMap, order, timeline);
//   }
// }
