import 'package:equatable/equatable.dart';
import '../../../transaction/domain/entities/transaction.dart';

class BulkCreateResult extends Equatable {
  final List<Transaction> created;
  final List<BulkCreateError> failed;

  const BulkCreateResult({
    required this.created,
    required this.failed,
  });

  int get successCount => created.length;
  int get failureCount => failed.length;
  bool get hasFailures => failed.isNotEmpty;
  bool get allSucceeded => failed.isEmpty;

  @override
  List<Object?> get props => [created, failed];
}

class BulkCreateError extends Equatable {
  final int index;
  final String error;

  const BulkCreateError({
    required this.index,
    required this.error,
  });

  @override
  List<Object?> get props => [index, error];
}
