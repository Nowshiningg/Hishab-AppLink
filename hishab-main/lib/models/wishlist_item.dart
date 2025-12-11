class WishlistItem {
  final int? id;
  final String title;
  final double price;
  final double savedAmount;
  final String? targetDate; // ISO 8601 format (optional)
  final String? imageUrl;
  final int priority; // Lower number = higher priority
  final String createdAt;
  final String updatedAt;
  final bool isPurchased;

  WishlistItem({
    this.id,
    required this.title,
    required this.price,
    this.savedAmount = 0.0,
    this.targetDate,
    this.imageUrl,
    this.priority = 999,
    required this.createdAt,
    required this.updatedAt,
    this.isPurchased = false,
  });

  // Convert to Map for DB persistence
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'savedAmount': savedAmount,
      'targetDate': targetDate,
      'imageUrl': imageUrl,
      'priority': priority,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isPurchased': isPurchased ? 1 : 0,
    };
  }

  // Create from DB row
  factory WishlistItem.fromMap(Map<String, dynamic> map) {
    return WishlistItem(
      id: map['id'] as int?,
      title: map['title'] as String,
      price: (map['price'] as num).toDouble(),
      savedAmount: (map['savedAmount'] as num).toDouble(),
      targetDate: map['targetDate'] as String?,
      imageUrl: map['imageUrl'] as String?,
      priority: map['priority'] as int? ?? 999,
      createdAt: map['createdAt'] as String,
      updatedAt: map['updatedAt'] as String,
      isPurchased: (map['isPurchased'] as int) == 1,
    );
  }

  // Create from JSON
  factory WishlistItem.fromJson(Map<String, dynamic> json) {
    return WishlistItem(
      id: json['id'] as int?,
      title: json['title'] as String,
      price: (json['price'] as num).toDouble(),
      savedAmount: (json['savedAmount'] as num?)?.toDouble() ?? 0.0,
      targetDate: json['targetDate'] as String?,
      imageUrl: json['imageUrl'] as String?,
      priority: json['priority'] as int? ?? 999,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      isPurchased: json['isPurchased'] as bool? ?? false,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'savedAmount': savedAmount,
      'targetDate': targetDate,
      'imageUrl': imageUrl,
      'priority': priority,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isPurchased': isPurchased,
    };
  }

  // Copy with method for updates
  WishlistItem copyWith({
    int? id,
    String? title,
    double? price,
    double? savedAmount,
    String? targetDate,
    String? imageUrl,
    int? priority,
    String? createdAt,
    String? updatedAt,
    bool? isPurchased,
  }) {
    return WishlistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      price: price ?? this.price,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
      imageUrl: imageUrl ?? this.imageUrl,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }

  // Helper: calculate progress percentage (0.0 - 1.0)
  double get progressPercent {
    if (price <= 0) return 0.0;
    return (savedAmount / price).clamp(0.0, 1.0);
  }

  // Helper: remaining amount
  double get remainingAmount {
    return (price - savedAmount).clamp(0.0, double.infinity);
  }

  // Helper: can purchase
  bool get canPurchase {
    return savedAmount >= price;
  }
}
