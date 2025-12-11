class Streak {
  final int? id;
  final String type; // e.g., 'daily_login', 'daily_budget', 'daily_savings'
  final int current;
  final int best;
  final String lastActiveDate; // ISO 8601 format (date only)

  Streak({
    this.id,
    required this.type,
    this.current = 0,
    this.best = 0,
    required this.lastActiveDate,
  });

  // Convert to Map for DB persistence
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'current': current,
      'best': best,
      'lastActiveDate': lastActiveDate,
    };
  }

  // Create from DB row
  factory Streak.fromMap(Map<String, dynamic> map) {
    return Streak(
      id: map['id'] as int?,
      type: map['type'] as String,
      current: map['current'] as int,
      best: map['best'] as int,
      lastActiveDate: map['lastActiveDate'] as String,
    );
  }

  // Create from JSON
  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      id: json['id'] as int?,
      type: json['type'] as String,
      current: json['current'] as int? ?? 0,
      best: json['best'] as int? ?? 0,
      lastActiveDate: json['lastActiveDate'] as String,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'current': current,
      'best': best,
      'lastActiveDate': lastActiveDate,
    };
  }

  // Copy with method for updates
  Streak copyWith({
    int? id,
    String? type,
    int? current,
    int? best,
    String? lastActiveDate,
  }) {
    return Streak(
      id: id ?? this.id,
      type: type ?? this.type,
      current: current ?? this.current,
      best: best ?? this.best,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    );
  }
}
