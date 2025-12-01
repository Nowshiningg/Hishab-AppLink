class Income {
  final int? id;
  final double monthlyIncome;
  final DateTime dateSet;

  Income({this.id, required this.monthlyIncome, required this.dateSet});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'monthly_income': monthlyIncome,
      'date_set': dateSet.toIso8601String(),
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'] as int?,
      monthlyIncome: map['monthly_income'] as double,
      dateSet: DateTime.parse(map['date_set'] as String),
    );
  }

  Income copyWith({int? id, double? monthlyIncome, DateTime? dateSet}) {
    return Income(
      id: id ?? this.id,
      monthlyIncome: monthlyIncome ?? this.monthlyIncome,
      dateSet: dateSet ?? this.dateSet,
    );
  }
}
