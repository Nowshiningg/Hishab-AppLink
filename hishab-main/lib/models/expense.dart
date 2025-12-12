class Expense {
  final int? id;
  final double amount;
  final String category;
  final String note;
  final DateTime date;
  final DateTime timestamp;

  Expense({
    this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'category': category,
      'note': note,
      'date': date.toIso8601String(),
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      amount: map['amount'] as double,
      category: map['category'] as String,
      note: map['note'] as String,
      date: DateTime.parse(map['date'] as String),
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  /// Create Expense from backend API JSON response
  factory Expense.fromApiJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as int?,
      amount: (json['amount'] as num).toDouble(),
      category: json['category_name'] ?? json['category'] ?? 'Other',
      note: json['note'] ?? '',
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
      timestamp: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Expense copyWith({
    int? id,
    double? amount,
    String? category,
    String? note,
    DateTime? date,
    DateTime? timestamp,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      note: note ?? this.note,
      date: date ?? this.date,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
