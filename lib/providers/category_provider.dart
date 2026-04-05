import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_constants.dart';
import '../core/database/database_helper.dart';
import '../models/models.dart';

class CategoryProvider extends ChangeNotifier {
  final _db = DatabaseHelper();
  List<CategoryModel> _categories = [];

  List<CategoryModel> get categories => _categories;
  List<CategoryModel> get expenseCategories =>
      _categories.where((c) => c.type == 'expense').toList();
  List<CategoryModel> get incomeCategories =>
      _categories.where((c) => c.type == 'income').toList();

  CategoryModel? findById(String id) {
    try { return _categories.firstWhere((c) => c.id == id); }
    catch (_) { return null; }
  }

  Future<void> loadCategories() async {
    final count = await _db.categoryCount();
    if (count == 0) await _insertDefaults();
    final rows = await _db.getAllCategories();
    _categories = rows.map((r) => CategoryModel.fromMap(r)).toList();
    notifyListeners();
  }

  Future<void> _insertDefaults() async {
    final uuid = const Uuid();
    for (final cat in AppConstants.defaultExpenseCategories) {
      await _db.insertCategory(CategoryModel(
        id: uuid.v4(),
        name: cat['name'],
        type: 'expense',
        color: cat['color'],
        emoji: cat['emoji'],
        isDefault: true,
      ).toMap());
    }
    for (final cat in AppConstants.defaultIncomeCategories) {
      await _db.insertCategory(CategoryModel(
        id: uuid.v4(),
        name: cat['name'],
        type: 'income',
        color: cat['color'],
        emoji: cat['emoji'],
        isDefault: true,
      ).toMap());
    }
  }

  Future<void> addCategory(CategoryModel cat) async {
    await _db.insertCategory(cat.toMap());
    await loadCategories();
  }

  Future<void> updateCategory(CategoryModel cat) async {
    await _db.updateCategory(cat.toMap());
    await loadCategories();
  }

  Future<void> deleteCategory(String id) async {
    await _db.deleteCategory(id);
    await loadCategories();
  }
}
