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

  ProjectDao? _projectDaoInstance;

  PaymentDao? _paymentDaoInstance;

  AppImageDao? _appImageDaoInstance;

  Future<sqflite.Database> open(
    String path,
    List<Migration> migrations, [
    Callback? callback,
  ]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 10,
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
            'CREATE TABLE IF NOT EXISTS `company` (`id` TEXT NOT NULL, `businessName` TEXT NOT NULL, `ownerName` TEXT NOT NULL, `email` TEXT NOT NULL, `mobile` TEXT NOT NULL, `yearsOfExperience` INTEGER, `registrationNumber` TEXT NOT NULL, `countryCode` TEXT NOT NULL, `address` TEXT NOT NULL, `logoUrl` TEXT, `imagePath` TEXT, `active` INTEGER NOT NULL, `currency` TEXT NOT NULL, `country` TEXT NOT NULL, `deviceId` TEXT, `businessType` TEXT, `enablePushNotifications` INTEGER, `enableSmsNotifications` INTEGER, `enableEmailNotifications` INTEGER, `measurementSystem` TEXT, `appAppearance` TEXT, `genderSpecialty` TEXT, `locationName` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `customers` (`id` TEXT, `name` TEXT NOT NULL, `phone` TEXT NOT NULL, `email` TEXT, `lastVisit` INTEGER NOT NULL, `gender` TEXT NOT NULL, `address` TEXT, `imagePath` TEXT, `profileImageUrl` TEXT, `createdDate` INTEGER NOT NULL, `syncDate` INTEGER, `isSynced` INTEGER NOT NULL, `companyId` TEXT, `userId` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `orders` (`id` TEXT NOT NULL, `title` TEXT NOT NULL, `customerId` TEXT NOT NULL, `status` TEXT NOT NULL, `paymentStatus` TEXT NOT NULL, `paymentAmount` REAL, `dueDate` TEXT, `notes` TEXT, `createdDate` TEXT NOT NULL, `orderNumber` TEXT, `subtotal` REAL, `total` REAL, `tax` REAL, `expectedDeliveryDate` INTEGER, `syncDate` INTEGER, `isSynced` INTEGER NOT NULL, `companyId` TEXT, `userId` TEXT, `currentStage` TEXT NOT NULL, `designReferences` TEXT NOT NULL, `totalQuotation` REAL NOT NULL, `paidAmount` REAL NOT NULL, `garmentType` TEXT NOT NULL, `fabric` TEXT NOT NULL, `lining` TEXT NOT NULL, FOREIGN KEY (`customerId`) REFERENCES `customers` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `measurements` (`id` TEXT NOT NULL, `customerId` TEXT NOT NULL, `name` TEXT NOT NULL, `measurementValues` TEXT NOT NULL, `createdDate` INTEGER NOT NULL, `updatedDate` INTEGER, `syncDate` INTEGER, `isSynced` INTEGER NOT NULL, `companyId` TEXT, `userId` TEXT, FOREIGN KEY (`customerId`) REFERENCES `customers` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `invoices` (`id` TEXT NOT NULL, `customerId` TEXT NOT NULL, `companyId` TEXT, `userId` TEXT, `status` TEXT NOT NULL, `createdDate` TEXT, `updatedDate` TEXT, `invoiceNumber` TEXT, `issueDate` INTEGER, `dueDate` INTEGER, `notes` TEXT, `terms` TEXT, `subtotal` REAL, `tax` REAL, `total` REAL, `projectId` TEXT, `syncDate` INTEGER, `isSynced` INTEGER NOT NULL, `title` TEXT, `date` INTEGER, `orderId` TEXT, `isPaid` INTEGER NOT NULL, FOREIGN KEY (`customerId`) REFERENCES `customers` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, FOREIGN KEY (`orderId`) REFERENCES `orders` (`id`) ON UPDATE NO ACTION ON DELETE SET NULL, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `payments` (`id` TEXT NOT NULL, `invoiceId` TEXT NOT NULL, `companyId` TEXT, `amount` REAL NOT NULL, `paymentDate` INTEGER NOT NULL, `referenceNumber` TEXT, `notes` TEXT, `status` TEXT NOT NULL, `syncDate` INTEGER, `isSynced` INTEGER NOT NULL, `userId` TEXT, `method` TEXT NOT NULL, FOREIGN KEY (`invoiceId`) REFERENCES `invoices` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `order_items` (`id` TEXT NOT NULL, `orderId` TEXT NOT NULL, `productName` TEXT NOT NULL, `productDescription` TEXT, `quantity` INTEGER NOT NULL, `unitPrice` REAL NOT NULL, `taxRate` REAL, `amount` REAL NOT NULL, `syncDate` INTEGER, `isSynced` INTEGER NOT NULL, `companyId` TEXT, `userId` TEXT, FOREIGN KEY (`orderId`) REFERENCES `orders` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `invoice_items` (`id` TEXT NOT NULL, `invoiceId` TEXT NOT NULL, `description` TEXT NOT NULL, `quantity` INTEGER, `unitPrice` REAL NOT NULL, `taxRate` REAL, `amount` REAL NOT NULL, `syncDate` INTEGER, `isSynced` INTEGER NOT NULL, `companyId` TEXT, `userId` TEXT, FOREIGN KEY (`invoiceId`) REFERENCES `invoices` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `projects` (`id` TEXT NOT NULL, `company_id` TEXT NOT NULL, `client_id` TEXT NOT NULL, `title` TEXT NOT NULL, `description` TEXT, `status` INTEGER NOT NULL, `start_date` INTEGER, `deadline` INTEGER, `completed_date` INTEGER, `budget` REAL NOT NULL, `spent` REAL NOT NULL, `created_at` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, `is_synced` INTEGER NOT NULL, `sync_date` INTEGER, `user_id` TEXT, PRIMARY KEY (`id`))');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `app_images` (`id` TEXT NOT NULL, `localPath` TEXT NOT NULL, `cloudUrl` TEXT, `publicId` TEXT, `ownerId` TEXT NOT NULL, `ownerType` TEXT NOT NULL, `syncStatus` TEXT NOT NULL, `createdAt` INTEGER NOT NULL, PRIMARY KEY (`id`))');

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

  @override
  ProjectDao get projectDao {
    return _projectDaoInstance ??= _$ProjectDao(database, changeListener);
  }

  @override
  PaymentDao get paymentDao {
    return _paymentDaoInstance ??= _$PaymentDao(database, changeListener);
  }

  @override
  AppImageDao get appImageDao {
    return _appImageDaoInstance ??= _$AppImageDao(database, changeListener);
  }
}

