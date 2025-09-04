import 'package:notdle/models/customer.dart';
import 'package:notdle/models/measurement.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _dbName = "tailor_app.db";
  static const _dbVersion = 2; // bump version when schema changes

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
    // Customers Table
    await db.execute('''
      CREATE TABLE customers(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        gender TEXT,
        phone TEXT,
        email TEXT,
        address TEXT,
        createdDate TEXT
      )
    ''');

    // Measurements Table
    await db.execute('''
      CREATE TABLE measurements(
        customerId INTEGER PRIMARY KEY,
        measurementData TEXT,
        createdDate TEXT,
        FOREIGN KEY(customerId) REFERENCES customers(id) ON DELETE CASCADE
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Example: adding createdDate if upgrading from v1
      await db.execute("ALTER TABLE customers ADD COLUMN createdDate TEXT");
      await db.execute("ALTER TABLE measurements ADD COLUMN createdDate TEXT");
    }
  }

  // ---------------------- CUSTOMER OPERATIONS ----------------------

  Future<int> insertCustomer(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert("customers", row);
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
    if (result.isNotEmpty) {
      return Customer.fromMap(result.first);
    }
    return null;
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await instance.database;
    return await db.update(
      "customers",
      customer.toMap(), // ✅ Convert to Map
      where: "id = ?",
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await instance.database;
    return await db.delete("customers", where: "id = ?", whereArgs: [id]);
  }

  // ---------------------- MEASUREMENT OPERATIONS ----------------------
  // Insert Measurement
  Future<int> insertMeasurement(Measurement measurement) async {
    final db = await instance.database;
    return await db.insert(
      "measurements",
      measurement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Fetch Measurement by customerId
  Future<Measurement?> fetchMeasurementByCustomerId(int customerId) async {
    final db = await instance.database;
    final result = await db.query(
      "measurements",
      where: "customerId = ?",
      whereArgs: [customerId],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return Measurement.fromMap(result.first);
    }
    return null;
  }

  // Update Measurement
  Future<int> updateMeasurement(Measurement measurement) async {
    final db = await instance.database;
    return await db.update(
      "measurements",
      measurement.toMap(),
      where: "customerId = ?",
      whereArgs: [measurement.customerId],
    );
  }

  // Delete Measurement
  Future<int> deleteMeasurement(int customerId) async {
    final db = await instance.database;
    return await db.delete(
      "measurements",
      where: "customerId = ?",
      whereArgs: [customerId],
    );
  }
}
