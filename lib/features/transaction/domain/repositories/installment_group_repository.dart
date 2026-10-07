import 'package:dartz/dartz.dart';

import '../../../../core/utils/failure.dart';
import '../entities/installment_group.dart';
import '../entities/installment_progress.dart';

abstract class InstallmentGroupRepository {
  /// Create a new installment group with auto-generated transactions
  Future<Either<Failure, InstallmentGroup>> createInstallmentGroup({
    required String budgetId,
    required double totalAmount,
    required int installmentCount,
    double interestRate = 0,
    required DateTime startDate,
    String? description,
    String? categoryId,
    String? accountId,
    String? cardId,
  });

  /// Get all installment groups for a budget
  Future<Either<Failure, List<InstallmentGroup>>> getInstallmentGroups(
      String budgetId);

  /// Get installment progress including paid/remaining details
  Future<Either<Failure, InstallmentProgress>> getInstallmentProgress(
      String groupId);

  /// Delete an installment group and its associated transactions
  Future<Either<Failure, void>> deleteInstallmentGroup(String groupId);
}
