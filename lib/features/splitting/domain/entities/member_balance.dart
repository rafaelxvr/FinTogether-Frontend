import 'package:equatable/equatable.dart';

class MemberBalance extends Equatable {
  final String userId;
  final String userName;
  final String owesTo;
  final String owesToName;
  final double netAmount;

  const MemberBalance({
    required this.userId,
    required this.userName,
    required this.owesTo,
    required this.owesToName,
    required this.netAmount,
  });

  bool get isDebtor => netAmount > 0;

  String get formattedAmount => 'R\$ ${netAmount.toStringAsFixed(2)}';

  @override
  List<Object?> get props => [
        userId,
        userName,
        owesTo,
        owesToName,
        netAmount,
      ];

  MemberBalance copyWith({
    String? userId,
    String? userName,
    String? owesTo,
    String? owesToName,
    double? netAmount,
  }) {
    return MemberBalance(
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      owesTo: owesTo ?? this.owesTo,
      owesToName: owesToName ?? this.owesToName,
      netAmount: netAmount ?? this.netAmount,
    );
  }
}
