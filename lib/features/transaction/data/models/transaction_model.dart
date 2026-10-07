import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/transaction.dart';

part 'transaction_model.g.dart';

@JsonSerializable()
class TransactionModel extends Transaction {
  @JsonKey(name: 'deleted_at')
  final DateTime? deletedAt;

  const TransactionModel({
    required super.id,
    required super.budgetId,
    super.userId,
    required super.transactionDate,
    required super.amount,
    required super.type,
    super.accountId,
    super.categoryId,
    super.cardId,
    super.description,
    super.notes,
    super.tags,
    required super.visibility,
    required super.isRecurring,
    super.recurrenceRule,
    required super.isInstallment,
    super.installmentGroupId,
    super.installmentNumber,
    super.parentRecurringId,
    super.merchantId,
    super.syncedAt,
    required super.createdAt,
    required super.updatedAt,
    this.deletedAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionModelToJson(this);

  Transaction toEntity() => Transaction(
        id: id,
        budgetId: budgetId,
        userId: userId,
        transactionDate: transactionDate,
        amount: amount,
        type: type,
        accountId: accountId,
        categoryId: categoryId,
        cardId: cardId,
        description: description,
        notes: notes,
        tags: tags,
        visibility: visibility,
        isRecurring: isRecurring,
        recurrenceRule: recurrenceRule,
        isInstallment: isInstallment,
        installmentGroupId: installmentGroupId,
        installmentNumber: installmentNumber,
        parentRecurringId: parentRecurringId,
        merchantId: merchantId,
        syncedAt: syncedAt,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
}