class _$CompanyDao extends CompanyDao {
  _$CompanyDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _companyInsertionAdapter = InsertionAdapter(
            database,
            'company',
            (Company item) => <String, Object?>{
                  'id': item.id,
                  'businessName': item.businessName,
                  'ownerName': item.ownerName,
                  'email': item.email,
                  'mobile': item.mobile,
                  'yearsOfExperience': item.yearsOfExperience,
                  'registrationNumber': item.registrationNumber,
                  'countryCode': item.countryCode,
                  'address': item.address,
                  'logoUrl': item.logoUrl,
                  'imagePath': item.imagePath,
                  'active': item.active ? 1 : 0,
                  'currency': item.currency,
                  'country': item.country,
                  'deviceId': item.deviceId,
                  'businessType': item.businessType,
                  'enablePushNotifications':
                      item.enablePushNotifications == null
                          ? null
                          : (item.enablePushNotifications! ? 1 : 0),
                  'enableSmsNotifications': item.enableSmsNotifications == null
                      ? null
                      : (item.enableSmsNotifications! ? 1 : 0),
                  'enableEmailNotifications':
                      item.enableEmailNotifications == null
                          ? null
                          : (item.enableEmailNotifications! ? 1 : 0),
                  'measurementSystem': item.measurementSystem,
                  'appAppearance': item.appAppearance,
                  'genderSpecialty': item.genderSpecialty,
                  'locationName': item.locationName
                }),
        _companyUpdateAdapter = UpdateAdapter(
            database,
            'company',
            ['id'],
            (Company item) => <String, Object?>{
                  'id': item.id,
                  'businessName': item.businessName,
                  'ownerName': item.ownerName,
                  'email': item.email,
                  'mobile': item.mobile,
                  'yearsOfExperience': item.yearsOfExperience,
                  'registrationNumber': item.registrationNumber,
                  'countryCode': item.countryCode,
                  'address': item.address,
                  'logoUrl': item.logoUrl,
                  'imagePath': item.imagePath,
                  'active': item.active ? 1 : 0,
                  'currency': item.currency,
                  'country': item.country,
                  'deviceId': item.deviceId,
                  'businessType': item.businessType,
                  'enablePushNotifications':
                      item.enablePushNotifications == null
                          ? null
                          : (item.enablePushNotifications! ? 1 : 0),
                  'enableSmsNotifications': item.enableSmsNotifications == null
                      ? null
                      : (item.enableSmsNotifications! ? 1 : 0),
                  'enableEmailNotifications':
                      item.enableEmailNotifications == null
                          ? null
                          : (item.enableEmailNotifications! ? 1 : 0),
                  'measurementSystem': item.measurementSystem,
                  'appAppearance': item.appAppearance,
                  'genderSpecialty': item.genderSpecialty,
                  'locationName': item.locationName
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Company> _companyInsertionAdapter;

  final UpdateAdapter<Company> _companyUpdateAdapter;

  @override
  Future<Company?> getCompany() async {
    return _queryAdapter.query('SELECT * FROM Company LIMIT 1',
        mapper: (Map<String, Object?> row) => Company(
            id: row['id'] as String?,
            businessName: row['businessName'] as String,
            ownerName: row['ownerName'] as String,
            email: row['email'] as String,
            mobile: row['mobile'] as String,
            yearsOfExperience: row['yearsOfExperience'] as int?,
            registrationNumber: row['registrationNumber'] as String,
            countryCode: row['countryCode'] as String,
            address: row['address'] as String,
            logoUrl: row['logoUrl'] as String?,
            imagePath: row['imagePath'] as String?,
            active: (row['active'] as int) != 0,
            currency: row['currency'] as String,
            country: row['country'] as String,
            deviceId: row['deviceId'] as String?,
            businessType: row['businessType'] as String?,
            enablePushNotifications: row['enablePushNotifications'] == null
                ? null
                : (row['enablePushNotifications'] as int) != 0,
            enableSmsNotifications: row['enableSmsNotifications'] == null
                ? null
                : (row['enableSmsNotifications'] as int) != 0,
            enableEmailNotifications: row['enableEmailNotifications'] == null
                ? null
                : (row['enableEmailNotifications'] as int) != 0,
            measurementSystem: row['measurementSystem'] as String?,
            appAppearance: row['appAppearance'] as String?,
            genderSpecialty: row['genderSpecialty'] as String?,
            locationName: row['locationName'] as String?));
  }

  @override
  Future<List<Company>> findAllCompanies() async {
    return _queryAdapter.queryList('SELECT * FROM Company',
        mapper: (Map<String, Object?> row) => Company(
            id: row['id'] as String?,
            businessName: row['businessName'] as String,
            ownerName: row['ownerName'] as String,
            email: row['email'] as String,
            mobile: row['mobile'] as String,
            yearsOfExperience: row['yearsOfExperience'] as int?,
            registrationNumber: row['registrationNumber'] as String,
            countryCode: row['countryCode'] as String,
            address: row['address'] as String,
            logoUrl: row['logoUrl'] as String?,
            imagePath: row['imagePath'] as String?,
            active: (row['active'] as int) != 0,
            currency: row['currency'] as String,
            country: row['country'] as String,
            deviceId: row['deviceId'] as String?,
            businessType: row['businessType'] as String?,
            enablePushNotifications: row['enablePushNotifications'] == null
                ? null
                : (row['enablePushNotifications'] as int) != 0,
            enableSmsNotifications: row['enableSmsNotifications'] == null
                ? null
                : (row['enableSmsNotifications'] as int) != 0,
            enableEmailNotifications: row['enableEmailNotifications'] == null
                ? null
                : (row['enableEmailNotifications'] as int) != 0,
            measurementSystem: row['measurementSystem'] as String?,
            appAppearance: row['appAppearance'] as String?,
            genderSpecialty: row['genderSpecialty'] as String?,
            locationName: row['locationName'] as String?));
  }

  @override
  Future<Company?> findCompanyById(String id) async {
    return _queryAdapter.query('SELECT * FROM Company WHERE id=?1',
        mapper: (Map<String, Object?> row) => Company(
            id: row['id'] as String?,
            businessName: row['businessName'] as String,
            ownerName: row['ownerName'] as String,
            email: row['email'] as String,
            mobile: row['mobile'] as String,
            yearsOfExperience: row['yearsOfExperience'] as int?,
            registrationNumber: row['registrationNumber'] as String,
            countryCode: row['countryCode'] as String,
            address: row['address'] as String,
            logoUrl: row['logoUrl'] as String?,
            imagePath: row['imagePath'] as String?,
            active: (row['active'] as int) != 0,
            currency: row['currency'] as String,
            country: row['country'] as String,
            deviceId: row['deviceId'] as String?,
            businessType: row['businessType'] as String?,
            enablePushNotifications: row['enablePushNotifications'] == null
                ? null
                : (row['enablePushNotifications'] as int) != 0,
            enableSmsNotifications: row['enableSmsNotifications'] == null
                ? null
                : (row['enableSmsNotifications'] as int) != 0,
            enableEmailNotifications: row['enableEmailNotifications'] == null
                ? null
                : (row['enableEmailNotifications'] as int) != 0,
            measurementSystem: row['measurementSystem'] as String?,
            appAppearance: row['appAppearance'] as String?,
            genderSpecialty: row['genderSpecialty'] as String?,
            locationName: row['locationName'] as String?),
        arguments: [id]);
  }

  @override
  Future<Company?> getCompanyByEmail(String email) async {
    return _queryAdapter.query('SELECT * FROM company WHERE email = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => Company(
            id: row['id'] as String?,
            businessName: row['businessName'] as String,
            ownerName: row['ownerName'] as String,
            email: row['email'] as String,
            mobile: row['mobile'] as String,
            yearsOfExperience: row['yearsOfExperience'] as int?,
            registrationNumber: row['registrationNumber'] as String,
            countryCode: row['countryCode'] as String,
            address: row['address'] as String,
            logoUrl: row['logoUrl'] as String?,
            imagePath: row['imagePath'] as String?,
            active: (row['active'] as int) != 0,
            currency: row['currency'] as String,
            country: row['country'] as String,
            deviceId: row['deviceId'] as String?,
            businessType: row['businessType'] as String?,
            enablePushNotifications: row['enablePushNotifications'] == null
                ? null
                : (row['enablePushNotifications'] as int) != 0,
            enableSmsNotifications: row['enableSmsNotifications'] == null
                ? null
                : (row['enableSmsNotifications'] as int) != 0,
            enableEmailNotifications: row['enableEmailNotifications'] == null
                ? null
                : (row['enableEmailNotifications'] as int) != 0,
            measurementSystem: row['measurementSystem'] as String?,
            appAppearance: row['appAppearance'] as String?,
            genderSpecialty: row['genderSpecialty'] as String?,
            locationName: row['locationName'] as String?),
        arguments: [email]);
  }

  @override
  Future<Company?> getCompanyByMobile(String mobile) async {
    return _queryAdapter.query(
        'SELECT * FROM company WHERE mobile = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => Company(
            id: row['id'] as String?,
            businessName: row['businessName'] as String,
            ownerName: row['ownerName'] as String,
            email: row['email'] as String,
            mobile: row['mobile'] as String,
            yearsOfExperience: row['yearsOfExperience'] as int?,
            registrationNumber: row['registrationNumber'] as String,
            countryCode: row['countryCode'] as String,
            address: row['address'] as String,
            logoUrl: row['logoUrl'] as String?,
            imagePath: row['imagePath'] as String?,
            active: (row['active'] as int) != 0,
            currency: row['currency'] as String,
            country: row['country'] as String,
            deviceId: row['deviceId'] as String?,
            businessType: row['businessType'] as String?,
            enablePushNotifications: row['enablePushNotifications'] == null
                ? null
                : (row['enablePushNotifications'] as int) != 0,
            enableSmsNotifications: row['enableSmsNotifications'] == null
                ? null
                : (row['enableSmsNotifications'] as int) != 0,
            enableEmailNotifications: row['enableEmailNotifications'] == null
                ? null
                : (row['enableEmailNotifications'] as int) != 0,
            measurementSystem: row['measurementSystem'] as String?,
            appAppearance: row['appAppearance'] as String?,
            genderSpecialty: row['genderSpecialty'] as String?,
            locationName: row['locationName'] as String?),
        arguments: [mobile]);
  }

