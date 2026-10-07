import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/merchant.dart';

part 'merchant_model.g.dart';

@JsonSerializable()
class MerchantModel extends Merchant {
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  const MerchantModel({
    required super.id,
    required super.budgetId,
    required super.name,
    super.displayName,
    super.logoUrl,
    super.color,
    super.defaultCategoryId,
    required super.archived,
    required super.createdAt,
    @JsonKey(name: 'updated_at') super.updatedAt,
    this.deletedAt,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) =>
      _$MerchantModelFromJson(json);

  Map<String, dynamic> toJson() => _$MerchantModelToJson(this);

  Merchant toEntity() => Merchant(
        id: id,
        budgetId: budgetId,
        name: name,
        displayName: displayName,
        logoUrl: logoUrl,
        color: color,
        defaultCategoryId: defaultCategoryId,
        archived: archived,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory MerchantModel.fromEntity(Merchant merchant) => MerchantModel(
        id: merchant.id,
        budgetId: merchant.budgetId,
        name: merchant.name,
        displayName: merchant.displayName,
        logoUrl: merchant.logoUrl,
        color: merchant.color,
        defaultCategoryId: merchant.defaultCategoryId,
        archived: merchant.archived,
        createdAt: merchant.createdAt,
        updatedAt: merchant.updatedAt,
      );
}
