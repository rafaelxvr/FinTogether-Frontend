import '../../domain/entities/card_monthly_cost.dart';

class CardMonthlyCostModel {
  final String cardId;
  final String cardName;
  final String billingCycleStart;
  final String billingCycleEnd;
  final double totalCost;
  final int transactionCount;

  const CardMonthlyCostModel({
    required this.cardId,
    required this.cardName,
    required this.billingCycleStart,
    required this.billingCycleEnd,
    required this.totalCost,
    required this.transactionCount,
  });

  factory CardMonthlyCostModel.fromJson(Map<String, dynamic> json) {
    return CardMonthlyCostModel(
      cardId: json['cardId'] as String,
      cardName: json['cardName'] as String,
      billingCycleStart: json['billingCycleStart'] as String,
      billingCycleEnd: json['billingCycleEnd'] as String,
      totalCost: (json['totalCost'] as num).toDouble(),
      transactionCount: json['transactionCount'] as int,
    );
  }

  CardMonthlyCost toEntity() {
    return CardMonthlyCost(
      cardId: cardId,
      cardName: cardName,
      billingCycleStart: DateTime.parse(billingCycleStart),
      billingCycleEnd: DateTime.parse(billingCycleEnd),
      totalCost: totalCost,
      transactionCount: transactionCount,
    );
  }
}

class AllCardsCostSummaryModel {
  final String budgetId;
  final String period;
  final List<CardMonthlyCostModel> cards;
  final double grandTotal;

  const AllCardsCostSummaryModel({
    required this.budgetId,
    required this.period,
    required this.cards,
    required this.grandTotal,
  });

  factory AllCardsCostSummaryModel.fromJson(Map<String, dynamic> json) {
    return AllCardsCostSummaryModel(
      budgetId: json['budgetId'] as String,
      period: json['period'] as String,
      cards: (json['cards'] as List)
          .map((e) => CardMonthlyCostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      grandTotal: (json['grandTotal'] as num).toDouble(),
    );
  }

  AllCardsCostSummary toEntity() {
    return AllCardsCostSummary(
      budgetId: budgetId,
      period: period,
      cards: cards.map((m) => m.toEntity()).toList(),
      grandTotal: grandTotal,
    );
  }
}

class CardCostComparisonModel {
  final String cardId;
  final String cardName;
  final List<CardMonthlyCostModel> months;

  const CardCostComparisonModel({
    required this.cardId,
    required this.cardName,
    required this.months,
  });

  factory CardCostComparisonModel.fromJson(Map<String, dynamic> json) {
    return CardCostComparisonModel(
      cardId: json['cardId'] as String,
      cardName: json['cardName'] as String,
      months: (json['months'] as List)
          .map((e) => CardMonthlyCostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  CardCostComparison toEntity() {
    return CardCostComparison(
      cardId: cardId,
      cardName: cardName,
      months: months.map((m) => m.toEntity()).toList(),
    );
  }
}