  @override
  Future<Company?> getCompanyByEmailAndMobile(
    String mobile,
    String password,
  ) async {
    return _queryAdapter.query(
        'SELECT * FROM company WHERE mobile = ?1 AND email= ?2 LIMIT 1',
        mapper: (Map<String, Object?> row) => Company(
            id: row['id'] as String?,
            businessName: row['businessName'] as String,
            ownerName: row['ownerName'] as String,
            email: row['email'] as String,
            mobile: row['mobile'] as String,
            yearsOfExperience: row['yearsOfExperience'] as int?,
            registrationNumber: row['registrationNumber'] as String,
            countryCode: row['countryCode'] as String,
            address: row['address'] as String,
            logoUrl: row['logoUrl'] as String?,
            imagePath: row['imagePath'] as String?,
            active: (row['active'] as int) != 0,
            currency: row['currency'] as String,
            country: row['country'] as String,
            deviceId: row['deviceId'] as String?,
            businessType: row['businessType'] as String?,
            enablePushNotifications: row['enablePushNotifications'] == null
                ? null
                : (row['enablePushNotifications'] as int) != 0,
            enableSmsNotifications: row['enableSmsNotifications'] == null
                ? null
                : (row['enableSmsNotifications'] as int) != 0,
            enableEmailNotifications: row['enableEmailNotifications'] == null
                ? null
                : (row['enableEmailNotifications'] as int) != 0,
            measurementSystem: row['measurementSystem'] as String?,
            appAppearance: row['appAppearance'] as String?,
            genderSpecialty: row['genderSpecialty'] as String?,
            locationName: row['locationName'] as String?),
        arguments: [mobile, password]);
  }

