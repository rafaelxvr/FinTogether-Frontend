import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/transaction_split.dart';

part 'transaction_split_model.g.dart';

@JsonSerializable()
class TransactionSplitModel extends TransactionSplit {
  const TransactionSplitModel({
    required super.id,
    required super.transactionId,
    required super.userId,
    required super.userName,
    required super.amount,
    super.isPaid,
    super.paidAt,
    required super.createdAt,
  });

  factory TransactionSplitModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionSplitModelFromJson(json);

  Map<String, dynamic> toJson() => _$TransactionSplitModelToJson(this);

  TransactionSplit toEntity() => TransactionSplit(
        id: id,
        transactionId: transactionId,
        userId: userId,
        userName: userName,
        amount: amount,
        isPaid: isPaid,
        paidAt: paidAt,
        createdAt: createdAt,
      );

  factory TransactionSplitModel.fromEntity(TransactionSplit split) =>
      TransactionSplitModel(
        id: split.id,
        transactionId: split.transactionId,
        userId: split.userId,
        userName: split.userName,
        amount: split.amount,
        isPaid: split.isPaid,
        paidAt: split.paidAt,
        createdAt: split.createdAt,
      );
}
