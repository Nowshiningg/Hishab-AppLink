/// Transaction Model
/// Represents a CaaS (Charging-as-a-Service) transaction
library;

class Transaction {
  final String transactionId;
  final String userId;
  final String phoneNumber;
  final String chargeType;
  final double amount;
  final String status; // 'pending', 'completed', 'failed', 'refunded'
  final String? paymentId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final Map<String, dynamic> metadata;
  final String? failureReason;

  Transaction({
    required this.transactionId,
    required this.userId,
    required this.phoneNumber,
    required this.chargeType,
    required this.amount,
    required this.status,
    this.paymentId,
    required this.createdAt,
    this.completedAt,
    required this.metadata,
    this.failureReason,
  });

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transactionId'] as String,
      userId: json['userId'] as String,
      phoneNumber: json['phoneNumber'] as String,
      chargeType: json['chargeType'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      paymentId: json['paymentId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
      failureReason: json['failureReason'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionId': transactionId,
      'userId': userId,
      'phoneNumber': phoneNumber,
      'chargeType': chargeType,
      'amount': amount,
      'status': status,
      'paymentId': paymentId,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'metadata': metadata,
      'failureReason': failureReason,
    };
  }
}

/// Transaction History Response
class TransactionHistory {
  final List<Transaction> transactions;
  final double totalCharged;
  final int totalTransactions;

  TransactionHistory({
    required this.transactions,
    required this.totalCharged,
    required this.totalTransactions,
  });

  factory TransactionHistory.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return TransactionHistory(
      transactions: (data['transactions'] as List<dynamic>)
          .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCharged: (data['totalCharged'] as num).toDouble(),
      totalTransactions: data['totalTransactions'] as int,
    );
  }
}
