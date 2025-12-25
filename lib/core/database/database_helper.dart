import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static Database? _db;
  static final DatabaseHelper instance = DatabaseHelper._internal();

  DatabaseHelper._internal();

  factory DatabaseHelper() => instance;

  Future<Database> get db async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), "saveit_app.db");
    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE expenses (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            firestoreId TEXT,
            title TEXT NOT NULL,
            amount REAL NOT NULL,
            category TEXT,
            date TEXT NOT NULL,
            description TEXT,
            isSynced INTEGER DEFAULT 0,
            createdAt TEXT NOT NULL,
            updatedAt TEXT
          )
        """);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE expenses ADD COLUMN firestoreId TEXT');
          await db.execute('ALTER TABLE expenses ADD COLUMN updatedAt TEXT');
        }
      },
    );
  }

  // Add expense
  Future<int> addExpense(Map<String, dynamic> expense) async {
    var database = await db;
    // Remove null id to let SQLite auto-generate
    final data = Map<String, dynamic>.from(expense);
    data.remove('id');
    return await database.insert("expenses", data);
  }

  // Get all expenses
  Future<List<Map<String, dynamic>>> getExpenses() async {
    var database = await db;
    return await database.query("expenses", orderBy: "date DESC");
  }

  // Get expense by ID
  Future<Map<String, dynamic>?> getExpenseById(int id) async {
    var database = await db;
    final results = await database.query(
      "expenses",
      where: "id = ?",
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  // Update expense
  Future<int> updateExpense(int id, Map<String, dynamic> expense) async {
    var database = await db;
    return await database.update(
      "expenses",
      expense,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // Delete expense
  Future<int> deleteExpense(int id) async {
    var database = await db;
    return await database.delete("expenses", where: "id = ?", whereArgs: [id]);
  }

  // Clear all data
  Future<void> clearAllData() async {
    var database = await db;
    await database.delete("expenses");
  }

  // Get unsynced expenses - جلب المصاريف غير المتزامنة
  Future<List<Map<String, dynamic>>> getUnsyncedExpenses() async {
    var database = await db;
    return await database.query(
      "expenses",
      where: "isSynced = ?",
      whereArgs: [0],
    );
  }

  // Mark expense as synced - تعليم مصروف كمتزامن
  Future<int> markExpenseAsSynced(int id, {String? firestoreId}) async {
    var database = await db;
    final data = <String, dynamic>{"isSynced": 1};
    if (firestoreId != null) {
      data["firestoreId"] = firestoreId;
    }
    return await database.update(
      "expenses",
      data,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  // Get expenses by category
  Future<List<Map<String, dynamic>>> getExpensesByCategory(
      String category) async {
    var database = await db;
    return await database.query(
      "expenses",
      where: "category = ?",
      whereArgs: [category],
      orderBy: "date DESC",
    );
  }

  // Get expenses by date range
  Future<List<Map<String, dynamic>>> getExpensesByDateRange(
    String startDate,
    String endDate,
  ) async {
    var database = await db;
    return await database.query(
      "expenses",
      where: "date >= ? AND date <= ?",
      whereArgs: [startDate, endDate],
      orderBy: "date DESC",
    );
  }

  // Get total amount
  Future<double> getTotalAmount() async {
    var database = await db;
    final result = await database.rawQuery(
      'SELECT SUM(amount) as total FROM expenses',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  // Get total by category
  Future<List<Map<String, dynamic>>> getTotalByCategory() async {
    var database = await db;
    return await database.rawQuery('''
      SELECT category, SUM(amount) as total, COUNT(*) as count
      FROM expenses
      GROUP BY category
      ORDER BY total DESC
    ''');
  }

  // Get expense count
  Future<int> getExpenseCount() async {
    var database = await db;
    final result = await database.rawQuery(
      'SELECT COUNT(*) as count FROM expenses',
    );
    return (result.first['count'] as int?) ?? 0;
  }
}
