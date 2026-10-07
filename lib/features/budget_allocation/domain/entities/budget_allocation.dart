import 'package:equatable/equatable.dart';

/// Budget health status based on spending percentage.
enum BudgetHealthStatus { healthy, warning, overBudget }

/// Allocation bar color based on spending percentage.
enum AllocationBarColor { green, yellow, red }

/// Budget Allocation Entity
/// Represents all allocations for a budget in a given month, with spending data.
class BudgetAllocation extends Equatable {
  final String budgetId;
  final String month;
  final double totalAllocated;
  final double totalSpent;
  final double totalRemaining;
  final double overallPercentageUsed;
  final List<CategoryAllocation> categories;

  const BudgetAllocation({
    required this.budgetId,
    required this.month,
    required this.totalAllocated,
    required this.totalSpent,
    required this.totalRemaining,
    required this.overallPercentageUsed,
    required this.categories,
  });

  BudgetHealthStatus get healthStatus {
    if (overallPercentageUsed > 100) return BudgetHealthStatus.overBudget;
    if (overallPercentageUsed >= 80) return BudgetHealthStatus.warning;
    return BudgetHealthStatus.healthy;
  }

  BudgetAllocation copyWith({
    String? budgetId,
    String? month,
    double? totalAllocated,
    double? totalSpent,
    double? totalRemaining,
    double? overallPercentageUsed,
    List<CategoryAllocation>? categories,
  }) {
    return BudgetAllocation(
      budgetId: budgetId ?? this.budgetId,
      month: month ?? this.month,
      totalAllocated: totalAllocated ?? this.totalAllocated,
      totalSpent: totalSpent ?? this.totalSpent,
      totalRemaining: totalRemaining ?? this.totalRemaining,
      overallPercentageUsed: overallPercentageUsed ?? this.overallPercentageUsed,
      categories: categories ?? this.categories,
    );
  }

  @override
  List<Object?> get props => [budgetId, month, totalAllocated, totalSpent, categories];
}

/// Category Allocation Entity
/// Represents a single category's allocation and actual spending.
class CategoryAllocation extends Equatable {
  final String categoryId;
  final String categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final double allocatedAmount;
  final double spentAmount;
  final double remainingAmount;
  final double percentageUsed;
  final double? limitAmount;
  final bool isOverBudget;

  const CategoryAllocation({
    required this.categoryId,
    required this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    required this.allocatedAmount,
    required this.spentAmount,
    required this.remainingAmount,
    required this.percentageUsed,
    this.limitAmount,
    required this.isOverBudget,
  });

  AllocationBarColor get barColor {
    if (percentageUsed > 100) return AllocationBarColor.red;
    if (percentageUsed >= 80) return AllocationBarColor.yellow;
    return AllocationBarColor.green;
  }

  CategoryAllocation copyWith({
    String? categoryId,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    double? allocatedAmount,
    double? spentAmount,
    double? remainingAmount,
    double? percentageUsed,
    double? limitAmount,
    bool? isOverBudget,
  }) {
    return CategoryAllocation(
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      allocatedAmount: allocatedAmount ?? this.allocatedAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      percentageUsed: percentageUsed ?? this.percentageUsed,
      limitAmount: limitAmount ?? this.limitAmount,
      isOverBudget: isOverBudget ?? this.isOverBudget,
    );
  }

  @override
  List<Object?> get props => [categoryId, allocatedAmount, spentAmount, percentageUsed];
}

/// Input model for setting a category allocation.
class CategoryAllocationInput {
  final String categoryId;
  final double allocatedAmount;

  const CategoryAllocationInput({
    required this.categoryId,
    required this.allocatedAmount,
  });
}
