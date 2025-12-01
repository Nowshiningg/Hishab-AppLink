class Reward {
  final int? id;
  final int points;
  final String reason;
  final DateTime timestamp;
  final String type; // 'earned' or 'redeemed'

  Reward({
    this.id,
    required this.points,
    required this.reason,
    required this.timestamp,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'points': points,
      'reason': reason,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }

  factory Reward.fromMap(Map<String, dynamic> map) {
    return Reward(
      id: map['id'] as int?,
      points: map['points'] as int,
      reason: map['reason'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      type: map['type'] as String,
    );
  }
}

class RewardRedemption {
  final String title;
  final String description;
  final int pointsCost;
  final String icon;
  final String type; // 'data', 'minutes', 'discount'

  RewardRedemption({
    required this.title,
    required this.description,
    required this.pointsCost,
    required this.icon,
    required this.type,
  });
}
