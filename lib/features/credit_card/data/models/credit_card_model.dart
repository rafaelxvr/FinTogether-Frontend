import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/credit_card.dart';

part 'credit_card_model.g.dart';

/// Credit Card Model
/// JSON serializable model for API communication
@JsonSerializable()
class CreditCardModel {
  final String id;
  final String budgetId;
  final String name;
  final String? issuer;
  final String? lastFour;
  final String currency;
  final int statementCloseDay;
  final int dueDay;
  final String? linkedAccountId;
  final String? linkedAccountName;
  @JsonKey(name: 'credit_limit')
  final double? creditLimit;
  final bool active;
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String? updatedAt;
  @JsonKey(name: 'deleted_at')
  final String? deletedAt;

  CreditCardModel({
    required this.id,
    required this.budgetId,
    required this.name,
    this.issuer,
    this.lastFour,
    required this.currency,
    required this.statementCloseDay,
    required this.dueDay,
    this.linkedAccountId,
    this.linkedAccountName,
    this.creditLimit,
    required this.active,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
  });

  factory CreditCardModel.fromJson(Map<String, dynamic> json) =>
      _$CreditCardModelFromJson(json);

  Map<String, dynamic> toJson() => _$CreditCardModelToJson(this);

  /// Convert to domain entity
  CreditCard toEntity() {
    return CreditCard(
      id: id,
      budgetId: budgetId,
      name: name,
      issuer: issuer,
      lastFour: lastFour,
      currency: currency,
      statementCloseDay: statementCloseDay,
      dueDay: dueDay,
      linkedAccountId: linkedAccountId,
      linkedAccountName: linkedAccountName,
      creditLimit: creditLimit,
      active: active,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }

  /// Create from domain entity
  factory CreditCardModel.fromEntity(CreditCard card) {
    return CreditCardModel(
      id: card.id,
      budgetId: card.budgetId,
      name: card.name,
      issuer: card.issuer,
      lastFour: card.lastFour,
      currency: card.currency,
      statementCloseDay: card.statementCloseDay,
      dueDay: card.dueDay,
      linkedAccountId: card.linkedAccountId,
      linkedAccountName: card.linkedAccountName,
      creditLimit: card.creditLimit,
      active: card.active,
      createdAt: card.createdAt.toIso8601String(),
      updatedAt: card.updatedAt?.toIso8601String(),
    );
  }
}
