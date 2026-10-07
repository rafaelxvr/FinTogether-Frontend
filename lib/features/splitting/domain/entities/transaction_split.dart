import 'package:equatable/equatable.dart';

class TransactionSplit extends Equatable {
  final String id;
  final String transactionId;
  final String userId;
  final String userName;
  final double amount;
  final bool isPaid;
  final DateTime? paidAt;
  final DateTime createdAt;

  const TransactionSplit({
    required this.id,
    required this.transactionId,
    required this.userId,
    required this.userName,
    required this.amount,
    this.isPaid = false,
    this.paidAt,
    required this.createdAt,
  });

  bool get isSettled => isPaid;

  String get formattedAmount => 'R\$ ${amount.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
        id,
        transactionId,
        userId,
        userName,
        amount,
        isPaid,
        paidAt,
        createdAt,
      ];

  TransactionSplit copyWith({
    String? id,
    String? transactionId,
    String? userId,
    String? userName,
    double? amount,
    bool? isPaid,
    DateTime? paidAt,
    DateTime? createdAt,
  }) {
    return TransactionSplit(
      id: id ?? this.id,
      transactionId: transactionId ?? this.transactionId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      amount: amount ?? this.amount,
      isPaid: isPaid ?? this.isPaid,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
