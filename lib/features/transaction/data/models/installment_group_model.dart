import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/installment_group.dart';

part 'installment_group_model.g.dart';

@JsonSerializable()
class InstallmentGroupModel extends InstallmentGroup {
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  const InstallmentGroupModel({
    required super.id,
    @JsonKey(name: 'budget_id') required super.budgetId,
    @JsonKey(name: 'card_id') super.cardId,
    @JsonKey(name: 'total_amount') required super.totalAmount,
    @JsonKey(name: 'installment_count') required super.installmentCount,
    @JsonKey(name: 'interest_rate') required super.interestRate,
    @JsonKey(name: 'start_date') required super.startDate,
    super.description,
    @JsonKey(name: 'created_at') required super.createdAt,
    @JsonKey(name: 'updated_at') super.updatedAt,
    this.deletedAt,
  });

  factory InstallmentGroupModel.fromJson(Map<String, dynamic> json) =>
      _$InstallmentGroupModelFromJson(json);

  Map<String, dynamic> toJson() => _$InstallmentGroupModelToJson(this);

  InstallmentGroup toEntity() => InstallmentGroup(
        id: id,
        budgetId: budgetId,
        cardId: cardId,
        totalAmount: totalAmount,
        installmentCount: installmentCount,
        interestRate: interestRate,
        startDate: startDate,
        description: description,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory InstallmentGroupModel.fromEntity(InstallmentGroup entity) =>
      InstallmentGroupModel(
        id: entity.id,
        budgetId: entity.budgetId,
        cardId: entity.cardId,
        totalAmount: entity.totalAmount,
        installmentCount: entity.installmentCount,
        interestRate: entity.interestRate,
        startDate: entity.startDate,
        description: entity.description,
        createdAt: entity.createdAt,
        updatedAt: entity.updatedAt,
      );
}
