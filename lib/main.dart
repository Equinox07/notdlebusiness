import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:notdle/db/app_database.dart';
import 'package:floor/floor.dart';
import 'package:notdle/pages/index_page.dart';
import 'package:notdle/providers/api_provider.dart';
import 'package:notdle/providers/app_provider.dart';
import 'package:notdle/providers/company_provider.dart';
import 'package:notdle/providers/customer_provider.dart';
import 'package:notdle/providers/dashboard_provider.dart';
import 'package:notdle/providers/invoice_provider.dart';
import 'package:notdle/providers/measurement_provider.dart';
import 'package:notdle/providers/notification_provider.dart';
import 'package:notdle/providers/order_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final migration1to2 = Migration(1, 2, (database) async {
    await database.execute(
      'ALTER TABLE company ADD COLUMN currency TEXT NOT NULL DEFAULT "GHS"',
    );
  });

  final migration2to3 = Migration(2, 3, (database) async {
    await database.execute(
      'ALTER TABLE company ADD COLUMN country TEXT NOT NULL DEFAULT "Ghana"',
    );
  });

  final migration3to4 = Migration(3, 4, (database) async {
    await database.execute('ALTER TABLE company ADD COLUMN deviceId TEXT');
  });

  final migration4to5 = Migration(4, 5, (database) async {
    // 1. Rename existing tables
    await database.execute('ALTER TABLE customers RENAME TO customers_old');
    await database.execute(
      'ALTER TABLE measurements RENAME TO measurements_old',
    );
    await database.execute('ALTER TABLE orders RENAME TO orders_old');
    await database.execute('ALTER TABLE invoices RENAME TO invoices_old');
    await database.execute('ALTER TABLE order_items RENAME TO order_items_old');
    await database.execute(
      'ALTER TABLE invoice_items RENAME TO invoice_items_old',
    );
    await database.execute('ALTER TABLE payments RENAME TO payments_old');
    await database.execute('ALTER TABLE projects RENAME TO projects_old');

    // 2. Create new tables with correct types (using schema from generated code)
    await database.execute(
      'CREATE TABLE IF NOT EXISTS `customers` (`id` TEXT, `name` TEXT NOT NULL, `phone` TEXT NOT NULL, `email` TEXT, `lastVisit` INTEGER NOT NULL, `gender` TEXT NOT NULL, `address` TEXT, `imagePath` TEXT, `profileImageUrl` TEXT, `createdDate` INTEGER NOT NULL, `syncDate` INTEGER, `isSynced` INTEGER NOT NULL, PRIMARY KEY (`id`))',
    );
    await database.execute(
      'CREATE TABLE IF NOT EXISTS `measurements` (`id` TEXT NOT NULL, `customerId` TEXT NOT NULL, `name` TEXT NOT NULL, `measurementValues` TEXT NOT NULL, `createdDate` INTEGER NOT NULL, `updatedDate` INTEGER, `syncDate` INTEGER, `isSynced` INTEGER NOT NULL, FOREIGN KEY (`customerId`) REFERENCES `customers` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))',
    );
    await database.execute(
      'CREATE TABLE IF NOT EXISTS `orders` (`id` TEXT NOT NULL, `title` TEXT NOT NULL, `customerId` TEXT NOT NULL, `status` TEXT NOT NULL, `paymentStatus` TEXT NOT NULL, `paymentAmount` REAL, `dueDate` TEXT, `notes` TEXT, `createdDate` TEXT NOT NULL, `orderNumber` TEXT, `subtotal` REAL, `total` REAL, `tax` REAL, `expectedDeliveryDate` INTEGER, `syncDate` INTEGER, `isSynced` INTEGER NOT NULL, FOREIGN KEY (`customerId`) REFERENCES `customers` (`id`) ON UPDATE NO ACTION ON DELETE NO ACTION, PRIMARY KEY (`id`))',
    );
    await database.execute(
      'CREATE TABLE IF NOT EXISTS `invoices` (`id` TEXT NOT NULL, `customerId` TEXT NOT NULL, `companyId` TEXT, `status` TEXT NOT NULL, `createdDate` TEXT, `updatedDate` TEXT, `invoiceNumber` TEXT, `issueDate` INTEGER, `dueDate` INTEGER, `notes` TEXT, `terms` TEXT, `subtotal` REAL, `tax` REAL, `total` REAL, `projectId` TEXT, `syncDate` INTEGER, `isSynced` INTEGER NOT NULL, `title` TEXT, `date` INTEGER, `orderId` TEXT, FOREIGN KEY (`customerId`) REFERENCES `customers` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, FOREIGN KEY (`orderId`) REFERENCES `orders` (`id`) ON UPDATE NO ACTION ON DELETE SET NULL, PRIMARY KEY (`id`))',
    );
    await database.execute(
      'CREATE TABLE IF NOT EXISTS `order_items` (`id` TEXT NOT NULL, `orderId` TEXT NOT NULL, `productName` TEXT NOT NULL, `productDescription` TEXT, `quantity` INTEGER NOT NULL, `unitPrice` REAL NOT NULL, `taxRate` REAL, `amount` REAL NOT NULL, `syncDate` INTEGER, `isSynced` INTEGER NOT NULL, FOREIGN KEY (`orderId`) REFERENCES `orders` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))',
    );
    await database.execute(
      'CREATE TABLE IF NOT EXISTS `invoice_items` (`id` TEXT NOT NULL, `invoiceId` TEXT NOT NULL, `description` TEXT NOT NULL, `quantity` INTEGER NOT NULL, `unitPrice` REAL NOT NULL, `taxRate` REAL, `amount` REAL NOT NULL, `syncDate` INTEGER, `isSynced` INTEGER NOT NULL, FOREIGN KEY (`invoiceId`) REFERENCES `invoices` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))',
    );
    await database.execute(
      'CREATE TABLE IF NOT EXISTS `payments` (`id` TEXT NOT NULL, `invoiceId` TEXT NOT NULL, `companyId` TEXT, `amount` REAL NOT NULL, `paymentDate` INTEGER NOT NULL, `referenceNumber` TEXT, `notes` TEXT, `status` TEXT NOT NULL, `syncDate` INTEGER, `isSynced` INTEGER NOT NULL, FOREIGN KEY (`invoiceId`) REFERENCES `invoices` (`id`) ON UPDATE NO ACTION ON DELETE CASCADE, PRIMARY KEY (`id`))',
    );
    await database.execute(
      'CREATE TABLE IF NOT EXISTS `projects` (`id` TEXT NOT NULL, `company_id` TEXT NOT NULL, `client_id` TEXT NOT NULL, `title` TEXT NOT NULL, `description` TEXT, `status` INTEGER NOT NULL, `start_date` INTEGER, `deadline` INTEGER, `completed_date` INTEGER, `budget` REAL NOT NULL, `spent` REAL NOT NULL, `created_at` INTEGER NOT NULL, `updated_at` INTEGER NOT NULL, `is_synced` INTEGER NOT NULL, `sync_date` INTEGER, PRIMARY KEY (`id`))',
    );

    // 3. Migrate data while casting IDs to STRING as needed
    await database.execute(
      'INSERT INTO customers (id, name, phone, email, lastVisit, gender, address, imagePath, profileImageUrl, createdDate, syncDate, isSynced) '
      'SELECT CAST(id AS TEXT), name, phone, email, lastVisit, gender, address, imagePath, profileImageUrl, createdDate, syncDate, isSynced FROM customers_old',
    );

    await database.execute(
      'INSERT INTO measurements (id, customerId, name, measurementValues, createdDate, updatedDate, syncDate, isSynced) '
      'SELECT CAST(id AS TEXT), CAST(customerId AS TEXT), name, measurementValues, createdDate, updatedDate, syncDate, isSynced FROM measurements_old',
    );

    await database.execute(
      'INSERT INTO orders (id, title, customerId, status, paymentStatus, paymentAmount, dueDate, notes, createdDate, orderNumber, subtotal, total, tax, expectedDeliveryDate, syncDate, isSynced) '
      'SELECT CAST(id AS TEXT), title, CAST(customerId AS TEXT), status, paymentStatus, paymentAmount, dueDate, notes, createdDate, orderNumber, subtotal, total, tax, expectedDeliveryDate, syncDate, isSynced FROM orders_old',
    );

    await database.execute(
      'INSERT INTO invoices (id, customerId, companyId, status, createdDate, updatedDate, invoiceNumber, issueDate, dueDate, notes, terms, subtotal, tax, total, projectId, syncDate, isSynced, title, date, orderId) '
      'SELECT CAST(id AS TEXT), CAST(customerId AS TEXT), companyId, status, createdDate, updatedDate, invoiceNumber, issueDate, dueDate, notes, terms, subtotal, tax, total, projectId, syncDate, isSynced, title, date, CAST(orderId AS TEXT) FROM invoices_old',
    );

    await database.execute(
      'INSERT INTO order_items (id, orderId, productName, productDescription, quantity, unitPrice, taxRate, amount, syncDate, isSynced) '
      'SELECT CAST(id AS TEXT), CAST(orderId AS TEXT), productName, productDescription, quantity, unitPrice, taxRate, amount, syncDate, isSynced FROM order_items_old',
    );

    await database.execute(
      'INSERT INTO invoice_items (id, invoiceId, description, quantity, unitPrice, taxRate, amount, syncDate, isSynced) '
      'SELECT CAST(id AS TEXT), CAST(invoiceId AS TEXT), description, quantity, unitPrice, taxRate, amount, syncDate, isSynced FROM invoice_items_old',
    );

    await database.execute(
      'INSERT INTO payments (id, invoiceId, companyId, amount, paymentDate, referenceNumber, notes, status, syncDate, isSynced) '
      'SELECT CAST(id AS TEXT), CAST(invoiceId AS TEXT), companyId, amount, paymentDate, referenceNumber, notes, status, syncDate, isSynced FROM payments_old',
    );

    await database.execute(
      'INSERT INTO projects (id, company_id, client_id, title, description, status, start_date, deadline, completed_date, budget, spent, created_at, updated_at, is_synced, sync_date) '
      'SELECT CAST(id AS TEXT), company_id, CAST(client_id AS TEXT), title, description, status, start_date, deadline, completed_date, budget, spent, created_at, updated_at, is_synced, sync_date FROM projects_old',
    );

    // 4. Drop old tables (in reverse order of dependency)
    await database.execute('DROP TABLE IF EXISTS projects_old');
    await database.execute('DROP TABLE IF EXISTS payments_old');
    await database.execute('DROP TABLE IF EXISTS invoice_items_old');
    await database.execute('DROP TABLE IF EXISTS order_items_old');
    await database.execute('DROP TABLE IF EXISTS measurements_old');
    await database.execute('DROP TABLE IF EXISTS invoices_old');
    await database.execute('DROP TABLE IF EXISTS orders_old');
    await database.execute('DROP TABLE IF EXISTS customers_old');
  });

  final db =
      await $FloorAppDatabase
          .databaseBuilder('app_database')
          .addMigrations([
            migration1to2,
            migration2to3,
            migration3to4,
            migration4to5,
          ])
          .addCallback(
            Callback(
              onConfigure: (database) async {
                // Disable foreign keys during migration/open to allow dropping/recreating tables
                await database.execute('PRAGMA foreign_keys = OFF');
              },
              onOpen: (database) async {
                // Re-enable foreign keys after migrations are done
                await database.execute('PRAGMA foreign_keys = ON');
              },
            ),
          )
          .build();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()..init(db)),
        ChangeNotifierProvider(create: (_) => ApiProvider()),
        ChangeNotifierProvider(
          create:
              (_) => MeasurementProvider(
                measurementDao: db.measurementDao,
                customerDao: db.customerDao,
              ),
        ),
        ChangeNotifierProvider(
          create: (context) => OrderProvider(orderDao: db.orderDao),
        ),
        ChangeNotifierProvider(
          create:
              (context) => CustomerProvider(
                customerDao: db.customerDao,
                orderDao: db.orderDao,
              ),
        ),
        ChangeNotifierProvider(
          create: (context) => InvoiceProvider(invoiceDao: db.invoiceDao),
        ),
        ChangeNotifierProvider(
          create: (context) => CompanyProvider(companyDao: db.companyDao),
        ),
        ChangeNotifierProvider(
          create:
              (context) => DashBoardProvider(
                orderDao: db.orderDao,
                customerDao: db.customerDao,
              ),
        ),
        ChangeNotifierProvider(create: (context) => NotificationProvider()),
      ],
      child: const IndexPage(),
    ),
  );

  FlutterNativeSplash.remove();
}
