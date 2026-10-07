import 'package:equatable/equatable.dart';

import '../../domain/entities/installment_group.dart';
import '../../domain/entities/installment_progress.dart';

/// Installment Group State
abstract class InstallmentGroupState extends Equatable {
  const InstallmentGroupState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class InstallmentGroupInitial extends InstallmentGroupState {
  const InstallmentGroupInitial();
}

/// Loading state
class InstallmentGroupLoading extends InstallmentGroupState {
  const InstallmentGroupLoading();
}

/// Loaded state with list of installment groups
class InstallmentGroupsLoaded extends InstallmentGroupState {
  final List<InstallmentGroup> groups;

  const InstallmentGroupsLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

/// State after successfully creating an installment group
class InstallmentGroupCreated extends InstallmentGroupState {
  final InstallmentGroup group;

  const InstallmentGroupCreated(this.group);

  @override
  List<Object?> get props => [group];
}

/// State with loaded installment progress
class InstallmentProgressLoaded extends InstallmentGroupState {
  final InstallmentProgress progress;

  const InstallmentProgressLoaded(this.progress);

  @override
  List<Object?> get props => [progress];
}

/// State after successfully deleting an installment group
class InstallmentGroupDeleted extends InstallmentGroupState {
  const InstallmentGroupDeleted();
}

/// Error state
class InstallmentGroupError extends InstallmentGroupState {
  final String message;

  const InstallmentGroupError(this.message);

  @override
  List<Object?> get props => [message];
}
