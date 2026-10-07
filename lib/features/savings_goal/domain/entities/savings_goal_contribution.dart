import 'package:equatable/equatable.dart';

class SavingsGoalContribution extends Equatable {
  final String id;
  final String savingsGoalId;
  final double amount;
  final String? note;
  final DateTime contributedAt;

  const SavingsGoalContribution({
    required this.id,
    required this.savingsGoalId,
    required this.amount,
    this.note,
    required this.contributedAt,
  });

  bool get isWithdrawal => amount < 0;

  String get formattedAmount {
    final absAmount = amount.abs();
    final sign = isWithdrawal ? '-' : '+';
    return '$sign ${absAmount.toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props => [
        id,
        savingsGoalId,
        amount,
        note,
        contributedAt,
      ];

  SavingsGoalContribution copyWith({
    String? id,
    String? savingsGoalId,
    double? amount,
    String? note,
    DateTime? contributedAt,
  }) {
    return SavingsGoalContribution(
      id: id ?? this.id,
      savingsGoalId: savingsGoalId ?? this.savingsGoalId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      contributedAt: contributedAt ?? this.contributedAt,
    );
  }
}
