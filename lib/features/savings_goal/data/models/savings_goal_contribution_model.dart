import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/savings_goal_contribution.dart';

part 'savings_goal_contribution_model.g.dart';

@JsonSerializable()
class SavingsGoalContributionModel extends SavingsGoalContribution {
  const SavingsGoalContributionModel({
    required super.id,
    required super.savingsGoalId,
    required super.amount,
    super.note,
    required super.contributedAt,
  });

  factory SavingsGoalContributionModel.fromJson(Map<String, dynamic> json) =>
      _$SavingsGoalContributionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SavingsGoalContributionModelToJson(this);

  SavingsGoalContribution toEntity() => SavingsGoalContribution(
        id: id,
        savingsGoalId: savingsGoalId,
        amount: amount,
        note: note,
        contributedAt: contributedAt,
      );

  factory SavingsGoalContributionModel.fromEntity(
          SavingsGoalContribution contribution) =>
      SavingsGoalContributionModel(
        id: contribution.id,
        savingsGoalId: contribution.savingsGoalId,
        amount: contribution.amount,
        note: contribution.note,
        contributedAt: contribution.contributedAt,
      );
}
