import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/budget_member.dart';

part 'budget_member_model.g.dart';

@JsonSerializable()
class BudgetMemberModel extends BudgetMember {
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  const BudgetMemberModel({
    required super.id,
    required super.budgetId,
    required super.userId,
    required super.userName,
    required super.userEmail,
    required super.role,
    required super.joinedAt,
    @JsonKey(name: 'updated_at') super.updatedAt,
    this.deletedAt,
  });

  factory BudgetMemberModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetMemberModelFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetMemberModelToJson(this);

  factory BudgetMemberModel.fromEntity(BudgetMember member) {
    return BudgetMemberModel(
      id: member.id,
      budgetId: member.budgetId,
      userId: member.userId,
      userName: member.userName,
      userEmail: member.userEmail,
      role: member.role,
      joinedAt: member.joinedAt,
      updatedAt: member.updatedAt,
    );
  }

  BudgetMember toEntity() {
    return BudgetMember(
      id: id,
      budgetId: budgetId,
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      role: role,
      joinedAt: joinedAt,
      updatedAt: updatedAt,
    );
  }
}
