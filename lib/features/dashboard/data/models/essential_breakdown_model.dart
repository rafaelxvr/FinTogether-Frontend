import '../../domain/entities/essential_breakdown.dart';

class EssentialCategoryItemModel {
  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;

  const EssentialCategoryItemModel({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  factory EssentialCategoryItemModel.fromJson(Map<String, dynamic> json) {
    return EssentialCategoryItemModel(
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      amount: (json['amount'] as num).toDouble(),
      percentage: (json['percentage'] as num).toDouble(),
    );
  }

  EssentialCategoryItem toEntity() {
    return EssentialCategoryItem(
      categoryId: categoryId,
      categoryName: categoryName,
      amount: amount,
      percentage: percentage,
    );
  }
}

class EssentialBreakdownModel {
  final String budgetId;
  final String period;
  final double essentialTotal;
  final double nonEssentialTotal;
  final double essentialPercentage;
  final double nonEssentialPercentage;
  final List<EssentialCategoryItemModel> essentialCategories;
  final List<EssentialCategoryItemModel> nonEssentialCategories;

  const EssentialBreakdownModel({
    required this.budgetId,
    required this.period,
    required this.essentialTotal,
    required this.nonEssentialTotal,
    required this.essentialPercentage,
    required this.nonEssentialPercentage,
    required this.essentialCategories,
    required this.nonEssentialCategories,
  });

  factory EssentialBreakdownModel.fromJson(Map<String, dynamic> json) {
    return EssentialBreakdownModel(
      budgetId: json['budgetId'] as String,
      period: json['period'] as String,
      essentialTotal: (json['essentialTotal'] as num).toDouble(),
      nonEssentialTotal: (json['nonEssentialTotal'] as num).toDouble(),
      essentialPercentage: (json['essentialPercentage'] as num).toDouble(),
      nonEssentialPercentage: (json['nonEssentialPercentage'] as num).toDouble(),
      essentialCategories: (json['essentialCategories'] as List)
          .map((e) => EssentialCategoryItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      nonEssentialCategories: (json['nonEssentialCategories'] as List)
          .map((e) => EssentialCategoryItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  EssentialBreakdown toEntity() {
    return EssentialBreakdown(
      budgetId: budgetId,
      period: period,
      essentialTotal: essentialTotal,
      nonEssentialTotal: nonEssentialTotal,
      essentialPercentage: essentialPercentage,
      nonEssentialPercentage: nonEssentialPercentage,
      essentialCategories: essentialCategories.map((e) => e.toEntity()).toList(),
      nonEssentialCategories: nonEssentialCategories.map((e) => e.toEntity()).toList(),
    );
  }
}
