import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/budget_allocation.dart';

part 'budget_allocation_model.g.dart';

/// Budget Allocation Model
/// JSON serializable model for API communication.
@JsonSerializable()
class BudgetAllocationModel {
  final String budgetId;
  final String month;
  final double totalAllocated;
  final double totalSpent;
  final double totalRemaining;
  final double overallPercentageUsed;
  final List<CategoryAllocationModel> categories;

  BudgetAllocationModel({
    required this.budgetId,
    required this.month,
    required this.totalAllocated,
    required this.totalSpent,
    required this.totalRemaining,
    required this.overallPercentageUsed,
    required this.categories,
  });

  factory BudgetAllocationModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetAllocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetAllocationModelToJson(this);

  BudgetAllocation toEntity() {
    return BudgetAllocation(
      budgetId: budgetId,
      month: month,
      totalAllocated: totalAllocated,
      totalSpent: totalSpent,
      totalRemaining: totalRemaining,
      overallPercentageUsed: overallPercentageUsed,
      categories: categories.map((c) => c.toEntity()).toList(),
    );
  }
}

/// Category Allocation Model
/// JSON serializable model for category allocation data.
@JsonSerializable()
class CategoryAllocationModel {
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

  CategoryAllocationModel({
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

  factory CategoryAllocationModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryAllocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryAllocationModelToJson(this);

  CategoryAllocation toEntity() {
    return CategoryAllocation(
      categoryId: categoryId,
      categoryName: categoryName,
      categoryIcon: categoryIcon,
      categoryColor: categoryColor,
      allocatedAmount: allocatedAmount,
      spentAmount: spentAmount,
      remainingAmount: remainingAmount,
      percentageUsed: percentageUsed,
      limitAmount: limitAmount,
      isOverBudget: isOverBudget,
    );
  }
}

/// Request model for setting allocations via PUT.
@JsonSerializable()
class SetAllocationsRequestModel {
  final String month;
  final List<CategoryAllocationInputModel> allocations;

  SetAllocationsRequestModel({
    required this.month,
    required this.allocations,
  });

  factory SetAllocationsRequestModel.fromJson(Map<String, dynamic> json) =>
      _$SetAllocationsRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$SetAllocationsRequestModelToJson(this);
}

/// Input model for a single category allocation in a request.
@JsonSerializable()
class CategoryAllocationInputModel {
  final String categoryId;
  final double allocatedAmount;

  CategoryAllocationInputModel({
    required this.categoryId,
    required this.allocatedAmount,
  });

  factory CategoryAllocationInputModel.fromJson(Map<String, dynamic> json) =>
      _$CategoryAllocationInputModelFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryAllocationInputModelToJson(this);
}
