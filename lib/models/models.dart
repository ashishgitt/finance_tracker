import 'package:flutter/material.dart';

// ─── Category ─────────────────────────────────────────────────────────────────
class CategoryModel {
  final String id;
  final String name;
  final String type; // 'income' | 'expense'
  final int color;
  final String emoji;
  final bool isDefault;
  final bool isDeleted;

  CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.color,
    required this.emoji,
    this.isDefault = false,
    this.isDeleted = false,
  });

  Color get colorValue => Color(color);

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'color': color,
        'emoji': emoji,
        'is_default': isDefault ? 1 : 0,
        'is_deleted': isDeleted ? 1 : 0,
      };

  factory CategoryModel.fromMap(Map<String, dynamic> m) => CategoryModel(
        id: m['id'],
        name: m['name'],
        type: m['type'],
        color: m['color'] as int,
        emoji: m['emoji'],
        isDefault: (m['is_default'] ?? 0) == 1,
        isDeleted: (m['is_deleted'] ?? 0) == 1,
      );

  CategoryModel copyWith({
    String? id, String? name, String? type, int? color, String? emoji,
    bool? isDefault, bool? isDeleted,
  }) =>
      CategoryModel(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        color: color ?? this.color,
        emoji: emoji ?? this.emoji,
        isDefault: isDefault ?? this.isDefault,
        isDeleted: isDeleted ?? this.isDeleted,
      );
}

// ─── Budget ───────────────────────────────────────────────────────────────────
class BudgetModel {
  final String id;
  final String? categoryId; // null = overall monthly budget
  final double amount;
  final int month;
  final int year;

  BudgetModel({
    required this.id,
    this.categoryId,
    required this.amount,
    required this.month,
    required this.year,
  });

  bool get isOverall => categoryId == null;

  Map<String, dynamic> toMap() => {
        'id': id,
        'category_id': categoryId,
        'amount': amount,
        'month': month,
        'year': year,
      };

  factory BudgetModel.fromMap(Map<String, dynamic> m) => BudgetModel(
        id: m['id'],
        categoryId: m['category_id'],
        amount: (m['amount'] as num).toDouble(),
        month: m['month'] as int,
        year: m['year'] as int,
      );

  BudgetModel copyWith({String? id, String? categoryId, double? amount, int? month, int? year}) =>
      BudgetModel(
        id: id ?? this.id,
        categoryId: categoryId ?? this.categoryId,
        amount: amount ?? this.amount,
        month: month ?? this.month,
        year: year ?? this.year,
      );
}

// ─── Savings Goal ─────────────────────────────────────────────────────────────
class SavingsGoalModel {
  final String id;
  final String title;
  final double targetAmount;
  final double savedAmount;
  final String? deadline;
  final String createdAt;
  final bool isCompleted;

  SavingsGoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    this.savedAmount = 0,
    this.deadline,
    required this.createdAt,
    this.isCompleted = false,
  });

  double get progressPercent =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0;

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'target_amount': targetAmount,
        'saved_amount': savedAmount,
        'deadline': deadline,
        'created_at': createdAt,
        'is_completed': isCompleted ? 1 : 0,
      };

  factory SavingsGoalModel.fromMap(Map<String, dynamic> m) => SavingsGoalModel(
        id: m['id'],
        title: m['title'],
        targetAmount: (m['target_amount'] as num).toDouble(),
        savedAmount: (m['saved_amount'] as num).toDouble(),
        deadline: m['deadline'],
        createdAt: m['created_at'],
        isCompleted: (m['is_completed'] ?? 0) == 1,
      );

  SavingsGoalModel copyWith({
    String? id, String? title, double? targetAmount, double? savedAmount,
    String? deadline, String? createdAt, bool? isCompleted,
  }) =>
      SavingsGoalModel(
        id: id ?? this.id,
        title: title ?? this.title,
        targetAmount: targetAmount ?? this.targetAmount,
        savedAmount: savedAmount ?? this.savedAmount,
        deadline: deadline ?? this.deadline,
        createdAt: createdAt ?? this.createdAt,
        isCompleted: isCompleted ?? this.isCompleted,
      );
}

// ─── Debt ─────────────────────────────────────────────────────────────────────
class DebtModel {
  final String id;
  final String personName;
  final double amount;
  final String type; // 'owe' | 'owed'
  final String? note;
  final String? dueDate;
  final bool isSettled;
  final String createdAt;

  DebtModel({
    required this.id,
    required this.personName,
    required this.amount,
    required this.type,
    this.note,
    this.dueDate,
    this.isSettled = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'person_name': personName,
        'amount': amount,
        'type': type,
        'note': note,
        'due_date': dueDate,
        'is_settled': isSettled ? 1 : 0,
        'created_at': createdAt,
      };

  factory DebtModel.fromMap(Map<String, dynamic> m) => DebtModel(
        id: m['id'],
        personName: m['person_name'],
        amount: (m['amount'] as num).toDouble(),
        type: m['type'],
        note: m['note'],
        dueDate: m['due_date'],
        isSettled: (m['is_settled'] ?? 0) == 1,
        createdAt: m['created_at'],
      );

  DebtModel copyWith({
    String? id, String? personName, double? amount, String? type,
    String? note, String? dueDate, bool? isSettled, String? createdAt,
  }) =>
      DebtModel(
        id: id ?? this.id,
        personName: personName ?? this.personName,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        note: note ?? this.note,
        dueDate: dueDate ?? this.dueDate,
        isSettled: isSettled ?? this.isSettled,
        createdAt: createdAt ?? this.createdAt,
      );
}
