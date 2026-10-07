import 'package:drift/drift.dart';

import 'connection/database_connection.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Users,
  Budgets,
  BudgetMembers,
  Categories,
  Merchants,
  Accounts,
  CreditCards,
  Transactions,
  InstallmentGroups,
  PendingSyncs,
  SyncLogs,
  SavingsGoals,
  SavingsGoalContributions,
  TransactionSplits,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  static Future<AppDatabase> create() async {
    final executor = await openConnection();
    return AppDatabase(executor);
  }

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        if (from < 5) {
          await m.createTable(transactionSplits);
        }
        if (from < 4) {
          await m.createTable(merchants);
          await m.addColumn(transactions, transactions.merchantId);
        }
        if (from < 3) {
          await m.createTable(savingsGoals);
          await m.createTable(savingsGoalContributions);
        }
        if (from < 2) {
          await m.addColumn(accounts, accounts.updatedAt);
          await m.addColumn(creditCards, creditCards.updatedAt);
          await m.addColumn(categories, categories.updatedAt);
          await m.addColumn(budgetMembers, budgetMembers.updatedAt);
          await m.addColumn(installmentGroups, installmentGroups.updatedAt);

          await m.addColumn(users, users.deletedAt);
          await m.addColumn(budgets, budgets.deletedAt);
          await m.addColumn(budgetMembers, budgetMembers.deletedAt);
          await m.addColumn(accounts, accounts.deletedAt);
          await m.addColumn(categories, categories.deletedAt);
          await m.addColumn(creditCards, creditCards.deletedAt);
          await m.addColumn(transactions, transactions.deletedAt);
          await m.addColumn(installmentGroups, installmentGroups.deletedAt);

          await m.createTable(pendingSyncs);
          await m.createTable(syncLogs);

          await customStatement(
            'CREATE UNIQUE INDEX IF NOT EXISTS idx_budget_members_budget_user '
            'ON budget_members (budget_id, user_id)',
          );
        }
      },
    );
  }
}
