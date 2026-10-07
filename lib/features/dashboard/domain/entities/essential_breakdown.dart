import 'package:equatable/equatable.dart';

class EssentialBreakdown extends Equatable {
  final String budgetId;
  final String period;
  final double essentialTotal;
  final double nonEssentialTotal;
  final double essentialPercentage;
  final double nonEssentialPercentage;
  final List<EssentialCategoryItem> essentialCategories;
  final List<EssentialCategoryItem> nonEssentialCategories;

  const EssentialBreakdown({
    required this.budgetId,
    required this.period,
    required this.essentialTotal,
    required this.nonEssentialTotal,
    required this.essentialPercentage,
    required this.nonEssentialPercentage,
    required this.essentialCategories,
    required this.nonEssentialCategories,
  });

  double get totalExpense => essentialTotal + nonEssentialTotal;

  @override
  List<Object?> get props => [
        budgetId, period, essentialTotal, nonEssentialTotal,
        essentialPercentage, nonEssentialPercentage,
        essentialCategories, nonEssentialCategories,
      ];
}

class EssentialCategoryItem extends Equatable {
  final String categoryId;
  final String categoryName;
  final double amount;
  final double percentage;

  const EssentialCategoryItem({
    required this.categoryId,
    required this.categoryName,
    required this.amount,
    required this.percentage,
  });

  @override
  List<Object?> get props => [categoryId, categoryName, amount, percentage];
}
