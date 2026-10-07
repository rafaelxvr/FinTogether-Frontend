import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/savings_goal.dart';

part 'savings_goal_model.g.dart';

@JsonSerializable()
class SavingsGoalModel extends SavingsGoal {
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  const SavingsGoalModel({
    required super.id,
    required super.budgetId,
    super.accountId,
    required super.name,
    super.description,
    required super.targetAmount,
    required super.currentAmount,
    required super.currency,
    super.deadline,
    super.icon,
    super.color,
    required super.active,
    super.completedAt,
    required super.createdAt,
    @JsonKey(name: 'updated_at') super.updatedAt,
    this.deletedAt,
  });

  factory SavingsGoalModel.fromJson(Map<String, dynamic> json) =>
      _$SavingsGoalModelFromJson(json);

  Map<String, dynamic> toJson() => _$SavingsGoalModelToJson(this);

  SavingsGoal toEntity() => SavingsGoal(
        id: id,
        budgetId: budgetId,
        accountId: accountId,
        name: name,
        description: description,
        targetAmount: targetAmount,
        currentAmount: currentAmount,
        currency: currency,
        deadline: deadline,
        icon: icon,
        color: color,
        active: active,
        completedAt: completedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory SavingsGoalModel.fromEntity(SavingsGoal goal) => SavingsGoalModel(
        id: goal.id,
        budgetId: goal.budgetId,
        accountId: goal.accountId,
        name: goal.name,
        description: goal.description,
        targetAmount: goal.targetAmount,
        currentAmount: goal.currentAmount,
        currency: goal.currency,
        deadline: goal.deadline,
        icon: goal.icon,
        color: goal.color,
        active: goal.active,
        completedAt: goal.completedAt,
        createdAt: goal.createdAt,
        updatedAt: goal.updatedAt,
      );
}
