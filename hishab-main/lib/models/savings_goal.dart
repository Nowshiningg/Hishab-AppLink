class SavingsGoal {
  final int? id;
  final String title;
  final double targetAmount;
  final double currentAmount; // Current progress (manually tracked)
  final double monthlyAllocation; // How much to allocate monthly
  final String targetDate; // ISO 8601 format
  final String createdAt;
  final String updatedAt;
  final bool isActive;
  final bool notifyOnMilestone;
  final String? colorHex;

  SavingsGoal({
    this.id,
    required this.title,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.monthlyAllocation = 0.0,
    required this.targetDate,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
    this.notifyOnMilestone = true,
    this.colorHex,
  });

  // Convert to Map for DB persistence
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'monthlyAllocation': monthlyAllocation,
      'targetDate': targetDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive ? 1 : 0,
      'notifyOnMilestone': notifyOnMilestone ? 1 : 0,
      'colorHex': colorHex,
    };
  }

  // Create from DB row
  factory SavingsGoal.fromMap(Map<String, dynamic> map) {
    return SavingsGoal(
      id: map['id'] as int?,
      title: map['title'] as String,
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num?)?.toDouble() ?? (map['savedAmount'] as num?)?.toDouble() ?? 0.0,
      monthlyAllocation: (map['monthlyAllocation'] as num?)?.toDouble() ?? 0.0,
      targetDate: map['targetDate'] as String,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
      isActive: (map['isActive'] as int) == 1,
      notifyOnMilestone: (map['notifyOnMilestone'] as int) == 1,
      colorHex: map['colorHex'] as String?,
    );
  }

  // Create from JSON
  factory SavingsGoal.fromJson(Map<String, dynamic> json) {
    return SavingsGoal(
      id: json['id'] as int?,
      title: json['title'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num?)?.toDouble() ?? 0.0,
      monthlyAllocation: (json['monthlyAllocation'] as num?)?.toDouble() ?? 0.0,
      targetDate: json['targetDate'] as String,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      isActive: json['isActive'] as bool? ?? true,
      notifyOnMilestone: json['notifyOnMilestone'] as bool? ?? true,
      colorHex: json['colorHex'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'monthlyAllocation': monthlyAllocation,
      'targetDate': targetDate,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
      'notifyOnMilestone': notifyOnMilestone,
      'colorHex': colorHex,
    };
  }

  // Copy with method for updates
  SavingsGoal copyWith({
    int? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    double? monthlyAllocation,
    String? targetDate,
    String? createdAt,
    String? updatedAt,
    bool? isActive,
    bool? notifyOnMilestone,
    String? colorHex,
  }) {
    return SavingsGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      monthlyAllocation: monthlyAllocation ?? this.monthlyAllocation,
      targetDate: targetDate ?? this.targetDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      notifyOnMilestone: notifyOnMilestone ?? this.notifyOnMilestone,
      colorHex: colorHex ?? this.colorHex,
    );
  }

  // Helper: calculate progress percentage (0.0 - 1.0)
  double get progressPercent {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  // Helper: remaining amount
  double get remainingAmount {
    return (targetAmount - currentAmount).clamp(0.0, double.infinity);
  }

  // Helper: is goal completed
  bool get isCompleted {
    return currentAmount >= targetAmount;
  }

  // Helper: calculate months to reach goal based on monthly allocation
  int get monthsToReachGoal {
    if (monthlyAllocation <= 0) return 999;
    final remaining = remainingAmount;
    return (remaining / monthlyAllocation).ceil();
  }

  // Helper: calculate projected completion date
  DateTime get projectedCompletionDate {
    final targetDateTime = DateTime.parse(targetDate);
    if (monthlyAllocation <= 0) return targetDateTime;
    
    final monthsNeeded = monthsToReachGoal;
    final projected = DateTime.now().add(Duration(days: monthsNeeded * 30));
    return projected;
  }

  // Helper: check if on track to meet target date
  bool get isOnTrack {
    final target = DateTime.parse(targetDate);
    final projected = projectedCompletionDate;
    return projected.isBefore(target) || projected.isAtSameMomentAs(target);
  }
}
