import 'package:equatable/equatable.dart';
import '../../domain/entities/batch_session.dart';
import '../../domain/entities/bulk_create_result.dart';

abstract class BatchEntryState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BatchEntryIdle extends BatchEntryState {
  final BatchSession session;

  BatchEntryIdle(this.session);

  @override
  List<Object?> get props => [session];
}

class BatchEntrySubmitting extends BatchEntryState {
  final BatchSession session;

  BatchEntrySubmitting(this.session);

  @override
  List<Object?> get props => [session];
}

class BatchEntryCompleted extends BatchEntryState {
  final BulkCreateResult result;
  final BatchSession session;

  BatchEntryCompleted({
    required this.result,
    required this.session,
  });

  int get successCount => result.successCount;
  int get failCount => result.failureCount;

  @override
  List<Object?> get props => [result, session];
}

class BatchEntryError extends BatchEntryState {
  final String message;
  final BatchSession session;

  BatchEntryError({
    required this.message,
    required this.session,
  });

  @override
  List<Object?> get props => [message, session];
}