  @override
  Future<int> insertCompany(Company company) {
    return _companyInsertionAdapter.insertAndReturnId(
        company, OnConflictStrategy.replace);
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
                  'profileImageUrl': item.profileImageUrl,
                  'createdDate': _dateTimeConvertor.encode(item.createdDate),
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'companyId': item.companyId,
                  'userId': item.userId
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
                  'profileImageUrl': item.profileImageUrl,
                  'createdDate': _dateTimeConvertor.encode(item.createdDate),
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'companyId': item.companyId,
                  'userId': item.userId
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
                  'profileImageUrl': item.profileImageUrl,
                  'createdDate': _dateTimeConvertor.encode(item.createdDate),
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'companyId': item.companyId,
                  'userId': item.userId
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
            profileImageUrl: row['profileImageUrl'] as String?,
            createdDate: _dateTimeConvertor.decode(row['createdDate'] as int),
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            companyId: row['companyId'] as String?,
            userId: row['userId'] as String?));
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
            profileImageUrl: row['profileImageUrl'] as String?,
            createdDate: _dateTimeConvertor.decode(row['createdDate'] as int),
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            companyId: row['companyId'] as String?,
            userId: row['userId'] as String?),
        arguments: [id]);
  }

  @override
  Future<int?> getCustomerCount() async {
    return _queryAdapter.query('SELECT COUNT(*) FROM customers',
        mapper: (Map<String, Object?> row) => row.values.first as int);
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
                  'createdDate': item.createdDate,
                  'orderNumber': item.orderNumber,
                  'subtotal': item.subtotal,
                  'total': item.total,
                  'tax': item.tax,
                  'expectedDeliveryDate':
                      _dateTimeNullConvertor.encode(item.expectedDeliveryDate),
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'companyId': item.companyId,
                  'userId': item.userId,
                  'currentStage':
                      _productionStageConverter.encode(item.currentStage),
                  'designReferences':
                      _stringListConverter.encode(item.designReferences),
                  'totalQuotation': item.totalQuotation,
                  'paidAmount': item.paidAmount,
                  'garmentType': item.garmentType,
                  'fabric': item.fabric,
                  'lining': item.lining
                }),
        _orderItemInsertionAdapter = InsertionAdapter(
            database,
            'order_items',
            (OrderItem item) => <String, Object?>{
                  'id': item.id,
                  'orderId': item.orderId,
                  'productName': item.productName,
                  'productDescription': item.productDescription,
                  'quantity': item.quantity,
                  'unitPrice': item.unitPrice,
                  'taxRate': item.taxRate,
                  'amount': item.amount,
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'companyId': item.companyId,
                  'userId': item.userId
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
                  'createdDate': item.createdDate,
                  'orderNumber': item.orderNumber,
                  'subtotal': item.subtotal,
                  'total': item.total,
                  'tax': item.tax,
                  'expectedDeliveryDate':
                      _dateTimeNullConvertor.encode(item.expectedDeliveryDate),
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'companyId': item.companyId,
                  'userId': item.userId,
                  'currentStage':
                      _productionStageConverter.encode(item.currentStage),
                  'designReferences':
                      _stringListConverter.encode(item.designReferences),
                  'totalQuotation': item.totalQuotation,
                  'paidAmount': item.paidAmount,
                  'garmentType': item.garmentType,
                  'fabric': item.fabric,
                  'lining': item.lining
                }),
        _orderItemUpdateAdapter = UpdateAdapter(
            database,
            'order_items',
            ['id'],
            (OrderItem item) => <String, Object?>{
                  'id': item.id,
                  'orderId': item.orderId,
                  'productName': item.productName,
                  'productDescription': item.productDescription,
                  'quantity': item.quantity,
                  'unitPrice': item.unitPrice,
                  'taxRate': item.taxRate,
                  'amount': item.amount,
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'companyId': item.companyId,
                  'userId': item.userId
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
                  'createdDate': item.createdDate,
                  'orderNumber': item.orderNumber,
                  'subtotal': item.subtotal,
                  'total': item.total,
                  'tax': item.tax,
                  'expectedDeliveryDate':
                      _dateTimeNullConvertor.encode(item.expectedDeliveryDate),
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'companyId': item.companyId,
                  'userId': item.userId,
                  'currentStage':
                      _productionStageConverter.encode(item.currentStage),
                  'designReferences':
                      _stringListConverter.encode(item.designReferences),
                  'totalQuotation': item.totalQuotation,
                  'paidAmount': item.paidAmount,
                  'garmentType': item.garmentType,
                  'fabric': item.fabric,
                  'lining': item.lining
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Order> _orderInsertionAdapter;

  final InsertionAdapter<OrderItem> _orderItemInsertionAdapter;

  final UpdateAdapter<Order> _orderUpdateAdapter;

  final UpdateAdapter<OrderItem> _orderItemUpdateAdapter;

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
            id: row['id'] as String?,
            orderNumber: row['orderNumber'] as String?,
            subtotal: row['subtotal'] as double?,
            total: row['total'] as double?,
            tax: row['tax'] as double?,
            expectedDeliveryDate: _dateTimeNullConvertor
                .decode(row['expectedDeliveryDate'] as int?),
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            companyId: row['companyId'] as String?,
            userId: row['userId'] as String?,
            currentStage:
                _productionStageConverter.decode(row['currentStage'] as String),
            designReferences:
                _stringListConverter.decode(row['designReferences'] as String),
            totalQuotation: row['totalQuotation'] as double,
            paidAmount: row['paidAmount'] as double,
            garmentType: row['garmentType'] as String,
            fabric: row['fabric'] as String,
            lining: row['lining'] as String));
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
            id: row['id'] as String?,
            orderNumber: row['orderNumber'] as String?,
            subtotal: row['subtotal'] as double?,
            total: row['total'] as double?,
            tax: row['tax'] as double?,
            expectedDeliveryDate: _dateTimeNullConvertor
                .decode(row['expectedDeliveryDate'] as int?),
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            companyId: row['companyId'] as String?,
            userId: row['userId'] as String?,
            currentStage:
                _productionStageConverter.decode(row['currentStage'] as String),
            designReferences:
                _stringListConverter.decode(row['designReferences'] as String),
            totalQuotation: row['totalQuotation'] as double,
            paidAmount: row['paidAmount'] as double,
            garmentType: row['garmentType'] as String,
            fabric: row['fabric'] as String,
            lining: row['lining'] as String),
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
            id: row['id'] as String?,
            orderNumber: row['orderNumber'] as String?,
            subtotal: row['subtotal'] as double?,
            total: row['total'] as double?,
            tax: row['tax'] as double?,
            expectedDeliveryDate: _dateTimeNullConvertor
                .decode(row['expectedDeliveryDate'] as int?),
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            companyId: row['companyId'] as String?,
            userId: row['userId'] as String?,
            currentStage:
                _productionStageConverter.decode(row['currentStage'] as String),
            designReferences:
                _stringListConverter.decode(row['designReferences'] as String),
            totalQuotation: row['totalQuotation'] as double,
            paidAmount: row['paidAmount'] as double,
            garmentType: row['garmentType'] as String,
            fabric: row['fabric'] as String,
            lining: row['lining'] as String),
        arguments: [customerId]);
  }

  @override
  Future<int?> getActiveOrderCount() async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM orders WHERE status != \"Completed\"',
        mapper: (Map<String, Object?> row) => row.values.first as int);
  }

  @override
  Future<Order?> getSoonestDueOrder() async {
    return _queryAdapter.query(
        'SELECT * FROM orders ORDER BY dueDate ASC LIMIT 1',
        mapper: (Map<String, Object?> row) => Order(
            title: row['title'] as String,
            customerId: row['customerId'] as String,
            status: row['status'] as String,
            paymentStatus: row['paymentStatus'] as String,
            paymentAmount: row['paymentAmount'] as double?,
            dueDate: row['dueDate'] as String?,
            notes: row['notes'] as String?,
            createdDate: row['createdDate'] as String,
            id: row['id'] as String?,
            orderNumber: row['orderNumber'] as String?,
            subtotal: row['subtotal'] as double?,
            total: row['total'] as double?,
            tax: row['tax'] as double?,
            expectedDeliveryDate: _dateTimeNullConvertor
                .decode(row['expectedDeliveryDate'] as int?),
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            companyId: row['companyId'] as String?,
            userId: row['userId'] as String?,
            currentStage:
                _productionStageConverter.decode(row['currentStage'] as String),
            designReferences:
                _stringListConverter.decode(row['designReferences'] as String),
            totalQuotation: row['totalQuotation'] as double,
            paidAmount: row['paidAmount'] as double,
            garmentType: row['garmentType'] as String,
            fabric: row['fabric'] as String,
            lining: row['lining'] as String));
  }

  @override
  Future<List<OrderItem>> getOrderItems(String orderId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM order_items WHERE orderId = ?1',
        mapper: (Map<String, Object?> row) => OrderItem(
            id: row['id'] as String?,
            orderId: row['orderId'] as String,
            productName: row['productName'] as String,
            productDescription: row['productDescription'] as String?,
            quantity: row['quantity'] as int,
            unitPrice: row['unitPrice'] as double,
            taxRate: row['taxRate'] as double?,
            amount: row['amount'] as double,
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            companyId: row['companyId'] as String?,
            userId: row['userId'] as String?),
        arguments: [orderId]);
  }

  @override
  Future<void> deleteOrderItems(String orderId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM order_items WHERE orderId = ?1',
        arguments: [orderId]);
  }

  @override
  Future<Customer?> getCustomer(String customerId) async {
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
            profileImageUrl: row['profileImageUrl'] as String?,
            createdDate: _dateTimeConvertor.decode(row['createdDate'] as int),
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            companyId: row['companyId'] as String?,
            userId: row['userId'] as String?),
        arguments: [customerId]);
  }

  @override
  Future<Invoice?> getInvoiceByOrderId(String orderId) async {
    return _queryAdapter.query(
        'SELECT * FROM invoices WHERE orderId = ?1 LIMIT 1',
        mapper: (Map<String, Object?> row) => Invoice(
            id: row['id'] as String?,
            customerId: row['customerId'] as String,
            companyId: row['companyId'] as String?,
            userId: row['userId'] as String?,
            status: row['status'] as String,
            createdDate: row['createdDate'] as String?,
            updatedDate: row['updatedDate'] as String?,
            invoiceNumber: row['invoiceNumber'] as String?,
            issueDate: _dateTimeNullConvertor.decode(row['issueDate'] as int?),
            dueDate: _dateTimeNullConvertor.decode(row['dueDate'] as int?),
            notes: row['notes'] as String?,
            terms: row['terms'] as String?,
            subtotal: row['subtotal'] as double?,
            tax: row['tax'] as double?,
            total: row['total'] as double?,
            projectId: row['projectId'] as String?,
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            title: row['title'] as String?,
            date: _dateTimeNullConvertor.decode(row['date'] as int?),
            orderId: row['orderId'] as String?,
            isPaid: (row['isPaid'] as int) != 0),
        arguments: [orderId]);
  }

  @override
  Future<List<Invoice>?> getInvoicesByOrderId(String orderId) async {
    return _queryAdapter.queryList('SELECT * FROM invoices WHERE orderId = ?1',
        mapper: (Map<String, Object?> row) => Invoice(
            id: row['id'] as String?,
            customerId: row['customerId'] as String,
            companyId: row['companyId'] as String?,
            userId: row['userId'] as String?,
            status: row['status'] as String,
            createdDate: row['createdDate'] as String?,
            updatedDate: row['updatedDate'] as String?,
            invoiceNumber: row['invoiceNumber'] as String?,
            issueDate: _dateTimeNullConvertor.decode(row['issueDate'] as int?),
            dueDate: _dateTimeNullConvertor.decode(row['dueDate'] as int?),
            notes: row['notes'] as String?,
            terms: row['terms'] as String?,
            subtotal: row['subtotal'] as double?,
            tax: row['tax'] as double?,
            total: row['total'] as double?,
            projectId: row['projectId'] as String?,
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            title: row['title'] as String?,
            date: _dateTimeNullConvertor.decode(row['date'] as int?),
            orderId: row['orderId'] as String?,
            isPaid: (row['isPaid'] as int) != 0),
        arguments: [orderId]);
  }

  @override
  Future<Invoice?> getInvoiceByCustomerId(String customerId) async {
    return _queryAdapter.query('SELECT * FROM invoices WHERE customerId = ?1',
        mapper: (Map<String, Object?> row) => Invoice(
            id: row['id'] as String?,
            customerId: row['customerId'] as String,
            companyId: row['companyId'] as String?,
            userId: row['userId'] as String?,
            status: row['status'] as String,
            createdDate: row['createdDate'] as String?,
            updatedDate: row['updatedDate'] as String?,
            invoiceNumber: row['invoiceNumber'] as String?,
            issueDate: _dateTimeNullConvertor.decode(row['issueDate'] as int?),
            dueDate: _dateTimeNullConvertor.decode(row['dueDate'] as int?),
            notes: row['notes'] as String?,
            terms: row['terms'] as String?,
            subtotal: row['subtotal'] as double?,
            tax: row['tax'] as double?,
            total: row['total'] as double?,
            projectId: row['projectId'] as String?,
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            title: row['title'] as String?,
            date: _dateTimeNullConvertor.decode(row['date'] as int?),
            orderId: row['orderId'] as String?,
            isPaid: (row['isPaid'] as int) != 0),
        arguments: [customerId]);
  }

  @override
  Future<void> insertOrder(Order order) async {
    await _orderInsertionAdapter.insert(order, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertOrderItem(OrderItem orderItem) async {
    await _orderItemInsertionAdapter.insert(
        orderItem, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateOrder(Order order) async {
    await _orderUpdateAdapter.update(order, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateOrderItem(OrderItem orderItem) async {
    await _orderItemUpdateAdapter.update(orderItem, OnConflictStrategy.abort);
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
                  'name': item.name,
                  'measurementValues':
                      _measurementMapConverter.encode(item.measurementValues),
                  'createdDate': _dateTimeConvertor.encode(item.createdDate),
                  'updatedDate':
                      _dateTimeNullConvertor.encode(item.updatedDate),
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'companyId': item.companyId,
                  'userId': item.userId
                }),
        _measurementUpdateAdapter = UpdateAdapter(
            database,
            'measurements',
            ['id'],
            (Measurement item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'name': item.name,
                  'measurementValues':
                      _measurementMapConverter.encode(item.measurementValues),
                  'createdDate': _dateTimeConvertor.encode(item.createdDate),
                  'updatedDate':
                      _dateTimeNullConvertor.encode(item.updatedDate),
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'companyId': item.companyId,
                  'userId': item.userId
                }),
        _measurementDeletionAdapter = DeletionAdapter(
            database,
            'measurements',
            ['id'],
            (Measurement item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'name': item.name,
                  'measurementValues':
                      _measurementMapConverter.encode(item.measurementValues),
                  'createdDate': _dateTimeConvertor.encode(item.createdDate),
                  'updatedDate':
                      _dateTimeNullConvertor.encode(item.updatedDate),
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'companyId': item.companyId,
                  'userId': item.userId
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
            id: row['id'] as String?,
            customerId: row['customerId'] as String,
            name: row['name'] as String,
            measurementValues: _measurementMapConverter
                .decode(row['measurementValues'] as String),
            createdDate: _dateTimeConvertor.decode(row['createdDate'] as int),
            updatedDate:
                _dateTimeNullConvertor.decode(row['updatedDate'] as int?),
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            companyId: row['companyId'] as String?,
            userId: row['userId'] as String?));
  }

  @override
  Future<Measurement?> getById(String id) async {
    return _queryAdapter.query('SELECT * FROM measurements WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Measurement(
            id: row['id'] as String?,
            customerId: row['customerId'] as String,
            name: row['name'] as String,
            measurementValues: _measurementMapConverter
                .decode(row['measurementValues'] as String),
            createdDate: _dateTimeConvertor.decode(row['createdDate'] as int),
            updatedDate:
                _dateTimeNullConvertor.decode(row['updatedDate'] as int?),
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            companyId: row['companyId'] as String?,
            userId: row['userId'] as String?),
        arguments: [id]);
  }

  @override
  Future<List<Measurement>> getMeasurementsForCustomer(
      String customerId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM measurements WHERE customerId = ?1 ORDER BY createdDate ASC',
        mapper: (Map<String, Object?> row) => Measurement(id: row['id'] as String?, customerId: row['customerId'] as String, name: row['name'] as String, measurementValues: _measurementMapConverter.decode(row['measurementValues'] as String), createdDate: _dateTimeConvertor.decode(row['createdDate'] as int), updatedDate: _dateTimeNullConvertor.decode(row['updatedDate'] as int?), syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?), isSynced: (row['isSynced'] as int) != 0, companyId: row['companyId'] as String?, userId: row['userId'] as String?),
        arguments: [customerId]);
  }

  @override
  Future<List<Measurement>> getMeasurementsByCustomerId(
      String customerId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM measurements WHERE customerId = ?1',
        mapper: (Map<String, Object?> row) => Measurement(
            id: row['id'] as String?,
            customerId: row['customerId'] as String,
            name: row['name'] as String,
            measurementValues: _measurementMapConverter
                .decode(row['measurementValues'] as String),
            createdDate: _dateTimeConvertor.decode(row['createdDate'] as int),
            updatedDate:
                _dateTimeNullConvertor.decode(row['updatedDate'] as int?),
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            companyId: row['companyId'] as String?,
            userId: row['userId'] as String?),
        arguments: [customerId]);
  }

  @override
  Future<Measurement?> getMeasurementById(String id) async {
    return _queryAdapter.query('SELECT * FROM measurements WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Measurement(
            id: row['id'] as String?,
            customerId: row['customerId'] as String,
            name: row['name'] as String,
            measurementValues: _measurementMapConverter
                .decode(row['measurementValues'] as String),
            createdDate: _dateTimeConvertor.decode(row['createdDate'] as int),
            updatedDate:
                _dateTimeNullConvertor.decode(row['updatedDate'] as int?),
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            companyId: row['companyId'] as String?,
            userId: row['userId'] as String?),
        arguments: [id]);
  }

  @override
  Future<void> deleteMeasurementsByCustomerId(String customerId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM measurements WHERE customerId = ?1',
        arguments: [customerId]);
  }

  @override
  Future<int> insertMeasurement(Measurement measurement) {
    return _measurementInsertionAdapter.insertAndReturnId(
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
                  'customerId': item.customerId,
                  'companyId': item.companyId,
                  'userId': item.userId,
                  'status': item.status,
                  'createdDate': item.createdDate,
                  'updatedDate': item.updatedDate,
                  'invoiceNumber': item.invoiceNumber,
                  'issueDate': _dateTimeNullConvertor.encode(item.issueDate),
                  'dueDate': _dateTimeNullConvertor.encode(item.dueDate),
                  'notes': item.notes,
                  'terms': item.terms,
                  'subtotal': item.subtotal,
                  'tax': item.tax,
                  'total': item.total,
                  'projectId': item.projectId,
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'title': item.title,
                  'date': _dateTimeNullConvertor.encode(item.date),
                  'orderId': item.orderId,
                  'isPaid': item.isPaid ? 1 : 0
                }),
        _invoiceItemInsertionAdapter = InsertionAdapter(
            database,
            'invoice_items',
            (InvoiceItem item) => <String, Object?>{
                  'id': item.id,
                  'invoiceId': item.invoiceId,
                  'description': item.description,
                  'quantity': item.quantity,
                  'unitPrice': item.unitPrice,
                  'taxRate': item.taxRate,
                  'amount': item.amount,
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'companyId': item.companyId,
                  'userId': item.userId
                }),
        _paymentInsertionAdapter = InsertionAdapter(
            database,
            'payments',
            (Payment item) => <String, Object?>{
                  'id': item.id,
                  'invoiceId': item.invoiceId,
                  'companyId': item.companyId,
                  'amount': item.amount,
                  'paymentDate': _dateTimeConvertor.encode(item.paymentDate),
                  'referenceNumber': item.referenceNumber,
                  'notes': item.notes,
                  'status': item.status,
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'userId': item.userId,
                  'method': item.method
                }),
        _invoiceUpdateAdapter = UpdateAdapter(
            database,
            'invoices',
            ['id'],
            (Invoice item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'companyId': item.companyId,
                  'userId': item.userId,
                  'status': item.status,
                  'createdDate': item.createdDate,
                  'updatedDate': item.updatedDate,
                  'invoiceNumber': item.invoiceNumber,
                  'issueDate': _dateTimeNullConvertor.encode(item.issueDate),
                  'dueDate': _dateTimeNullConvertor.encode(item.dueDate),
                  'notes': item.notes,
                  'terms': item.terms,
                  'subtotal': item.subtotal,
                  'tax': item.tax,
                  'total': item.total,
                  'projectId': item.projectId,
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'title': item.title,
                  'date': _dateTimeNullConvertor.encode(item.date),
                  'orderId': item.orderId,
                  'isPaid': item.isPaid ? 1 : 0
                }),
        _invoiceItemUpdateAdapter = UpdateAdapter(
            database,
            'invoice_items',
            ['id'],
            (InvoiceItem item) => <String, Object?>{
                  'id': item.id,
                  'invoiceId': item.invoiceId,
                  'description': item.description,
                  'quantity': item.quantity,
                  'unitPrice': item.unitPrice,
                  'taxRate': item.taxRate,
                  'amount': item.amount,
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'companyId': item.companyId,
                  'userId': item.userId
                }),
        _paymentUpdateAdapter = UpdateAdapter(
            database,
            'payments',
            ['id'],
            (Payment item) => <String, Object?>{
                  'id': item.id,
                  'invoiceId': item.invoiceId,
                  'companyId': item.companyId,
                  'amount': item.amount,
                  'paymentDate': _dateTimeConvertor.encode(item.paymentDate),
                  'referenceNumber': item.referenceNumber,
                  'notes': item.notes,
                  'status': item.status,
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'userId': item.userId,
                  'method': item.method
                }),
        _invoiceDeletionAdapter = DeletionAdapter(
            database,
            'invoices',
            ['id'],
            (Invoice item) => <String, Object?>{
                  'id': item.id,
                  'customerId': item.customerId,
                  'companyId': item.companyId,
                  'userId': item.userId,
                  'status': item.status,
                  'createdDate': item.createdDate,
                  'updatedDate': item.updatedDate,
                  'invoiceNumber': item.invoiceNumber,
                  'issueDate': _dateTimeNullConvertor.encode(item.issueDate),
                  'dueDate': _dateTimeNullConvertor.encode(item.dueDate),
                  'notes': item.notes,
                  'terms': item.terms,
                  'subtotal': item.subtotal,
                  'tax': item.tax,
                  'total': item.total,
                  'projectId': item.projectId,
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'title': item.title,
                  'date': _dateTimeNullConvertor.encode(item.date),
                  'orderId': item.orderId,
                  'isPaid': item.isPaid ? 1 : 0
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Invoice> _invoiceInsertionAdapter;

  final InsertionAdapter<InvoiceItem> _invoiceItemInsertionAdapter;

  final InsertionAdapter<Payment> _paymentInsertionAdapter;

  final UpdateAdapter<Invoice> _invoiceUpdateAdapter;

  final UpdateAdapter<InvoiceItem> _invoiceItemUpdateAdapter;

  final UpdateAdapter<Payment> _paymentUpdateAdapter;

  final DeletionAdapter<Invoice> _invoiceDeletionAdapter;

  @override
  Future<List<Invoice>> getAllInvoices() async {
    return _queryAdapter.queryList('SELECT * FROM invoices',
        mapper: (Map<String, Object?> row) => Invoice(
            id: row['id'] as String?,
            customerId: row['customerId'] as String,
            companyId: row['companyId'] as String?,
            userId: row['userId'] as String?,
            status: row['status'] as String,
            createdDate: row['createdDate'] as String?,
            updatedDate: row['updatedDate'] as String?,
            invoiceNumber: row['invoiceNumber'] as String?,
            issueDate: _dateTimeNullConvertor.decode(row['issueDate'] as int?),
            dueDate: _dateTimeNullConvertor.decode(row['dueDate'] as int?),
            notes: row['notes'] as String?,
            terms: row['terms'] as String?,
            subtotal: row['subtotal'] as double?,
            tax: row['tax'] as double?,
            total: row['total'] as double?,
            projectId: row['projectId'] as String?,
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            title: row['title'] as String?,
            date: _dateTimeNullConvertor.decode(row['date'] as int?),
            orderId: row['orderId'] as String?,
            isPaid: (row['isPaid'] as int) != 0));
  }

  @override
  Future<Invoice?> getInvoiceById(String id) async {
    return _queryAdapter.query('SELECT * FROM invoices WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Invoice(
            id: row['id'] as String?,
            customerId: row['customerId'] as String,
            companyId: row['companyId'] as String?,
            userId: row['userId'] as String?,
            status: row['status'] as String,
            createdDate: row['createdDate'] as String?,
            updatedDate: row['updatedDate'] as String?,
            invoiceNumber: row['invoiceNumber'] as String?,
            issueDate: _dateTimeNullConvertor.decode(row['issueDate'] as int?),
            dueDate: _dateTimeNullConvertor.decode(row['dueDate'] as int?),
            notes: row['notes'] as String?,
            terms: row['terms'] as String?,
            subtotal: row['subtotal'] as double?,
            tax: row['tax'] as double?,
            total: row['total'] as double?,
            projectId: row['projectId'] as String?,
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            title: row['title'] as String?,
            date: _dateTimeNullConvertor.decode(row['date'] as int?),
            orderId: row['orderId'] as String?,
            isPaid: (row['isPaid'] as int) != 0),
        arguments: [id]);
  }

  @override
  Future<List<InvoiceItem>> getInvoiceItems(String invoiceId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM invoice_items WHERE invoiceId = ?1',
        mapper: (Map<String, Object?> row) => InvoiceItem(
            id: row['id'] as String?,
            invoiceId: row['invoiceId'] as String,
            description: row['description'] as String,
            quantity: row['quantity'] as int?,
            unitPrice: row['unitPrice'] as double,
            taxRate: row['taxRate'] as double?,
            amount: row['amount'] as double,
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            companyId: row['companyId'] as String?,
            userId: row['userId'] as String?),
        arguments: [invoiceId]);
  }

  @override
  Future<void> deleteInvoiceItems(String invoiceId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM invoice_items WHERE invoiceId = ?1',
        arguments: [invoiceId]);
  }

  @override
  Future<List<Payment>> getPayments(String invoiceId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM payments WHERE invoiceId = ?1',
        mapper: (Map<String, Object?> row) => Payment(
            id: row['id'] as String?,
            invoiceId: row['invoiceId'] as String,
            companyId: row['companyId'] as String?,
            amount: row['amount'] as double,
            paymentDate: _dateTimeConvertor.decode(row['paymentDate'] as int),
            referenceNumber: row['referenceNumber'] as String?,
            notes: row['notes'] as String?,
            status: row['status'] as String,
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            userId: row['userId'] as String?,
            method: row['method'] as String),
        arguments: [invoiceId]);
  }

  @override
  Future<void> deletePayments(String invoiceId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM payments WHERE invoiceId = ?1',
        arguments: [invoiceId]);
  }

  @override
  Future<void> insertInvoice(Invoice invoice) async {
    await _invoiceInsertionAdapter.insert(invoice, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertInvoiceItem(InvoiceItem invoiceItem) async {
    await _invoiceItemInsertionAdapter.insert(
        invoiceItem, OnConflictStrategy.replace);
  }

  @override
  Future<void> insertPayment(Payment payment) async {
    await _paymentInsertionAdapter.insert(payment, OnConflictStrategy.replace);
  }

  @override
  Future<void> updateInvoice(Invoice invoice) async {
    await _invoiceUpdateAdapter.update(invoice, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateInvoiceItem(InvoiceItem invoiceItem) async {
    await _invoiceItemUpdateAdapter.update(
        invoiceItem, OnConflictStrategy.abort);
  }

  @override
  Future<void> updatePayment(Payment payment) async {
    await _paymentUpdateAdapter.update(payment, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteInvoice(Invoice invoice) async {
    await _invoiceDeletionAdapter.delete(invoice);
  }
}

class _$ProjectDao extends ProjectDao {
  _$ProjectDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _projectInsertionAdapter = InsertionAdapter(
            database,
            'projects',
            (Project item) => <String, Object?>{
                  'id': item.id,
                  'company_id': item.companyId,
                  'client_id': item.clientId,
                  'title': item.title,
                  'description': item.description,
                  'status': item.status.index,
                  'start_date': _dateTimeNullConvertor.encode(item.startDate),
                  'deadline': _dateTimeNullConvertor.encode(item.deadline),
                  'completed_date':
                      _dateTimeNullConvertor.encode(item.completedDate),
                  'budget': item.budget,
                  'spent': item.spent,
                  'created_at': _dateTimeConvertor.encode(item.createdAt),
                  'updated_at': _dateTimeConvertor.encode(item.updatedAt),
                  'is_synced': item.isSynced ? 1 : 0,
                  'sync_date': _dateTimeNullConvertor.encode(item.syncDate),
                  'user_id': item.userId
                }),
        _projectUpdateAdapter = UpdateAdapter(
            database,
            'projects',
            ['id'],
            (Project item) => <String, Object?>{
                  'id': item.id,
                  'company_id': item.companyId,
                  'client_id': item.clientId,
                  'title': item.title,
                  'description': item.description,
                  'status': item.status.index,
                  'start_date': _dateTimeNullConvertor.encode(item.startDate),
                  'deadline': _dateTimeNullConvertor.encode(item.deadline),
                  'completed_date':
                      _dateTimeNullConvertor.encode(item.completedDate),
                  'budget': item.budget,
                  'spent': item.spent,
                  'created_at': _dateTimeConvertor.encode(item.createdAt),
                  'updated_at': _dateTimeConvertor.encode(item.updatedAt),
                  'is_synced': item.isSynced ? 1 : 0,
                  'sync_date': _dateTimeNullConvertor.encode(item.syncDate),
                  'user_id': item.userId
                }),
        _projectDeletionAdapter = DeletionAdapter(
            database,
            'projects',
            ['id'],
            (Project item) => <String, Object?>{
                  'id': item.id,
                  'company_id': item.companyId,
                  'client_id': item.clientId,
                  'title': item.title,
                  'description': item.description,
                  'status': item.status.index,
                  'start_date': _dateTimeNullConvertor.encode(item.startDate),
                  'deadline': _dateTimeNullConvertor.encode(item.deadline),
                  'completed_date':
                      _dateTimeNullConvertor.encode(item.completedDate),
                  'budget': item.budget,
                  'spent': item.spent,
                  'created_at': _dateTimeConvertor.encode(item.createdAt),
                  'updated_at': _dateTimeConvertor.encode(item.updatedAt),
                  'is_synced': item.isSynced ? 1 : 0,
                  'sync_date': _dateTimeNullConvertor.encode(item.syncDate),
                  'user_id': item.userId
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Project> _projectInsertionAdapter;

  final UpdateAdapter<Project> _projectUpdateAdapter;

  final DeletionAdapter<Project> _projectDeletionAdapter;

  @override
  Future<Project?> getProjectById(String id) async {
    return _queryAdapter.query('SELECT * FROM projects WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Project(
            id: row['id'] as String?,
            companyId: row['company_id'] as String,
            clientId: row['client_id'] as String,
            title: row['title'] as String,
            description: row['description'] as String?,
            status: ProjectStatus.values[row['status'] as int],
            startDate: _dateTimeNullConvertor.decode(row['start_date'] as int?),
            deadline: _dateTimeNullConvertor.decode(row['deadline'] as int?),
            completedDate:
                _dateTimeNullConvertor.decode(row['completed_date'] as int?),
            budget: row['budget'] as double,
            spent: row['spent'] as double,
            createdAt: _dateTimeNullConvertor.decode(row['created_at'] as int?),
            updatedAt: _dateTimeNullConvertor.decode(row['updated_at'] as int?),
            isSynced: (row['is_synced'] as int) != 0,
            syncDate: _dateTimeNullConvertor.decode(row['sync_date'] as int?),
            userId: row['user_id'] as String?),
        arguments: [id]);
  }

  @override
  Future<List<Project>> getProjectsByCompany(String companyId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM projects WHERE company_id = ?1 ORDER BY updated_at DESC',
        mapper: (Map<String, Object?> row) => Project(
            id: row['id'] as String?,
            companyId: row['company_id'] as String,
            clientId: row['client_id'] as String,
            title: row['title'] as String,
            description: row['description'] as String?,
            status: ProjectStatus.values[row['status'] as int],
            startDate: _dateTimeNullConvertor.decode(row['start_date'] as int?),
            deadline: _dateTimeNullConvertor.decode(row['deadline'] as int?),
            completedDate:
                _dateTimeNullConvertor.decode(row['completed_date'] as int?),
            budget: row['budget'] as double,
            spent: row['spent'] as double,
            createdAt: _dateTimeNullConvertor.decode(row['created_at'] as int?),
            updatedAt: _dateTimeNullConvertor.decode(row['updated_at'] as int?),
            isSynced: (row['is_synced'] as int) != 0,
            syncDate: _dateTimeNullConvertor.decode(row['sync_date'] as int?),
            userId: row['user_id'] as String?),
        arguments: [companyId]);
  }

  @override
  Future<List<Project>> searchProjects(
    String companyId,
    String query,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM projects      WHERE company_id = ?1      AND (title LIKE \'%\' || ?2 || \'%\' OR description LIKE \'%\' || ?2 || \'%\')     ORDER BY updated_at DESC',
        mapper: (Map<String, Object?> row) => Project(id: row['id'] as String?, companyId: row['company_id'] as String, clientId: row['client_id'] as String, title: row['title'] as String, description: row['description'] as String?, status: ProjectStatus.values[row['status'] as int], startDate: _dateTimeNullConvertor.decode(row['start_date'] as int?), deadline: _dateTimeNullConvertor.decode(row['deadline'] as int?), completedDate: _dateTimeNullConvertor.decode(row['completed_date'] as int?), budget: row['budget'] as double, spent: row['spent'] as double, createdAt: _dateTimeNullConvertor.decode(row['created_at'] as int?), updatedAt: _dateTimeNullConvertor.decode(row['updated_at'] as int?), isSynced: (row['is_synced'] as int) != 0, syncDate: _dateTimeNullConvertor.decode(row['sync_date'] as int?), userId: row['user_id'] as String?),
        arguments: [companyId, query]);
  }

  @override
  Future<List<Project>> getProjectsByStatus(
    String companyId,
    String status,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM projects      WHERE company_id = ?1      AND status = ?2     ORDER BY updated_at DESC',
        mapper: (Map<String, Object?> row) => Project(id: row['id'] as String?, companyId: row['company_id'] as String, clientId: row['client_id'] as String, title: row['title'] as String, description: row['description'] as String?, status: ProjectStatus.values[row['status'] as int], startDate: _dateTimeNullConvertor.decode(row['start_date'] as int?), deadline: _dateTimeNullConvertor.decode(row['deadline'] as int?), completedDate: _dateTimeNullConvertor.decode(row['completed_date'] as int?), budget: row['budget'] as double, spent: row['spent'] as double, createdAt: _dateTimeNullConvertor.decode(row['created_at'] as int?), updatedAt: _dateTimeNullConvertor.decode(row['updated_at'] as int?), isSynced: (row['is_synced'] as int) != 0, syncDate: _dateTimeNullConvertor.decode(row['sync_date'] as int?), userId: row['user_id'] as String?),
        arguments: [companyId, status]);
  }

  @override
  Future<List<Project>> getOverdueProjects(
    String companyId,
    DateTime date,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM projects      WHERE company_id = ?1      AND deadline < ?2     AND status NOT IN (\'COMPLETED\', \'CANCELLED\')     ORDER BY deadline ASC',
        mapper: (Map<String, Object?> row) => Project(id: row['id'] as String?, companyId: row['company_id'] as String, clientId: row['client_id'] as String, title: row['title'] as String, description: row['description'] as String?, status: ProjectStatus.values[row['status'] as int], startDate: _dateTimeNullConvertor.decode(row['start_date'] as int?), deadline: _dateTimeNullConvertor.decode(row['deadline'] as int?), completedDate: _dateTimeNullConvertor.decode(row['completed_date'] as int?), budget: row['budget'] as double, spent: row['spent'] as double, createdAt: _dateTimeNullConvertor.decode(row['created_at'] as int?), updatedAt: _dateTimeNullConvertor.decode(row['updated_at'] as int?), isSynced: (row['is_synced'] as int) != 0, syncDate: _dateTimeNullConvertor.decode(row['sync_date'] as int?), userId: row['user_id'] as String?),
        arguments: [companyId, _dateTimeConvertor.encode(date)]);
  }

  @override
  Future<List<Project>> getProjectsDueBetween(
    String companyId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM projects      WHERE company_id = ?1      AND deadline BETWEEN ?2 AND ?3     ORDER BY deadline ASC',
        mapper: (Map<String, Object?> row) => Project(
            id: row['id'] as String?,
            companyId: row['company_id'] as String,
            clientId: row['client_id'] as String,
            title: row['title'] as String,
            description: row['description'] as String?,
            status: ProjectStatus.values[row['status'] as int],
            startDate: _dateTimeNullConvertor.decode(row['start_date'] as int?),
            deadline: _dateTimeNullConvertor.decode(row['deadline'] as int?),
            completedDate:
                _dateTimeNullConvertor.decode(row['completed_date'] as int?),
            budget: row['budget'] as double,
            spent: row['spent'] as double,
            createdAt: _dateTimeNullConvertor.decode(row['created_at'] as int?),
            updatedAt: _dateTimeNullConvertor.decode(row['updated_at'] as int?),
            isSynced: (row['is_synced'] as int) != 0,
            syncDate: _dateTimeNullConvertor.decode(row['sync_date'] as int?),
            userId: row['user_id'] as String?),
        arguments: [
          companyId,
          _dateTimeConvertor.encode(startDate),
          _dateTimeConvertor.encode(endDate)
        ]);
  }

  @override
  Future<List<Project>> getProjectsByClient(String clientId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM projects WHERE client_id = ?1 ORDER BY updated_at DESC',
        mapper: (Map<String, Object?> row) => Project(
            id: row['id'] as String?,
            companyId: row['company_id'] as String,
            clientId: row['client_id'] as String,
            title: row['title'] as String,
            description: row['description'] as String?,
            status: ProjectStatus.values[row['status'] as int],
            startDate: _dateTimeNullConvertor.decode(row['start_date'] as int?),
            deadline: _dateTimeNullConvertor.decode(row['deadline'] as int?),
            completedDate:
                _dateTimeNullConvertor.decode(row['completed_date'] as int?),
            budget: row['budget'] as double,
            spent: row['spent'] as double,
            createdAt: _dateTimeNullConvertor.decode(row['created_at'] as int?),
            updatedAt: _dateTimeNullConvertor.decode(row['updated_at'] as int?),
            isSynced: (row['is_synced'] as int) != 0,
            syncDate: _dateTimeNullConvertor.decode(row['sync_date'] as int?),
            userId: row['user_id'] as String?),
        arguments: [clientId]);
  }

  @override
  Future<void> deleteProjectById(String id) async {
    await _queryAdapter
        .queryNoReturn('DELETE FROM projects WHERE id = ?1', arguments: [id]);
  }

  @override
  Future<void> deleteProjectsByCompany(String companyId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM projects WHERE company_id = ?1',
        arguments: [companyId]);
  }

  @override
  Future<int?> countProjects(String companyId) async {
    return _queryAdapter.query(
        'SELECT COUNT(*) FROM projects WHERE company_id = ?1',
        mapper: (Map<String, Object?> row) => row.values.first as int,
        arguments: [companyId]);
  }

  @override
  Future<void> insertProject(Project project) async {
    await _projectInsertionAdapter.insert(project, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateProject(Project project) async {
    await _projectUpdateAdapter.update(project, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteProject(Project project) async {
    await _projectDeletionAdapter.delete(project);
  }
}

class _$PaymentDao extends PaymentDao {
  _$PaymentDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _paymentInsertionAdapter = InsertionAdapter(
            database,
            'payments',
            (Payment item) => <String, Object?>{
                  'id': item.id,
                  'invoiceId': item.invoiceId,
                  'companyId': item.companyId,
                  'amount': item.amount,
                  'paymentDate': _dateTimeConvertor.encode(item.paymentDate),
                  'referenceNumber': item.referenceNumber,
                  'notes': item.notes,
                  'status': item.status,
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'userId': item.userId,
                  'method': item.method
                }),
        _paymentUpdateAdapter = UpdateAdapter(
            database,
            'payments',
            ['id'],
            (Payment item) => <String, Object?>{
                  'id': item.id,
                  'invoiceId': item.invoiceId,
                  'companyId': item.companyId,
                  'amount': item.amount,
                  'paymentDate': _dateTimeConvertor.encode(item.paymentDate),
                  'referenceNumber': item.referenceNumber,
                  'notes': item.notes,
                  'status': item.status,
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'userId': item.userId,
                  'method': item.method
                }),
        _paymentDeletionAdapter = DeletionAdapter(
            database,
            'payments',
            ['id'],
            (Payment item) => <String, Object?>{
                  'id': item.id,
                  'invoiceId': item.invoiceId,
                  'companyId': item.companyId,
                  'amount': item.amount,
                  'paymentDate': _dateTimeConvertor.encode(item.paymentDate),
                  'referenceNumber': item.referenceNumber,
                  'notes': item.notes,
                  'status': item.status,
                  'syncDate': _dateTimeNullConvertor.encode(item.syncDate),
                  'isSynced': item.isSynced ? 1 : 0,
                  'userId': item.userId,
                  'method': item.method
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<Payment> _paymentInsertionAdapter;

  final UpdateAdapter<Payment> _paymentUpdateAdapter;

  final DeletionAdapter<Payment> _paymentDeletionAdapter;

  @override
  Future<List<Payment>> getAllPayments() async {
    return _queryAdapter.queryList('SELECT * FROM payments',
        mapper: (Map<String, Object?> row) => Payment(
            id: row['id'] as String?,
            invoiceId: row['invoiceId'] as String,
            companyId: row['companyId'] as String?,
            amount: row['amount'] as double,
            paymentDate: _dateTimeConvertor.decode(row['paymentDate'] as int),
            referenceNumber: row['referenceNumber'] as String?,
            notes: row['notes'] as String?,
            status: row['status'] as String,
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            userId: row['userId'] as String?,
            method: row['method'] as String));
  }

  @override
  Future<Payment?> getPaymentById(String id) async {
    return _queryAdapter.query('SELECT * FROM payments WHERE id = ?1',
        mapper: (Map<String, Object?> row) => Payment(
            id: row['id'] as String?,
            invoiceId: row['invoiceId'] as String,
            companyId: row['companyId'] as String?,
            amount: row['amount'] as double,
            paymentDate: _dateTimeConvertor.decode(row['paymentDate'] as int),
            referenceNumber: row['referenceNumber'] as String?,
            notes: row['notes'] as String?,
            status: row['status'] as String,
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            userId: row['userId'] as String?,
            method: row['method'] as String),
        arguments: [id]);
  }

  @override
  Future<List<Payment>> getPaymentsForInvoice(String invoiceId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM payments WHERE invoiceId = ?1',
        mapper: (Map<String, Object?> row) => Payment(
            id: row['id'] as String?,
            invoiceId: row['invoiceId'] as String,
            companyId: row['companyId'] as String?,
            amount: row['amount'] as double,
            paymentDate: _dateTimeConvertor.decode(row['paymentDate'] as int),
            referenceNumber: row['referenceNumber'] as String?,
            notes: row['notes'] as String?,
            status: row['status'] as String,
            syncDate: _dateTimeNullConvertor.decode(row['syncDate'] as int?),
            isSynced: (row['isSynced'] as int) != 0,
            userId: row['userId'] as String?,
            method: row['method'] as String),
        arguments: [invoiceId]);
  }

  @override
  Future<void> insertPayment(Payment payment) async {
    await _paymentInsertionAdapter.insert(payment, OnConflictStrategy.replace);
  }

  @override
  Future<void> updatePayment(Payment payment) async {
    await _paymentUpdateAdapter.update(payment, OnConflictStrategy.abort);
  }

  @override
  Future<void> deletePayment(Payment payment) async {
    await _paymentDeletionAdapter.delete(payment);
  }
}

class _$AppImageDao extends AppImageDao {
  _$AppImageDao(
    this.database,
    this.changeListener,
  )   : _queryAdapter = QueryAdapter(database),
        _appImageInsertionAdapter = InsertionAdapter(
            database,
            'app_images',
            (AppImage item) => <String, Object?>{
                  'id': item.id,
                  'localPath': item.localPath,
                  'cloudUrl': item.cloudUrl,
                  'publicId': item.publicId,
                  'ownerId': item.ownerId,
                  'ownerType': item.ownerType,
                  'syncStatus': item.syncStatus,
                  'createdAt': _dateTimeConvertor.encode(item.createdAt)
                }),
        _appImageUpdateAdapter = UpdateAdapter(
            database,
            'app_images',
            ['id'],
            (AppImage item) => <String, Object?>{
                  'id': item.id,
                  'localPath': item.localPath,
                  'cloudUrl': item.cloudUrl,
                  'publicId': item.publicId,
                  'ownerId': item.ownerId,
                  'ownerType': item.ownerType,
                  'syncStatus': item.syncStatus,
                  'createdAt': _dateTimeConvertor.encode(item.createdAt)
                }),
        _appImageDeletionAdapter = DeletionAdapter(
            database,
            'app_images',
            ['id'],
            (AppImage item) => <String, Object?>{
                  'id': item.id,
                  'localPath': item.localPath,
                  'cloudUrl': item.cloudUrl,
                  'publicId': item.publicId,
                  'ownerId': item.ownerId,
                  'ownerType': item.ownerType,
                  'syncStatus': item.syncStatus,
                  'createdAt': _dateTimeConvertor.encode(item.createdAt)
                });

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  final InsertionAdapter<AppImage> _appImageInsertionAdapter;

  final UpdateAdapter<AppImage> _appImageUpdateAdapter;

  final DeletionAdapter<AppImage> _appImageDeletionAdapter;

  @override
  Future<List<AppImage>> getImages(
    String ownerId,
    String ownerType,
  ) async {
    return _queryAdapter.queryList(
        'SELECT * FROM app_images WHERE ownerId = ?1 AND ownerType = ?2',
        mapper: (Map<String, Object?> row) => AppImage(
            id: row['id'] as String,
            localPath: row['localPath'] as String,
            cloudUrl: row['cloudUrl'] as String?,
            publicId: row['publicId'] as String?,
            ownerId: row['ownerId'] as String,
            ownerType: row['ownerType'] as String,
            syncStatus: row['syncStatus'] as String,
            createdAt: _dateTimeConvertor.decode(row['createdAt'] as int)),
        arguments: [ownerId, ownerType]);
  }

  @override
  Future<void> deleteByOwner(
    String ownerId,
    String ownerType,
  ) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM app_images WHERE ownerId = ?1 AND ownerType = ?2',
        arguments: [ownerId, ownerType]);
  }

  @override
  Future<void> insertImage(AppImage image) async {
    await _appImageInsertionAdapter.insert(image, OnConflictStrategy.abort);
  }

  @override
  Future<void> updateImage(AppImage image) async {
    await _appImageUpdateAdapter.update(image, OnConflictStrategy.abort);
  }

  @override
  Future<void> deleteImage(AppImage image) async {
    await _appImageDeletionAdapter.delete(image);
  }
}

// ignore_for_file: unused_element
final _dateTimeConvertor = DateTimeConvertor();
final _measurementMapConverter = MeasurementMapConverter();
final _dateTimeNullConvertor = DateTimeNullConvertor();
final _stringListConverter = StringListConverter();
final _productionStageConverter = ProductionStageConverter();
