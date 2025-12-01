/// Subscription Model
/// Represents a user's premium subscription status

class Subscription {
  final String userId;
  final String phoneNumber;
  final String subscriptionId;
  final String status; // 'active', 'suspended', 'cancelled', 'not_subscribed'
  final DateTime? startDate;
  final DateTime? nextBillingDate;
  final DateTime? endDate;
  final double amount;
  final List<String> features;
  final String? failureReason;

  Subscription({
    required this.userId,
    required this.phoneNumber,
    required this.subscriptionId,
    required this.status,
    this.startDate,
    this.nextBillingDate,
    this.endDate,
    required this.amount,
    required this.features,
    this.failureReason,
  });

  bool get isActive => status == 'active';
  bool get isSuspended => status == 'suspended';
  bool get isCancelled => status == 'cancelled';

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      userId: json['userId'] as String,
      phoneNumber: json['phoneNumber'] as String,
      subscriptionId: json['subscriptionId'] as String,
      status: json['status'] as String,
      startDate: json['startDate'] != null 
          ? DateTime.parse(json['startDate'] as String)
          : null,
      nextBillingDate: json['nextBillingDate'] != null
          ? DateTime.parse(json['nextBillingDate'] as String)
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'] as String)
          : null,
      amount: (json['amount'] as num).toDouble(),
      features: (json['features'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      failureReason: json['failureReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'phoneNumber': phoneNumber,
      'subscriptionId': subscriptionId,
      'status': status,
      'startDate': startDate?.toIso8601String(),
      'nextBillingDate': nextBillingDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'amount': amount,
      'features': features,
      'failureReason': failureReason,
    };
  }

  Subscription copyWith({
    String? userId,
    String? phoneNumber,
    String? subscriptionId,
    String? status,
    DateTime? startDate,
    DateTime? nextBillingDate,
    DateTime? endDate,
    double? amount,
    List<String>? features,
    String? failureReason,
  }) {
    return Subscription(
      userId: userId ?? this.userId,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      endDate: endDate ?? this.endDate,
      amount: amount ?? this.amount,
      features: features ?? this.features,
      failureReason: failureReason ?? this.failureReason,
    );
  }
}

/// Subscription Status Response
class SubscriptionStatusResponse {
  final bool subscribed;
  final Subscription? subscription;
  final String message;

  SubscriptionStatusResponse({
    required this.subscribed,
    this.subscription,
    required this.message,
  });

  factory SubscriptionStatusResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return SubscriptionStatusResponse(
      subscribed: data['subscribed'] as bool,
      subscription: data['subscribed'] == true && data.containsKey('userId')
          ? Subscription.fromJson(data)
          : null,
      message: json['message'] as String? ?? '',
    );
  }
}
