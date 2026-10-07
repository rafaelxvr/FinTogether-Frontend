import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/account.dart';

part 'account_model.g.dart';

@JsonSerializable()
class AccountModel extends Account {
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  const AccountModel({
    required super.id,
    required super.budgetId,
    required super.name,
    required super.type,
    required super.currency,
    required super.openingBalance,
    required super.currentBalance,
    required super.active,
    required super.createdAt,
    @JsonKey(name: 'updated_at') super.updatedAt,
    this.deletedAt,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) =>
      _$AccountModelFromJson(json);

  Map<String, dynamic> toJson() => _$AccountModelToJson(this);

  Account toEntity() => Account(
        id: id,
        budgetId: budgetId,
        name: name,
        type: type,
        currency: currency,
        openingBalance: openingBalance,
        currentBalance: currentBalance,
        active: active,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  factory AccountModel.fromEntity(Account account) => AccountModel(
        id: account.id,
        budgetId: account.budgetId,
        name: account.name,
        type: account.type,
        currency: account.currency,
        openingBalance: account.openingBalance,
        currentBalance: account.currentBalance,
        active: account.active,
        createdAt: account.createdAt,
        updatedAt: account.updatedAt,
      );
}
