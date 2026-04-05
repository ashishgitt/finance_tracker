import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'myfinance.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category_id TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        payment_mode TEXT DEFAULT 'Cash',
        is_recurring INTEGER DEFAULT 0,
        recurrence_type TEXT,
        receipt_image TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        color INTEGER NOT NULL,
        emoji TEXT NOT NULL,
        is_default INTEGER DEFAULT 0,
        is_deleted INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        category_id TEXT,
        amount REAL NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE savings_goals (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        target_amount REAL NOT NULL,
        saved_amount REAL DEFAULT 0,
        deadline TEXT,
        created_at TEXT NOT NULL,
        is_completed INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE debts (
        id TEXT PRIMARY KEY,
        person_name TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        note TEXT,
        due_date TEXT,
        is_settled INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');
  }

  // ─── Transactions ─────────────────────────────────────────────
  Future<int> insertTransaction(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert('transactions', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateTransaction(Map<String, dynamic> row) async {
    final db = await database;
    return db.update('transactions', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllTransactions() async {
    final db = await database;
    return db.query('transactions', orderBy: 'date DESC, created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getTransactionsByMonth(int month, int year) async {
    final db = await database;
    final start = '$year-${month.toString().padLeft(2, '0')}-01';
    final end = '$year-${month.toString().padLeft(2, '0')}-31';
    return db.query('transactions',
        where: 'date >= ? AND date <= ?',
        whereArgs: [start, end],
        orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getTransactionsByDateRange(
      String start, String end) async {
    final db = await database;
    return db.query('transactions',
        where: 'date >= ? AND date <= ?',
        whereArgs: [start, end],
        orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> searchTransactions(String query) async {
    final db = await database;
    return db.query('transactions',
        where: 'note LIKE ? OR amount LIKE ?',
        whereArgs: ['%$query%', '%$query%'],
        orderBy: 'date DESC');
  }

  Future<List<Map<String, dynamic>>> getTransactionsByDate(String date) async {
    final db = await database;
    return db.query('transactions',
        where: 'date = ?', whereArgs: [date], orderBy: 'created_at DESC');
  }

  // ─── Categories ───────────────────────────────────────────────
  Future<int> insertCategory(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert('categories', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateCategory(Map<String, dynamic> row) async {
    final db = await database;
    return db.update('categories', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deleteCategory(String id) async {
    final db = await database;
    return db.update('categories', {'is_deleted': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return db.query('categories', where: 'is_deleted = 0');
  }

  Future<int> categoryCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as cnt FROM categories WHERE is_deleted=0');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // ─── Budgets ──────────────────────────────────────────────────
  Future<int> insertOrUpdateBudget(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert('budgets', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteBudget(String id) async {
    final db = await database;
    return db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getBudgetsForMonth(int month, int year) async {
    final db = await database;
    return db.query('budgets',
        where: 'month = ? AND year = ?', whereArgs: [month, year]);
  }

  // ─── Savings Goals ────────────────────────────────────────────
  Future<int> insertSavingsGoal(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert('savings_goals', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateSavingsGoal(Map<String, dynamic> row) async {
    final db = await database;
    return db.update('savings_goals', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deleteSavingsGoal(String id) async {
    final db = await database;
    return db.delete('savings_goals', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllSavingsGoals() async {
    final db = await database;
    return db.query('savings_goals', orderBy: 'created_at DESC');
  }

  // ─── Debts ────────────────────────────────────────────────────
  Future<int> insertDebt(Map<String, dynamic> row) async {
    final db = await database;
    return db.insert('debts', row, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateDebt(Map<String, dynamic> row) async {
    final db = await database;
    return db.update('debts', row, where: 'id = ?', whereArgs: [row['id']]);
  }

  Future<int> deleteDebt(String id) async {
    final db = await database;
    return db.delete('debts', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getAllDebts() async {
    final db = await database;
    return db.query('debts', orderBy: 'created_at DESC');
  }
}
