import 'package:equatable/equatable.dart';

/// Domain entity for per-card monthly cost
class CardMonthlyCost extends Equatable {
  final String cardId;
  final String cardName;
  final DateTime billingCycleStart;
  final DateTime billingCycleEnd;
  final double totalCost;
  final int transactionCount;

  const CardMonthlyCost({
    required this.cardId,
    required this.cardName,
    required this.billingCycleStart,
    required this.billingCycleEnd,
    required this.totalCost,
    required this.transactionCount,
  });

  String get formattedCost => 'R\$ ${totalCost.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
        cardId,
        cardName,
        billingCycleStart,
        billingCycleEnd,
        totalCost,
        transactionCount,
      ];
}

/// All cards cost summary for a budget
class AllCardsCostSummary extends Equatable {
  final String budgetId;
  final String period;
  final List<CardMonthlyCost> cards;
  final double grandTotal;

  const AllCardsCostSummary({
    required this.budgetId,
    required this.period,
    required this.cards,
    required this.grandTotal,
  });

  @override
  List<Object?> get props => [budgetId, period, cards, grandTotal];
}

/// Cost comparison for a single card over multiple months
class CardCostComparison extends Equatable {
  final String cardId;
  final String cardName;
  final List<CardMonthlyCost> months;

  const CardCostComparison({
    required this.cardId,
    required this.cardName,
    required this.months,
  });

  double get averageCost {
    if (months.isEmpty) return 0.0;
    return months.map((m) => m.totalCost).reduce((a, b) => a + b) / months.length;
  }

  @override
  List<Object?> get props => [cardId, cardName, months];
}
