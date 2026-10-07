import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/installment_progress.dart';
import 'installment_group_model.dart';
import 'transaction_model.dart';

part 'installment_progress_model.g.dart';

@JsonSerializable()
class InstallmentProgressModel {
  final InstallmentGroupModel group;

  @JsonKey(name: 'paid_count')
  final int paidCount;

  @JsonKey(name: 'paid_amount')
  final double paidAmount;

  @JsonKey(name: 'remaining_count')
  final int remainingCount;

  @JsonKey(name: 'remaining_amount')
  final double remainingAmount;

  final List<TransactionModel> transactions;

  const InstallmentProgressModel({
    required this.group,
    required this.paidCount,
    required this.paidAmount,
    required this.remainingCount,
    required this.remainingAmount,
    required this.transactions,
  });

  factory InstallmentProgressModel.fromJson(Map<String, dynamic> json) =>
      _$InstallmentProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$InstallmentProgressModelToJson(this);

  InstallmentProgress toEntity() => InstallmentProgress(
        group: group.toEntity(),
        paidCount: paidCount,
        paidAmount: paidAmount,
        remainingCount: remainingCount,
        remainingAmount: remainingAmount,
        transactions: transactions.map((t) => t.toEntity()).toList(),
      );
}
