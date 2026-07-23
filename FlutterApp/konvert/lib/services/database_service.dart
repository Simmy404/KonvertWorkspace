// lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  DatabaseService._internal();
  static final DatabaseService instance = DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('HawkEye.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 4,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE bricks (
        brick_id INTEGER PRIMARY KEY,
        brick_name TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        customer_id INTEGER PRIMARY KEY,
        customer_type TEXT NOT NULL,
        customer_name TEXT NOT NULL,
        customer_brickid TEXT,
        customer_address TEXT,
        customer_city TEXT,
        customer_cperson TEXT,
        customer_phone TEXT,
        customer_licno TEXT,
        customer_lexdtd TEXT,
        customer_lcatg TEXT,
        customer_ntnno TEXT,
        customer_staxno TEXT,
        customer_lat TEXT,
        customer_long TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        product_vendid INTEGER,
        product_grpid INTEGER,
        product_id INTEGER PRIMARY KEY,
        product_name TEXT NOT NULL,
        product_packsize TEXT,
        product_maxper TEXT,
        product_gstper TEXT,
        product_staxper TEXT,
        product_is_otc TEXT,
        product_is_sch_g TEXT,
        product_retail TEXT,
        product_tp TEXT
      )
    ''');

    // Booking Table implementation ready for future use
    await db.execute('''
      CREATE TABLE bookings (
        booking_invoice INTEGER,
        booking_brikid INTEGER,
        booking_custid INTEGER,
        booking_prodid INTEGER,
        booking_qty INTEGER,
        booking_bonus DECIMAL(10,2),
        booking_discount DECIMAL(10,2),
        booking_price DECIMAL(10,2),
        booking_long DECIMAL(10,6),
        booking_lat DECIMAL(10,6),
        booking_date DATE,
        booking_time TIME,
        booking_grand_total DECIMAL(10,3),
        booking_prod_count INTEGER,
        booking_remarks TEXT
      )
    ''');
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    await db.execute("DROP TABLE IF EXISTS bricks");
    await db.execute("DROP TABLE IF EXISTS customers");
    await db.execute("DROP TABLE IF EXISTS products");
    await db.execute("DROP TABLE IF EXISTS bookings");
    await _createDB(db, newVersion);
  }

  // --- BATCH INSERTERS FOR SYNC ---

  Future<void> syncBricks(List<dynamic> brickList) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('bricks'); // Clear old data
      final batch = txn.batch();
      for (var json in brickList) {
        if (json is Map) {
          batch.insert('bricks', {
            'brick_id': int.tryParse(json['brik_id']?.toString() ?? '') ?? json['brik_id'],
            'brick_name': json['brik_name']?.toString() ?? '',
          });
        }
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> syncCustomers(List<dynamic> customerList) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('customers');
      final batch = txn.batch();
      for (var json in customerList) {
        if (json is Map) {
          batch.insert('customers', {
            'customer_id': int.tryParse(json['cust_id']?.toString() ?? '') ?? json['cust_id'],
            'customer_type': json['cust_type']?.toString() ?? '',
            'customer_name': json['cust_name']?.toString() ?? '',
            'customer_brickid': json['cust_brikid']?.toString() ?? '',
            'customer_address': json['cust_address']?.toString() ?? '',
            'customer_city': json['cust_city']?.toString() ?? '',
            'customer_cperson': json['cust_cperson']?.toString() ?? '',
            'customer_phone': json['cust_phone']?.toString() ?? '',
            'customer_licno': json['cust_licno']?.toString() ?? '',
            'customer_lexdtd': json['cust_lexdtd']?.toString() ?? '',
            'customer_lcatg': json['cust_lcatg']?.toString() ?? '',
            'customer_ntnno': json['cust_ntnno']?.toString() ?? '',
            'customer_staxno': json['cust_staxno']?.toString() ?? '',
            'customer_lat': json['cust_lat']?.toString() ?? '',
            'customer_long': json['cust_long']?.toString() ?? '',
          });
        }
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> syncProducts(List<dynamic> productList) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      await txn.delete('products');
      final batch = txn.batch();
      for (var json in productList) {
        if (json is Map) {
          batch.insert('products', {
            'product_vendid': int.tryParse(json['prod_vendid']?.toString() ?? '') ?? json['prod_vendid'],
            'product_grpid': int.tryParse(json['prod_grpid']?.toString() ?? '') ?? json['prod_grpid'],
            'product_id': int.tryParse(json['prod_id']?.toString() ?? '') ?? json['prod_id'],
            'product_name': json['prod_name']?.toString() ?? '',
            'product_packsize': json['prod_packsize']?.toString() ?? '',
            'product_maxper': json['prod_maxper']?.toString() ?? '',
            'product_gstper': json['prod_gstper']?.toString() ?? '',
            'product_staxper': json['prod_staxper']?.toString() ?? '',
            'product_is_otc': json['prod_is_otc']?.toString() ?? '',
            'product_is_sch_g': json['prod_is_sch_g']?.toString() ?? '',
            'product_retail': json['prod_retail']?.toString() ?? '',
            'product_tp': json['prod_tp']?.toString() ?? '',
          });
        }
      }
      await batch.commit(noResult: true);
    });
  }

  Future<void> syncDoctors(List<dynamic> doctorList) async {
    final db = await instance.database;
    await db.transaction((txn) async {
      final batch = txn.batch();
      for (var json in doctorList) {
        if (json is Map) {
          batch.insert(
            'customers',
            {
              'customer_id': int.tryParse(json['cust_id']?.toString() ?? json['doc_id']?.toString() ?? '') ?? json['cust_id'],
              'customer_type': json['cust_type']?.toString() ?? 'Doctor',
              'customer_name': json['cust_name']?.toString() ?? json['doc_name']?.toString() ?? '',
              'customer_brickid': json['cust_brikid']?.toString() ?? json['doc_brikid']?.toString() ?? '',
              'customer_address': json['cust_address']?.toString() ?? json['doc_address']?.toString() ?? '',
              'customer_city': json['cust_city']?.toString() ?? json['doc_city']?.toString() ?? '',
              'customer_cperson': json['cust_cperson']?.toString() ?? json['doc_cperson']?.toString() ?? '',
              'customer_phone': json['cust_phone']?.toString() ?? json['doc_phone']?.toString() ?? '',
              'customer_licno': json['cust_licno']?.toString() ?? '',
              'customer_lexdtd': json['cust_lexdtd']?.toString() ?? '',
              'customer_lcatg': json['cust_lcatg']?.toString() ?? '',
              'customer_ntnno': json['cust_ntnno']?.toString() ?? '',
              'customer_staxno': json['cust_staxno']?.toString() ?? '',
              'customer_lat': json['cust_lat']?.toString() ?? '',
              'customer_long': json['cust_long']?.toString() ?? '',
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      }
      await batch.commit(noResult: true);
    });
  }

  // --- QUERY & COUNT HELPERS ---

  Future<int> getBricksCount() async {
    final db = await instance.database;
    final result = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM bricks'));
    return result ?? 0;
  }

  Future<int> getProductsCount() async {
    final db = await instance.database;
    final result = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM products'));
    return result ?? 0;
  }

  Future<int> getChemistsCount() async {
    final db = await instance.database;
    final result = Sqflite.firstIntValue(await db.rawQuery(
      "SELECT COUNT(*) FROM customers WHERE LOWER(customer_type) LIKE '%chemist%' OR LOWER(customer_type) = 'c' OR customer_type = '1'"
    ));
    final count = result ?? 0;
    if (count == 0) {
      final total = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM customers'));
      return total ?? 0;
    }
    return count;
  }

  Future<int> getDoctorsCount() async {
    final db = await instance.database;
    final result = Sqflite.firstIntValue(await db.rawQuery(
      "SELECT COUNT(*) FROM customers WHERE LOWER(customer_type) LIKE '%doctor%' OR LOWER(customer_type) = 'd' OR customer_type = '2'"
    ));
    return result ?? 0;
  }
}