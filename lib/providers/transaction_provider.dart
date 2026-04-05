import 'package:flutter/material.dart';
import '../core/database/database_helper.dart';
import '../models/transaction_model.dart';

class TransactionProvider extends ChangeNotifier {
  final _db = DatabaseHelper();
  List<TransactionModel> _all = [];
  List<TransactionModel> _filtered = [];
  bool _isLoading = false;

  List<TransactionModel> get all => _all;
  List<TransactionModel> get filtered => _filtered;
  bool get isLoading => _isLoading;

  // ─── CRUD ─────────────────────────────────────────────────────
  Future<void> loadAll() async {
    _isLoading = true;
    notifyListeners();
    final rows = await _db.getAllTransactions();
    _all = rows.map((r) => TransactionModel.fromMap(r)).toList();
    _filtered = List.from(_all);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(TransactionModel t) async {
    await _db.insertTransaction(t.toMap());
    await loadAll();
  }

  Future<void> updateTransaction(TransactionModel t) async {
    await _db.updateTransaction(t.toMap());
    await loadAll();
  }

  Future<void> deleteTransaction(String id) async {
    await _db.deleteTransaction(id);
    await loadAll();
  }

  // ─── Monthly data ─────────────────────────────────────────────
  Future<List<TransactionModel>> getByMonth(int month, int year) async {
    final rows = await _db.getTransactionsByMonth(month, year);
    return rows.map((r) => TransactionModel.fromMap(r)).toList();
  }

  Future<List<TransactionModel>> getByDateRange(DateTime start, DateTime end) async {
    final s = '${start.year}-${start.month.toString().padLeft(2,'0')}-${start.day.toString().padLeft(2,'0')}';
    final e = '${end.year}-${end.month.toString().padLeft(2,'0')}-${end.day.toString().padLeft(2,'0')}';
    final rows = await _db.getTransactionsByDateRange(s, e);
    return rows.map((r) => TransactionModel.fromMap(r)).toList();
  }

  Future<List<TransactionModel>> getByDate(DateTime date) async {
    final d = '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
    final rows = await _db.getTransactionsByDate(d);
    return rows.map((r) => TransactionModel.fromMap(r)).toList();
  }

  // ─── Search ───────────────────────────────────────────────────
  Future<List<TransactionModel>> search(String query) async {
    final rows = await _db.searchTransactions(query);
    return rows.map((r) => TransactionModel.fromMap(r)).toList();
  }

  // ─── Filter (in-memory) ───────────────────────────────────────
  void applyFilter({
    String? type,
    String? categoryId,
    String? paymentMode,
    double? minAmount,
    double? maxAmount,
    DateTime? fromDate,
    DateTime? toDate,
    String? query,
  }) {
    _filtered = _all.where((t) {
      if (type != null && type.isNotEmpty && t.type != type) return false;
      if (categoryId != null && categoryId.isNotEmpty && t.categoryId != categoryId) return false;
      if (paymentMode != null && paymentMode.isNotEmpty && t.paymentMode != paymentMode) return false;
      if (minAmount != null && t.amount < minAmount) return false;
      if (maxAmount != null && t.amount > maxAmount) return false;
      if (fromDate != null && t.date.compareTo(
              '${fromDate.year}-${fromDate.month.toString().padLeft(2,'0')}-${fromDate.day.toString().padLeft(2,'0')}') < 0)
        return false;
      if (toDate != null && t.date.compareTo(
              '${toDate.year}-${toDate.month.toString().padLeft(2,'0')}-${toDate.day.toString().padLeft(2,'0')}') > 0)
        return false;
      if (query != null && query.isNotEmpty) {
        final q = query.toLowerCase();
        if (!(t.note?.toLowerCase().contains(q) ?? false) &&
            !t.amount.toString().contains(q)) return false;
      }
      return true;
    }).toList();
    notifyListeners();
  }

  void clearFilter() {
    _filtered = List.from(_all);
    notifyListeners();
  }

  // ─── Analytics Helpers ────────────────────────────────────────
  double totalIncome(List<TransactionModel> txns) =>
      txns.where((t) => t.type == 'income').fold(0, (s, t) => s + t.amount);

  double totalExpense(List<TransactionModel> txns) =>
      txns.where((t) => t.type == 'expense').fold(0, (s, t) => s + t.amount);

  Map<String, double> categoryBreakdown(List<TransactionModel> txns, String type) {
    final Map<String, double> map = {};
    for (final t in txns.where((t) => t.type == type)) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    return map;
  }

  Map<String, double> dailyBreakdown(List<TransactionModel> txns, String type) {
    final Map<String, double> map = {};
    for (final t in txns.where((t) => t.type == type)) {
      map[t.date] = (map[t.date] ?? 0) + t.amount;
    }
    return map;
  }

  // Recent transactions (last 10)
  List<TransactionModel> get recentTransactions => _all.take(10).toList();

  // Today's total expense
  double todayExpense() {
    final today = DateTime.now();
    final d = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
    return _all.where((t) => t.date == d && t.type == 'expense').fold(0, (s, t) => s + t.amount);
  }

  // This month totals
  double thisMonthIncome() {
    final now = DateTime.now();
    final txns = _all.where((t) {
      return t.date.startsWith('${now.year}-${now.month.toString().padLeft(2,'0')}') &&
          t.type == 'income';
    });
    return txns.fold(0, (s, t) => s + t.amount);
  }

  double thisMonthExpense() {
    final now = DateTime.now();
    final txns = _all.where((t) {
      return t.date.startsWith('${now.year}-${now.month.toString().padLeft(2,'0')}') &&
          t.type == 'expense';
    });
    return txns.fold(0, (s, t) => s + t.amount);
  }
}
