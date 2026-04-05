class TransactionModel {
  final String id;
  final double amount;
  final String type; // 'income' | 'expense'
  final String categoryId;
  final String date; // yyyy-MM-dd
  final String? note;
  final String paymentMode;
  final bool isRecurring;
  final String? recurrenceType;
  final String? receiptImage;
  final String createdAt;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.date,
    this.note,
    this.paymentMode = 'Cash',
    this.isRecurring = false,
    this.recurrenceType,
    this.receiptImage,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'type': type,
        'category_id': categoryId,
        'date': date,
        'note': note,
        'payment_mode': paymentMode,
        'is_recurring': isRecurring ? 1 : 0,
        'recurrence_type': recurrenceType,
        'receipt_image': receiptImage,
        'created_at': createdAt,
      };

  factory TransactionModel.fromMap(Map<String, dynamic> m) => TransactionModel(
        id: m['id'],
        amount: (m['amount'] as num).toDouble(),
        type: m['type'],
        categoryId: m['category_id'],
        date: m['date'],
        note: m['note'],
        paymentMode: m['payment_mode'] ?? 'Cash',
        isRecurring: (m['is_recurring'] ?? 0) == 1,
        recurrenceType: m['recurrence_type'],
        receiptImage: m['receipt_image'],
        createdAt: m['created_at'],
      );

  TransactionModel copyWith({
    String? id,
    double? amount,
    String? type,
    String? categoryId,
    String? date,
    String? note,
    String? paymentMode,
    bool? isRecurring,
    String? recurrenceType,
    String? receiptImage,
    String? createdAt,
  }) =>
      TransactionModel(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        type: type ?? this.type,
        categoryId: categoryId ?? this.categoryId,
        date: date ?? this.date,
        note: note ?? this.note,
        paymentMode: paymentMode ?? this.paymentMode,
        isRecurring: isRecurring ?? this.isRecurring,
        recurrenceType: recurrenceType ?? this.recurrenceType,
        receiptImage: receiptImage ?? this.receiptImage,
        createdAt: createdAt ?? this.createdAt,
      );
}
