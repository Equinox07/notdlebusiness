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
        name TEXT NOT NULL,
        phone TEXT,
        email TEXT,
        orders INTEGER DEFAULT 0,
        lastVisit TEXT,
        gender TEXT,
        address TEXT,
        imagePath TEXT,
        createdDate TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE measurements(
        customerId INTEGER,
        measurementData TEXT,
        createdDate TEXT,
        FOREIGN KEY(customerId) REFERENCES customers(id) ON DELETE CASCADE
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
      orders: customer.orders,
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

  // -------------------- MEASUREMENT OPERATIONS --------------------

  Future<int> insertMeasurement(Measurement measurement) async {
    final db = await instance.database;
    return await db.insert(
      "measurements",
      measurement.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateMeasurement(Measurement measurement) async {
    final db = await instance.database;
    return await db.update(
      "measurements",
      measurement.toMap(),
      where: "customerId = ?",
      whereArgs: [measurement.customerId],
    );
  }

  Future<int> deleteMeasurement(int customerId) async {
    final db = await instance.database;
    return await db.delete(
      "measurements",
      where: "customerId = ?",
      whereArgs: [customerId],
    );
  }

  Future<Measurement?> fetchMeasurementByCustomerId(int customerId) async {
    final db = await instance.database;
    final result = await db.query(
      "measurements",
      where: "customerId = ?",
      whereArgs: [customerId],
      limit: 1,
    );
    if (result.isNotEmpty) return Measurement.fromMap(result.first);
    return null;
  }
}
