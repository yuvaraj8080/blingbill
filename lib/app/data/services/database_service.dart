import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/bill_item_model.dart';
import '../models/bill_model.dart';
import '../models/product_model.dart';

class DatabaseService extends GetxService {
  static DatabaseService get to => Get.find();

  Database? _database;

  // Database version
  final int _version = 7;

  // Table names
  final String _productTable = 'products';
  final String _billTable = 'bills';
  final String _billItemTable = 'bill_Items';

  // Initialize database
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  // Initialize database
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'blingbill.db');

    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade, // Added upgrade handler
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < _version) {
      try {
        await db.execute('ALTER TABLE bills ADD COLUMN totalAmount REAL');
      } catch (e) {
        debugPrint('Error upgrading database: $e');
      }
      await _onCreate(db, _version);
    }
  }

  // Create tables
  Future<void> _onCreate(Database db, int version) async {
    // Product Table
    await db.execute('''
      CREATE TABLE $_productTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        description TEXT,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        imagePath TEXT,
        stock INTEGER DEFAULT 0,
        discount REAL DEFAULT 0,
        tax REAL DEFAULT 0,
        createdAt TEXT
      )
    ''');

    // Bills table 
    await db.execute('''
      CREATE TABLE $_billTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerName TEXT NOT NULL,
        date INTEGER NOT NULL,
        subTotal REAL NOT NULL,
        discount REAL NOT NULL,
        discountAmount REAL NOT NULL,
        tax REAL NOT NULL,
        taxAmount REAL NOT NULL,
        totalAmount REAL NOT NULL,
        paymentMethod TEXT
      )
    ''');

    // BillItems table
    await db.execute('''
      CREATE TABLE $_billItemTable (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        billId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        productName TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        discount REAL,
        tax REAL,
        totalAmount REAL NOT NULL,
        FOREIGN KEY (billId) REFERENCES $_billTable(id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES $_productTable(id) ON DELETE RESTRICT
      )
    ''');
  }

  // Product CRUD operations
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<Product?> getProduct(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Product.fromMap(maps.first);
    }

    return null;
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products', where: 'category = ?', whereArgs: [category]);

    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update('products', product.toMap(), where: 'id = ?', whereArgs: [product.id]);
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // Bill CRUD operations
  Future<int> insertBill(Bill bill) async {
    final db = await database;
    int billId = 0;

    try {
      await db.transaction((txn) async {
        // Insert bill
        billId = await txn.insert(_billTable, bill.toMapForDb(), conflictAlgorithm: ConflictAlgorithm.replace);

        // Insert all bill items
        for (final item in bill.items) {
          await txn.insert(
            _billItemTable,
            item.copyWith(billId: billId).toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      return billId;
    } catch (e) {
      Get.snackbar('Database Error', 'Failed to save bill: ${e.toString()}', snackPosition: SnackPosition.BOTTOM);
      return 0;
    }
  }

  Future<List<Bill>> getAllBills() async {
    final db = await database;
    final List<Map<String, dynamic>> billMaps = await db.query('bills', orderBy: 'date DESC');

    List<Bill> bills = [];

    for (var billMap in billMaps) {
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'bill_Items',
        where: 'billId = ?',
        whereArgs: [billMap['id']],
      );

      final List<BillItem> items = List.generate(itemMaps.length, (i) => BillItem.fromMap(itemMaps[i]));

      bills.add(Bill.fromMap(billMap, items));
    }

    return bills;
  }

  Future<Bill?> getBill(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> billMaps = await db.query('bills', where: 'id = ?', whereArgs: [id]);

    if (billMaps.isEmpty) {
      return null;
    }

    final List<Map<String, dynamic>> itemMaps = await db.query('bill_Items', where: 'billId = ?', whereArgs: [id]);

    final List<BillItem> items = List.generate(itemMaps.length, (i) => BillItem.fromMap(itemMaps[i]));

    return Bill.fromMap(billMaps.first, items);
  }

  Future<List<Bill>> searchBills(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> billMaps = await db.query(
      'bills',
      where: 'customerName LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'date DESC',
    );

    List<Bill> bills = [];

    for (var billMap in billMaps) {
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'bill_Items',
        where: 'billId = ?',
        whereArgs: [billMap['id']],
      );

      final List<BillItem> items = List.generate(itemMaps.length, (i) => BillItem.fromMap(itemMaps[i]));

      bills.add(Bill.fromMap(billMap, items));
    }

    return bills;
  }

  Future<List<Bill>> getBillsByDateRange(DateTime start, DateTime end) async {
    final db = await database;
    final List<Map<String, dynamic>> billMaps = await db.query(
      'bills',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
      orderBy: 'date DESC',
    );

    List<Bill> bills = [];

    for (var billMap in billMaps) {
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'bill_Items',
        where: 'billId = ?',
        whereArgs: [billMap['id']],
      );

      final List<BillItem> items = List.generate(itemMaps.length, (i) => BillItem.fromMap(itemMaps[i]));

      bills.add(Bill.fromMap(billMap, items));
    }

    return bills;
  }

  Future<int> deleteBill(int id) async {
    final db = await database;
    return await db.delete('bills', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> updateBill(Bill bill) async {
    int result = 0;
    final db = await database;

    await db.transaction((txn) async {
      // Update bill
      result = await txn.update('bills', bill.toMapForDb(), where: 'id = ?', whereArgs: [bill.id]);

      // Delete existing bill items
      await txn.delete('bill_Items', where: 'billId = ?', whereArgs: [bill.id]);

      // Insert updated bill items
      for (var item in bill.items) {
        await txn.insert('bill_Items', item.copyWith(billId: bill.id).toMap());
      }
    });

    return result;
  }

  Future<List<Bill>> getRecentBills({int limit = 5}) async {
    final db = await database;
    final List<Map<String, dynamic>> billMaps = await db.query('bills', orderBy: 'date DESC', limit: limit);

    List<Bill> bills = [];

    for (var billMap in billMaps) {
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'bill_Items',
        where: 'billId = ?',
        whereArgs: [billMap['id']],
      );

      final List<BillItem> items = List.generate(itemMaps.length, (i) => BillItem.fromMap(itemMaps[i]));

      bills.add(Bill.fromMap(billMap, items));
    }

    return bills;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
