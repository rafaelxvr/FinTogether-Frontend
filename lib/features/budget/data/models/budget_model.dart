import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/budget.dart';

part 'budget_model.g.dart';

@JsonSerializable()
class BudgetModel extends Budget {
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  const BudgetModel({
    required super.id,
    required super.name,
    required super.type,
    required super.ownerId,
    required super.ownerName,
    required super.memberCount,
    required super.createdAt,
    required super.updatedAt,
    this.deletedAt,
  });

  factory BudgetModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetModelFromJson(json);

  Map<String, dynamic> toJson() => _$BudgetModelToJson(this);

  factory BudgetModel.fromEntity(Budget budget) {
    return BudgetModel(
      id: budget.id,
      name: budget.name,
      type: budget.type,
      ownerId: budget.ownerId,
      ownerName: budget.ownerName,
      memberCount: budget.memberCount,
      createdAt: budget.createdAt,
      updatedAt: budget.updatedAt,
    );
  }

  Budget toEntity() {
    return Budget(
      id: id,
      name: name,
      type: type,
      ownerId: ownerId,
      ownerName: ownerName,
      memberCount: memberCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
