import 'package:equatable/equatable.dart';
import '../../domain/entities/card_monthly_cost.dart';

abstract class CardCostState extends Equatable {
  const CardCostState();

  @override
  List<Object?> get props => [];
}

class CardCostInitial extends CardCostState {
  const CardCostInitial();
}

class CardCostLoading extends CardCostState {
  const CardCostLoading();
}

class CardCostLoaded extends CardCostState {
  final AllCardsCostSummary? costSummary;
  final CardCostComparison? comparison;

  const CardCostLoaded({this.costSummary, this.comparison});

  @override
  List<Object?> get props => [costSummary, comparison];

  CardCostLoaded copyWith({
    AllCardsCostSummary? costSummary,
    CardCostComparison? comparison,
  }) {
    return CardCostLoaded(
      costSummary: costSummary ?? this.costSummary,
      comparison: comparison ?? this.comparison,
    );
  }
}

class CardCostError extends CardCostState {
  final String message;

  const CardCostError(this.message);

  @override
  List<Object?> get props => [message];
}
