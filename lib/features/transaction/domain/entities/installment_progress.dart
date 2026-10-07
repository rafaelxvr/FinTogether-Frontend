import 'package:equatable/equatable.dart';

import 'installment_group.dart';
import 'transaction.dart';

class InstallmentProgress extends Equatable {
  final InstallmentGroup group;
  final int paidCount;
  final double paidAmount;
  final int remainingCount;
  final double remainingAmount;
  final List<Transaction> transactions;

  const InstallmentProgress({
    required this.group,
    required this.paidCount,
    required this.paidAmount,
    required this.remainingCount,
    required this.remainingAmount,
    required this.transactions,
  });

  double get progressPercent =>
      group.installmentCount > 0 ? paidCount / group.installmentCount : 0;

  bool get isCompleted => paidCount >= group.installmentCount;

  @override
  List<Object?> get props => [
        group,
        paidCount,
        paidAmount,
        remainingCount,
        remainingAmount,
      ];
}
