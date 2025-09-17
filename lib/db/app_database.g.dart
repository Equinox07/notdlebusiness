// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

abstract class $AppDatabaseBuilderContract {
  /// Adds migrations to the builder.
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations);

  /// Adds a database [Callback] to the builder.
  $AppDatabaseBuilderContract addCallback(Callback callback);

  /// Creates the database and initializes it.
  Future<AppDatabase> build();
}

// ignore: avoid_classes_with_only_static_members
class $FloorAppDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract databaseBuilder(String name) =>
      _$AppDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static $AppDatabaseBuilderContract inMemoryDatabaseBuilder() =>
      _$AppDatabaseBuilder(null);
}

class _$AppDatabaseBuilder implements $AppDatabaseBuilderContract {
  _$AppDatabaseBuilder(this.name);

  final String? name;

  final List<Migration> _migrations = [];

  Callback? _callback;

  @override
  $AppDatabaseBuilderContract addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  @override
  $AppDatabaseBuilderContract addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  @override
  Future<AppDatabase> build() async {
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name!)
        : ':memory:';
    final database = _$AppDatabase();
    database.database = await database.open(
      path,
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$AppDatabase extends AppDatabase {
  _$AppDatabase([StreamController<String>? listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  CompanyDao? _companyDaoInstance;

  CustomerDao? _customerDaoInstance;

  OrderDao? _orderDaoInstance;

  MeasurementDao? _measurementDaoInstance;

  InvoiceDao? _invoiceDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
        await callback?.onConfigure?.call(database);
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `Company` (`id` TEXT NOT NULL, `fullName` TEXT NOT NULL, `email` TEXT NOT NULL, `mobile` TEXT NOT NULL, `businessName` TEXT NOT NULL, `yearsOfExperience` INTEGER NOT NULL, `registrationNumber` TEXT NOT NULL, `address` TEXT NOT NULL, `countryCode` TEXT NOT NULL, `imagePath` TEXT, `imageUrl` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `customers` (`id` TEXT, `name` TEXT NOT NULL, `phone` TEXT NOT NULL, `email` TEXT, `lastVisit` INTEGER NOT NULL, `gender` TEXT NOT NULL, `address` TEXT, `imagePath` TEXT, `imageUrl` TEXT, `createdDate` INTEGER NOT NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `orders` (`id` TEXT NOT NULL, `title` TEXT NOT NULL, `customerId` TEXT NOT NULL, `status` TEXT NOT NULL, `paymentStatus` TEXT NOT NULL, `paymentAmount` REAL, `dueDate` TEXT, `notes` TEXT, `createdDate` TEXT NOT NULL, FOREIGN KEY (`customerId`) REFERENCES `customers` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `measurements` (`id` INTEGER PRIMARY KEY AUTOINCREMENT, `customerId` TEXT NOT NULL, `measurementValues` TEXT NOT NULL, `createdDate` INTEGER NOT NULL, `updatedDate` INTEGER, FOREIGN KEY (`customerId`) REFERENCES `customers` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `invoices` (`id` TEXT NOT NULL, `title` TEXT NOT NULL, `customerId` TEXT NOT NULL, `status` TEXT NOT NULL, `totalAmount` REAL NOT NULL, `date` INTEGER NOT NULL, `orderId` TEXT NOT NULL, `createdDate` TEXT, `updatedDate` TEXT, FOREIGN KEY (`customerId`) REFERENCES `customers` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, FOREIGN KEY (`orderId`) REFERENCES `orders` (`id`) ON UPDATE NO ACTION ON DELETE SET NULL, PRIMARY KEY (`id`))');

        await callback?.onCreate?.call(database, version);
      },
    );
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
  }

  @override
  CompanyDao get companyDao {
    return _companyDaoInstance ??= _$CompanyDao(database, changeListener);
  }

  @override
  CustomerDao get customerDao {
    return _customerDaoInstance ??= _$CustomerDao(database, changeListener);
  }

  @override
  OrderDao get orderDao {
    return _orderDaoInstance ??= _$OrderDao(database, changeListener);
  }

  @override
  MeasurementDao get measurementDao {
    return _measurementDaoInstance ??=
        _$MeasurementDao(database, changeListener);
  }

  @override
  InvoiceDao get invoiceDao {
    return _invoiceDaoInstance ??= _$InvoiceDao(database, changeListener);
  }
}

class _$CompanyDao extends CompanyDao {
  _$CompanyDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _companyInsertionAdapter = InsertionAdapter(
            database,
            'Company',
            (Company item) => <String, Object?>{
                  'id': item.id,
                  'fullName': item.fullName,
                  'email': item.email,
                  'mobile': item.mobile,
                  'businessName': item.businessName,
                  'yearsOfExperience': item.yearsOfExperience,
                  'registrationNumber': item.registrationNumber,
                  'address': item.address,
                  'countryCode': item.countryCode,
                  'imagePath': item.imagePath,
                  'imageUrl': item.imageUrl
                }),
        _companyUpdateAdapter = UpdateAdapter(
            database,
            'Company',
            ['id'],
            (Company item) => <String, Object?>{
                  'id': item.id,
                  'fullName': item.fullName,
                  'email': item.email,
                  'mobile': item.mobile,
                  'businessName': item.businessName,
                  'yearsOfExperience': item.yearsOfExperience,
                  'registrationNumber': item.registrationNumber,
                  'address': item.address,
                  'countryCode': item.countryCode,
                  'imagePath': item.imagePath,
                  'imageUrl': item.imageUrl
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Company> _companyInsertionAdapter;

  final UpdateAdapter<Company> _companyUpdateAdapter;

  @override
  Future<Company?> getCompany() async {
    return _queryAdapter.query('SELECT * FROM companies LIMIT 1',
        mapper: (Map<String, Object?> row) => Company(
            id: row['id'] as String?,
            fullName: row['fullName'] as String,
            email: row['email'] as String,
            mobile: row['mobile'] as String,
            businessName: row['businessName'] as String,
            yearsOfExperience: row['yearsOfExperience'] as int,
            registrationNumber: row['registrationNumber'] as String,
            address: row['address'] as String,
            countryCode: row['countryCode'] as String,
            imagePath: row['imagePath'] as String?,
            imageUrl: row['imageUrl'] as String?));
  }

  @override
  Future<List<Company>> findAllCompanies() async {
    return _queryAdapter.queryList('SELECT * FROM Company',
        mapper: (Map<String, Object?> row) => Company(
            id: row['id'] as String?,
            fullName: row['fullName'] as String,
            email: row['email'] as String,
            mobile: row['mobile'] as String,
            businessName: row['businessName'] as String,
            yearsOfExperience: row['yearsOfExperience'] as int,
            registrationNumber: row['registrationNumber'] as String,
            address: row['address'] as String,
            countryCode: row['countryCode'] as String,
            imagePath: row['imagePath'] as String?,
            imageUrl: row['imageUrl'] as String?));
  }

  @override
  Future<Company?> findCompanyById(String id) async {
    return _queryAdapter.query('SELECT * FROM Company WHERE id=?1',
        mapper: (Map<String, Object?> row) => Company(
            id: row['id'] as String?,
            fullName: row['fullName'] as String,
            email: row['email'] as String,
            mobile: row['mobile'] as String,
            businessName: row['businessName'] as String,
            yearsOfExperience: row['yearsOfExperience'] as int,
            registrationNumber: row['registrationNumber'] as String,
            address: row['address'] as String,
            countryCode: row['countryCode'] as String,
            imagePath: row['imagePath'] as String?,
            imageUrl: row['imageUrl'] as String?),
        arguments: [id]);
  }

  @override
  Future<void> insertCompany(Company company) async {
    await _companyInsertionAdapter.insert(company, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateCompany(Company company) async {
    await _companyUpdateAdapter.update(company, OnConflictStrategy.abort);
  }
}

class _$CustomerDao extends CustomerDao {
  _$CustomerDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _customerInsertionAdapter = InsertionAdapter(
            database,
            'customers',
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'phone': item.phone,
                  'email': item.email,
                  'lastVisit': _dateTimeConvertor.encode(item.lastVisit),
                  'gender': item.gender,
                  'address': item.address,
                  'imagePath': item.imagePath,
                  'imageUrl': item.imageUrl,
                  'createdDate': _dateTimeConvertor.encode(item.createdDate)
                }),
        _customerUpdateAdapter = UpdateAdapter(
            database,
            'customers',
            ['id'],
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'phone': item.phone,
                  'email': item.email,
                  'lastVisit': _dateTimeConvertor.encode(item.lastVisit),
                  'gender': item.gender,
                  'address': item.address,
                  'imagePath': item.imagePath,
                  'imageUrl': item.imageUrl,
                  'createdDate': _dateTimeConvertor.encode(item.createdDate)
                }),
        _customerDeletionAdapter = DeletionAdapter(
            database,
            'customers',
            ['id'],
            (Customer item) => <String, Object?>{
                  'id': item.id,
                  'name': item.name,
                  'phone': item.phone,
                  'email': item.email,
                  'lastVisit': _dateTimeConvertor.encode(item.lastVisit),
                  'gender': item.gender,
                  'address': item.address,
                  'imagePath': item.imagePath,
                  'imageUrl': item.imageUrl,
                  'createdDate': _dateTimeConvertor.encode(item.createdDate)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Customer> _customerInsertionAdapter;

  final UpdateAdapter<Customer> _customerUpdateAdapter;

  final DeletionAdapter<Customer> _customerDeletionAdapter;

  @override
  Future<List<Customer>> getAllCustomers() async {
    return _queryAdapter.queryList('SELECT * FROM customers ORDER BY name ASC',
        mapper: (Map<String, Object?> row) => Customer(
            id: row['id'] as String?,
            name: row['name'] as String,
            phone: row['phone'] as String,
            email: row['email'] as String?,
            lastVisit: _dateTimeConvertor.decode(row['lastVisit'] as int),
            gender: row['gender'] as String,
            address: row['address'] as String?,
            imagePath: row['imagePath'] as String?,
            imageUrl: row['imageUrl'] as String?,
            createdDate: _dateTimeConvertor.decode(row['createdDate'] as int)));
  }

  @override
  Future<Customer?> getCustomerById(String id) async {
    return _queryAdapter.query('SELECT * FROM customers WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Customer(
            id: row['id'] as String?,
            name: row['name'] as String,
            phone: row['phone'] as String,
            email: row['email'] as String?,
            lastVisit: _dateTimeConvertor.decode(row['lastVisit'] as int),
            gender: row['gender'] as String,
            address: row['address'] as String?,
            imagePath: row['imagePath'] as String?,
            imageUrl: row['imageUrl'] as String?,
            createdDate: _dateTimeConvertor.decode(row['createdDate'] as int)),
        arguments: [id]);
  }

  @override
  Future<int> insertCustomer(Customer customer) {
    return _customerInsertionAdapter.insertAndReturnId(
        customer, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    await _customerUpdateAdapter.update(customer, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteCustomer(Customer customer) async {
    await _customerDeletionAdapter.delete(customer);
  }
}

class _$OrderDao extends OrderDao {
  _$OrderDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _orderInsertionAdapter = InsertionAdapter(
            database,
            'orders',
            (Order item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'customerId': item.customerId,
                  'status': item.status,
                  'paymentStatus': item.paymentStatus,
                  'paymentAmount': item.paymentAmount,
                  'dueDate': item.dueDate,
                  'notes': item.notes,
                  'createdDate': item.createdDate
                }),
        _orderUpdateAdapter = UpdateAdapter(
            database,
            'orders',
            ['id'],
            (Order item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'customerId': item.customerId,
                  'status': item.status,
                  'paymentStatus': item.paymentStatus,
                  'paymentAmount': item.paymentAmount,
                  'dueDate': item.dueDate,
                  'notes': item.notes,
                  'createdDate': item.createdDate
                }),
        _orderDeletionAdapter = DeletionAdapter(
            database,
            'orders',
            ['id'],
            (Order item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'customerId': item.customerId,
                  'status': item.status,
                  'paymentStatus': item.paymentStatus,
                  'paymentAmount': item.paymentAmount,
                  'dueDate': item.dueDate,
                  'notes': item.notes,
                  'createdDate': item.createdDate
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Order> _orderInsertionAdapter;

  final UpdateAdapter<Order> _orderUpdateAdapter;

  final DeletionAdapter<Order> _orderDeletionAdapter;

  @override
  Future<List<Order>> getAllOrders() async {
    return _queryAdapter.queryList('SELECT * FROM orders ORDER BY dueDate ASC',
        mapper: (Map<String, Object?> row) => Order(
            title: row['title'] as String,
            customerId: row['customerId'] as String,
            status: row['status'] as String,
            paymentStatus: row['paymentStatus'] as String,
            paymentAmount: row['paymentAmount'] as double?,
            dueDate: row['dueDate'] as String?,
            notes: row['notes'] as String?,
            createdDate: row['createdDate'] as String,
            id: row['id'] as String?));
  }

  @override
  Future<Order?> getOrderById(String id) async {
    return _queryAdapter.query('SELECT * FROM orders WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Order(
            title: row['title'] as String,
            customerId: row['customerId'] as String,
            status: row['status'] as String,
            paymentStatus: row['paymentStatus'] as String,
            paymentAmount: row['paymentAmount'] as double?,
            dueDate: row['dueDate'] as String?,
            notes: row['notes'] as String?,
            createdDate: row['createdDate'] as String,
            id: row['id'] as String?),
        arguments: [id]);
  }

  @override
  Future<int?> countCustomerOrder(String customerId) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM orders WHERE customerId = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [customerId]);
  }

  @override
  Future<List<Order>> getAllCustomerOrders(String customerId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM orders WHERE customerId = ?1 ORDER BY dueDate ASC',
        mapper: (Map<String, Object?> row) => Order(
            title: row['title'] as String,
            customerId: row['customerId'] as String,
            status: row['status'] as String,
            paymentStatus: row['paymentStatus'] as String,
            paymentAmount: row['paymentAmount'] as double?,
            dueDate: row['dueDate'] as String?,
            notes: row['notes'] as String?,
            createdDate: row['createdDate'] as String,
            id: row['id'] as String?),
        arguments: [customerId]);
  }

  @override
  Future<void> insertOrder(Order order) async {
    await _orderInsertionAdapter.insert(order, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateOrder(Order order) async {
    await _orderUpdateAdapter.update(order, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteOrder(Order order) async {
    await _orderDeletionAdapter.delete(order);
  }
}

class _$MeasurementDao extends MeasurementDao {
  _$MeasurementDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _measurementInsertionAdapter = InsertionAdapter(
            database,
            'measurements',
            (Measurement item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'measurementValues':
                      _measurementMapConverter.encode(item.measurementValues),
                  'createdDate': _dateTimeConvertor.encode(item.createdDate),
                  'updatedDate': _dateTimeNullConvertor.encode(item.updatedDate)
                }),
        _measurementUpdateAdapter = UpdateAdapter(
            database,
            'measurements',
            ['id'],
            (Measurement item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'measurementValues':
                      _measurementMapConverter.encode(item.measurementValues),
                  'createdDate': _dateTimeConvertor.encode(item.createdDate),
                  'updatedDate': _dateTimeNullConvertor.encode(item.updatedDate)
                }),
        _measurementDeletionAdapter = DeletionAdapter(
            database,
            'measurements',
            ['id'],
            (Measurement item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'measurementValues':
                      _measurementMapConverter.encode(item.measurementValues),
                  'createdDate': _dateTimeConvertor.encode(item.createdDate),
                  'updatedDate': _dateTimeNullConvertor.encode(item.updatedDate)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Measurement> _measurementInsertionAdapter;

  final UpdateAdapter<Measurement> _measurementUpdateAdapter;

  final DeletionAdapter<Measurement> _measurementDeletionAdapter;

  @override
  Future<List<Measurement>> getAllMeasurements() async {
    return _queryAdapter.queryList(
        'SELECT * FROM measurements ORDER BY createdDate ASC',
        mapper: (Map<String, Object?> row) => Measurement(
            id: row['id'] as int?,
            customerId: row['customerId'] as String,
            measurementValues: _measurementMapConverter
                .decode(row['measurementValues'] as String),
            createdDate: _dateTimeConvertor.decode(row['createdDate'] as int),
            updatedDate:
                _dateTimeNullConvertor.decode(row['updatedDate'] as int?)));
  }

  @override
  Future<Measurement?> getById(String id) async {
    return _queryAdapter.query('SELECT * FROM measurements WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Measurement(
            id: row['id'] as int?,
            customerId: row['customerId'] as String,
            measurementValues: _measurementMapConverter
                .decode(row['measurementValues'] as String),
            createdDate: _dateTimeConvertor.decode(row['createdDate'] as int),
            updatedDate:
                _dateTimeNullConvertor.decode(row['updatedDate'] as int?)),
        arguments: [id]);
  }

  @override
  Future<List<Measurement>> getMeasurementsForCustomer(
      String customerId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM measurements WHERE customerId = ?1 ORDER BY createdDate ASC',
        mapper: (Map<String, Object?> row) => Measurement(id: row['id'] as int?, customerId: row['customerId'] as String, measurementValues: _measurementMapConverter.decode(row['measurementValues'] as String), createdDate: _dateTimeConvertor.decode(row['createdDate'] as int), updatedDate: _dateTimeNullConvertor.decode(row['updatedDate'] as int?)),
        arguments: [customerId]);
  }

  @override
  Future<void> insertMeasurement(Measurement measurement) async {
    await _measurementInsertionAdapter.insert(
        measurement, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateMeasurement(Measurement measurement) async {
    await _measurementUpdateAdapter.update(
        measurement, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteMeasurement(Measurement measurement) async {
    await _measurementDeletionAdapter.delete(measurement);
  }
}

class _$InvoiceDao extends InvoiceDao {
  _$InvoiceDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _invoiceInsertionAdapter = InsertionAdapter(
            database,
            'invoices',
            (Invoice item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'customerId': item.customerId,
                  'status': item.status,
                  'totalAmount': item.totalAmount,
                  'date': _dateTimeConvertor.encode(item.date),
                  'orderId': item.orderId,
                  'createdDate': item.createdDate,
                  'updatedDate': item.updatedDate
                }),
        _invoiceUpdateAdapter = UpdateAdapter(
            database,
            'invoices',
            ['id'],
            (Invoice item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'customerId': item.customerId,
                  'status': item.status,
                  'totalAmount': item.totalAmount,
                  'date': _dateTimeConvertor.encode(item.date),
                  'orderId': item.orderId,
                  'createdDate': item.createdDate,
                  'updatedDate': item.updatedDate
                }),
        _invoiceDeletionAdapter = DeletionAdapter(
            database,
            'invoices',
            ['id'],
            (Invoice item) => <String, Object?>{
                  'id': item.id,
                  'title': item.title,
                  'customerId': item.customerId,
                  'status': item.status,
                  'totalAmount': item.totalAmount,
                  'date': _dateTimeConvertor.encode(item.date),
                  'orderId': item.orderId,
                  'createdDate': item.createdDate,
                  'updatedDate': item.updatedDate
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Invoice> _invoiceInsertionAdapter;

  final UpdateAdapter<Invoice> _invoiceUpdateAdapter;

  final DeletionAdapter<Invoice> _invoiceDeletionAdapter;

  @override
  Future<List<Invoice>> getAllInvoices() async {
    return _queryAdapter.queryList('SELECT * FROM invoices',
        mapper: (Map<String, Object?> row) => Invoice(
            id: row['id'] as String,
            title: row['title'] as String,
            customerId: row['customerId'] as String,
            status: row['status'] as String,
            totalAmount: row['totalAmount'] as double,
            date: _dateTimeConvertor.decode(row['date'] as int),
            orderId: row['orderId'] as String,
            createdDate: row['createdDate'] as String?,
            updatedDate: row['updatedDate'] as String?));
  }

  @override
  Future<Invoice?> getInvoiceById(String id) async {
    return _queryAdapter.query('SELECT * FROM invoices WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Invoice(
            id: row['id'] as String,
            title: row['title'] as String,
            customerId: row['customerId'] as String,
            status: row['status'] as String,
            totalAmount: row['totalAmount'] as double,
            date: _dateTimeConvertor.decode(row['date'] as int),
            orderId: row['orderId'] as String,
            createdDate: row['createdDate'] as String?,
            updatedDate: row['updatedDate'] as String?),
        arguments: [id]);
  }

  @override
  Future<void> insertInvoice(Invoice invoice) async {
    await _invoiceInsertionAdapter.insert(invoice, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateInvoice(Invoice invoice) async {
    await _invoiceUpdateAdapter.update(invoice, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteInvoice(Invoice invoice) async {
    await _invoiceDeletionAdapter.delete(invoice);
  }
}

// ignore_for_file: unused_element
final _dateTimeConvertor = DateTimeConvertor();
final _measurementMapConverter = MeasurementMapConverter();
final _dateTimeNullConvertor = DateTimeNullConvertor();
