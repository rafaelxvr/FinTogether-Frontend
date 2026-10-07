import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/member_balance.dart';

part 'member_balance_model.g.dart';

@JsonSerializable()
class MemberBalanceModel extends MemberBalance {
  const MemberBalanceModel({
    required super.userId,
    required super.userName,
    required super.owesTo,
    required super.owesToName,
    required super.netAmount,
  });

  factory MemberBalanceModel.fromJson(Map<String, dynamic> json) =>
      _$MemberBalanceModelFromJson(json);

  Map<String, dynamic> toJson() => _$MemberBalanceModelToJson(this);

  MemberBalance toEntity() => MemberBalance(
        userId: userId,
        userName: userName,
        owesTo: owesTo,
        owesToName: owesToName,
        netAmount: netAmount,
      );

  factory MemberBalanceModel.fromEntity(MemberBalance balance) =>
      MemberBalanceModel(
        userId: balance.userId,
        userName: balance.userName,
        owesTo: balance.owesTo,
        owesToName: balance.owesToName,
        netAmount: balance.netAmount,
      );
}
