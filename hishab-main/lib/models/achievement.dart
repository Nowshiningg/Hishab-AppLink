class Achievement {
  final int? id;
  final String key; // Unique identifier (e.g., 'streak_7_days', 'goal_completed_first')
  final String title;
  final String description;
  final String? unlockedAt; // ISO 8601 format, null if locked

  Achievement({
    this.id,
    required this.key,
    required this.title,
    required this.description,
    this.unlockedAt,
  });

  // Convert to Map for DB persistence
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'title': title,
      'description': description,
      'unlockedAt': unlockedAt,
    };
  }

  // Create from DB row
  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as int?,
      key: map['key'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      unlockedAt: map['unlockedAt'] as String?,
    );
  }

  // Create from JSON
  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as int?,
      key: json['key'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      unlockedAt: json['unlockedAt'] as String?,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'key': key,
      'title': title,
      'description': description,
      'unlockedAt': unlockedAt,
    };
  }

  // Copy with method for updates
  Achievement copyWith({
    int? id,
    String? key,
    String? title,
    String? description,
    String? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      key: key ?? this.key,
      title: title ?? this.title,
      description: description ?? this.description,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  // Helper: is unlocked
  bool get isUnlocked {
    return unlockedAt != null;
  }
}
