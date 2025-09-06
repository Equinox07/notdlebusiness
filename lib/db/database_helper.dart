import 'package:notdle/models/invoice.dart';
import 'package:notdle/models/order.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/customer.dart';
import '../models/measurement.dart';

class DatabaseHelper {
  static const _dbName = "tailor_app.db";
  static const _dbVersion = 2;

  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        email TEXT,
        lastVisit TEXT,
        gender TEXT,
        address TEXT,
        imagePath TEXT,
        imageUrl TEXT,
        createdDate TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE measurements(
       id INTEGER PRIMARY KEY AUTOINCREMENT,
      customerId TEXT NOT NULL,
      measurementValues TEXT,
      createdDate TEXT NOT NULL,
      FOREIGN KEY(customerId) REFERENCES customers(id) ON DELETE CASCADE
      )
    ''');

    // Create Orders table
    await db.execute('''
             CREATE TABLE orders(
               id TEXT PRIMARY KEY,
               title TEXT,
               customerId TEXT,
               status TEXT,
               paymentStatus TEXT,
               paymentAmount REAL,
               dueDate TEXT,
               notes TEXT,
               invoiceId TEXT,
               FOREIGN KEY (customerId) REFERENCES customers(id)
             )
           ''');

    // Create Invoices table
    await db.execute('''
             CREATE TABLE invoices(
               id TEXT PRIMARY KEY,
               title TEXT,
               customerId TEXT,
               status TEXT,
               totalAmount REAL,
               date TEXT,
               orderId TEXT,
               FOREIGN KEY (customerId) REFERENCES customers(id),
               FOREIGN KEY (orderId) REFERENCES orders(id)
             )
           ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Example migration
      await db.execute("ALTER TABLE customers ADD COLUMN createdDate TEXT");
      await db.execute("ALTER TABLE measurements ADD COLUMN createdDate TEXT");
    }
  }

  // -------------------- CUSTOMER OPERATIONS --------------------

  Future<Customer> insertCustomer(Customer customer) async {
    final db = await instance.database;

    // Insert and get the generated id
    final id = await db.insert(
      "customers",
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Return a new Customer with id assigned
    return Customer(
      id: id,
      name: customer.name,
      gender: customer.gender,
      phone: customer.phone,
      email: customer.email,
      address: customer.address,
      imagePath: customer.imagePath,
      lastVisit: customer.lastVisit,
      createdDate: customer.createdDate,
    );
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await instance.database;
    return await db.update(
      "customers",
      customer.toMap(),
      where: "id = ?",
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await instance.database;
    return await db.delete("customers", where: "id = ?", whereArgs: [id]);
  }

  Future<List<Customer>> fetchCustomers() async {
    final db = await instance.database;
    final result = await db.query("customers", orderBy: "createdDate DESC");
    return result.map((map) => Customer.fromMap(map)).toList();
  }

  Future<Customer?> fetchCustomerById(int id) async {
    final db = await instance.database;
    final result = await db.query(
      "customers",
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    if (result.isNotEmpty) return Customer.fromMap(result.first);
    return null;
  }

  // lib/helpers/database_helper.dart

  // ... (other code)

  Future<List<Order>> getCustomerOrders(int customerId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'orders',
      where: 'customerId = ?',
      whereArgs: [customerId],
    );

    return List.generate(maps.length, (i) {
      return Order.fromMap(maps[i]);
    });
  }

  // -------------------- MEASUREMENT OPERATIONS --------------------
  // ------------------ Measurements CRUD ------------------

  Future<Measurement> insertMeasurement(Measurement measurement) async {
    final db = await instance.database;
    final id = await db.insert(
      'measurements',
      measurement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return Measurement(
      id: id,
      customerId: measurement.customerId,
      measurementValues: measurement.measurementValues,
      createdDate: measurement.createdDate,
    );
  }

  Future<Measurement?> fetchMeasurementById(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'measurements',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Measurement.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Measurement>> fetchMeasurementsByCustomer(
    String customerId,
  ) async {
    final db = await instance.database;
    final maps = await db.query(
      'measurements',
      where: 'customerId = ?',
      whereArgs: [customerId],
    );
    return maps.map((map) => Measurement.fromMap(map)).toList();
  }

  Future<int> updateMeasurement(Measurement measurement) async {
    final db = await instance.database;
    if (measurement.id == null) throw Exception("Measurement ID is null!");
    return await db.update(
      'measurements',
      measurement.toMap(),
      where: 'id = ?',
      whereArgs: [measurement.id],
    );
  }

  Future<int> deleteMeasurement(int id) async {
    final db = await instance.database;
    return await db.delete('measurements', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MeasurementWithCustomer>> fetchMeasurementsWithCustomer() async {
    final db = await database;
    final measurementMaps = await db.query('measurements');

    List<MeasurementWithCustomer> list = [];

    for (var m in measurementMaps) {
      final customerId = m['customerId'];
      final customerMap =
          (await db.query(
            'customers',
            where: 'id = ?',
            whereArgs: [customerId],
          )).first;
      final customer = Customer.fromMap(customerMap);

      final measurement = Measurement.fromMap(m);
      list.add(
        MeasurementWithCustomer(measurement: measurement, customer: customer),
      );
    }

    return list;
  }

  Future<List<Measurement>> fetchAllMeasurementsWithCustomer() async {
    final db = await database;
    final measurementMaps = await db.query('measurements');

    List<Measurement> list = [];

    for (var m in measurementMaps) {
      final measurement = Measurement.fromMap(m);

      // fetch linked customer
      final customerMap =
          (await db.query(
            'customers',
            where: 'id = ?',
            whereArgs: [measurement.customerId],
          )).first;
      final customer = Customer.fromMap(customerMap);

      measurement.linkCustomer(customer);
      list.add(measurement);
    }

    return list;
  }

  // --- Order Operations ---
  Future<void> insertOrder(Order order) async {
    final db = await database;
    await db.insert(
      'orders',
      order.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Order>> getOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('orders');
    return List.generate(maps.length, (i) => Order.fromMap(maps[i]));
  }

  // --- Invoice Operations ---
  Future<void> insertInvoice(Invoice invoice) async {
    final db = await database;
    await db.insert(
      'invoices',
      invoice.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Invoice>> getInvoices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('invoices');
    return List.generate(maps.length, (i) => Invoice.fromMap(maps[i]));
  }

  // New method to get a single order with its customer
  Future<Map<String, dynamic>?> getOrderWithDetails(String orderId) async {
    final db = await database;

    final List<Map<String, dynamic>> orders = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [orderId],
    );

    if (orders.isNotEmpty) {
      final orderMap = orders.first;
      final customerMap = await db.query(
        'customers',
        where: 'id = ?',
        whereArgs: [orderMap['customerId']],
      );
      final invoiceMap = await db.query(
        'invoices',
        where: 'orderId = ?',
        whereArgs: [orderId],
      );

      final customer =
          customerMap.isNotEmpty ? Customer.fromMap(customerMap.first) : null;
      final invoice =
          invoiceMap.isNotEmpty ? Invoice.fromMap(invoiceMap.first) : null;

      return {
        'order': Order.fromMap(orderMap),
        'customer': customer,
        'invoice': invoice,
      };
    }
    return null;
  }

  // Method to fetch the count of all orders for this customer from the database.
  Future<int> getCustomerOrderCount(int id) async {
    final dbHelper = DatabaseHelper.instance;
    final Database db = await dbHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM orders WHERE customerId = ?', [
        id,
      ]),
    );
    return count ?? 0;
  }
}

class MeasurementWithCustomer {
  final Measurement measurement;
  final Customer customer;

  MeasurementWithCustomer({required this.measurement, required this.customer});
}
