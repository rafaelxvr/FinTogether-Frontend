import 'package:dartz/dartz.dart';
import '../../../../core/utils/failure.dart';
import '../entities/credit_card.dart';
import '../repositories/credit_card_repository.dart';

/// Get Credit Cards Use Case
class GetCreditCardsUseCase {
  final CreditCardRepository repository;

  GetCreditCardsUseCase(this.repository);

  Future<Either<Failure, List<CreditCard>>> call(
    String budgetId, {
    bool activeOnly = false,
  }) async {
    if (budgetId.isEmpty) {
      return const Left(ValidationFailure('Budget ID cannot be empty'));
    }
    return await repository.getCreditCards(budgetId, activeOnly: activeOnly);
  }
}

/// Create Credit Card Use Case
class CreateCreditCardUseCase {
  final CreditCardRepository repository;

  CreateCreditCardUseCase(this.repository);

  Future<Either<Failure, CreditCard>> call({
    required String budgetId,
    required String name,
    String? issuer,
    String? lastFour,
    String currency = 'BRL',
    required int statementCloseDay,
    required int dueDay,
    String? linkedAccountId,
  }) async {
    if (budgetId.isEmpty) {
      return const Left(ValidationFailure('Budget ID cannot be empty'));
    }
    if (name.trim().isEmpty) {
      return const Left(ValidationFailure('Name cannot be empty'));
    }
    if (statementCloseDay < 1 || statementCloseDay > 31) {
      return const Left(
          ValidationFailure('Statement close day must be between 1 and 31'));
    }
    if (dueDay < 1 || dueDay > 31) {
      return const Left(ValidationFailure('Due day must be between 1 and 31'));
    }

    return await repository.createCreditCard(
      budgetId: budgetId,
      name: name.trim(),
      issuer: issuer?.trim(),
      lastFour: lastFour?.trim(),
      currency: currency,
      statementCloseDay: statementCloseDay,
      dueDay: dueDay,
      linkedAccountId: linkedAccountId,
    );
  }
}

/// Update Credit Card Use Case
class UpdateCreditCardUseCase {
  final CreditCardRepository repository;

  UpdateCreditCardUseCase(this.repository);

  Future<Either<Failure, CreditCard>> call(
    String id, {
    String? name,
    String? issuer,
    String? lastFour,
    String? currency,
    int? statementCloseDay,
    int? dueDay,
    String? linkedAccountId,
  }) async {
    if (id.isEmpty) {
      return const Left(ValidationFailure('Credit card ID cannot be empty'));
    }

    if (name != null && name.trim().isEmpty) {
      return const Left(ValidationFailure('Name cannot be empty'));
    }

    if (statementCloseDay != null &&
        (statementCloseDay < 1 || statementCloseDay > 31)) {
      return const Left(
          ValidationFailure('Statement close day must be between 1 and 31'));
    }

    if (dueDay != null && (dueDay < 1 || dueDay > 31)) {
      return const Left(ValidationFailure('Due day must be between 1 and 31'));
    }

    return await repository.updateCreditCard(
      id,
      name: name?.trim(),
      issuer: issuer?.trim(),
      lastFour: lastFour?.trim(),
      currency: currency,
      statementCloseDay: statementCloseDay,
      dueDay: dueDay,
      linkedAccountId: linkedAccountId,
    );
  }
}

/// Delete Credit Card Use Case
class DeleteCreditCardUseCase {
  final CreditCardRepository repository;

  DeleteCreditCardUseCase(this.repository);

  Future<Either<Failure, void>> call(String id) async {
    if (id.isEmpty) {
      return const Left(ValidationFailure('Credit card ID cannot be empty'));
    }
    return await repository.deleteCreditCard(id);
  }
}

/// Toggle Status Use Case
class ToggleCreditCardStatusUseCase {
  final CreditCardRepository repository;

  ToggleCreditCardStatusUseCase(this.repository);

  Future<Either<Failure, CreditCard>> call(String id, bool active) async {
    if (id.isEmpty) {
      return const Left(ValidationFailure('Credit card ID cannot be empty'));
    }
    return await repository.toggleStatus(id, active);
  }
}
