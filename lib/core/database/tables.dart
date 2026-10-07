import 'package:drift/drift.dart';

// Users Table
class Users extends Table {
  TextColumn get id => text()();
  TextColumn get email => text().unique()();
  TextColumn get name => text()();
  TextColumn get locale => text().withDefault(const Constant('pt-BR'))();
  TextColumn get settings => text().nullable()(); // JSON
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Budgets Table
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get ownerId => text().references(Users, #id)();
  TextColumn get type => text()(); // 'personal' or 'shared'
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Budget Members Table
class BudgetMembers extends Table {
  TextColumn get id => text()();
  TextColumn get budgetId => text().references(Budgets, #id, onDelete: KeyAction.cascade)();
  TextColumn get userId => text().references(Users, #id, onDelete: KeyAction.cascade)();
  TextColumn get role => text()(); // 'owner', 'member', 'viewer'
  DateTimeColumn get joinedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [{budgetId, userId}];
}

// Categories Table
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get budgetId => text().references(Budgets, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get type => text()(); // 'income', 'expense', 'transfer'
  TextColumn get parentId => text().nullable().references(Categories, #id)();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  RealColumn get limitAmount => real().nullable()();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Accounts Table
class Accounts extends Table {
  TextColumn get id => text()();
  TextColumn get budgetId => text().references(Budgets, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get type => text()(); // 'cash', 'checking', 'savings', 'credit_card', 'investment'
  TextColumn get currency => text().withDefault(const Constant('BRL'))();
  RealColumn get openingBalance => real().withDefault(const Constant(0.0))();
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Credit Cards Table
class CreditCards extends Table {
  TextColumn get id => text()();
  TextColumn get budgetId => text().references(Budgets, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get issuer => text().nullable()();
  TextColumn get lastFour => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('BRL'))();
  IntColumn get statementCloseDay => integer()();
  IntColumn get dueDay => integer()();
  TextColumn get linkedAccountId => text().nullable().references(Accounts, #id)();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Merchants Table
class Merchants extends Table {
  TextColumn get id => text()();
  TextColumn get budgetId => text().references(Budgets, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get displayName => text().nullable()();
  TextColumn get logoUrl => text().nullable()();
  TextColumn get color => text().nullable()();
  TextColumn get defaultCategoryId => text().nullable().references(Categories, #id)();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Transactions Table
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get budgetId => text().references(Budgets, #id, onDelete: KeyAction.cascade)();
  TextColumn get userId => text().nullable().references(Users, #id)();
  DateTimeColumn get transactionDate => dateTime()();
  RealColumn get amount => real()();
  TextColumn get type => text()(); // 'income', 'expense', 'transfer'
  TextColumn get accountId => text().nullable().references(Accounts, #id)();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();
  TextColumn get cardId => text().nullable().references(CreditCards, #id)();
  TextColumn get merchantId => text().nullable().references(Merchants, #id)();
  TextColumn get description => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get tags => text().nullable()(); // JSON array
  TextColumn get visibility => text().withDefault(const Constant('shared'))(); // 'private', 'shared'
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurrenceRule => text().nullable()(); // JSON
  BoolColumn get isInstallment => boolean().withDefault(const Constant(false))();
  TextColumn get installmentGroupId => text().nullable()();
  IntColumn get installmentNumber => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Installment Groups Table
class InstallmentGroups extends Table {
  TextColumn get id => text()();
  TextColumn get budgetId => text().references(Budgets, #id, onDelete: KeyAction.cascade)();
  TextColumn get cardId => text().nullable().references(CreditCards, #id)();
  RealColumn get totalAmount => real()();
  IntColumn get installmentCount => integer()();
  RealColumn get interestRate => real().withDefault(const Constant(0.0))();
  DateTimeColumn get startDate => dateTime()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Pending Syncs Table
class PendingSyncs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()();
  TextColumn get entityId => text()();
  TextColumn get operation => text()();
  TextColumn get payload => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  BoolColumn get failed => boolean().withDefault(const Constant(false))();
}

// Savings Goals Table
class SavingsGoals extends Table {
  TextColumn get id => text()();
  TextColumn get budgetId => text().references(Budgets, #id, onDelete: KeyAction.cascade)();
  TextColumn get accountId => text().nullable().references(Accounts, #id)();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get targetAmount => real()();
  RealColumn get currentAmount => real().withDefault(const Constant(0.0))();
  TextColumn get currency => text().withDefault(const Constant('BRL'))();
  DateTimeColumn get deadline => dateTime().nullable()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  BoolColumn get active => boolean().withDefault(const Constant(true))();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Savings Goal Contributions Table
class SavingsGoalContributions extends Table {
  TextColumn get id => text()();
  TextColumn get savingsGoalId => text().references(SavingsGoals, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get contributedAt => dateTime().withDefault(currentDateAndTime)();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

// Transaction Splits Table
class TransactionSplits extends Table {
  TextColumn get id => text()();
  TextColumn get transactionId => text().references(Transactions, #id, onDelete: KeyAction.cascade)();
  TextColumn get userId => text()();
  TextColumn get userName => text()();
  RealColumn get amount => real()();
  BoolColumn get isPaid => boolean().withDefault(const Constant(false))();
  DateTimeColumn get paidAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().nullable()();
  DateTimeColumn get deletedAt => dateTime().nullable()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [{transactionId, userId}];
}

// Sync Logs Table
class SyncLogs extends Table {
  TextColumn get entityType => text()();
  DateTimeColumn get lastSyncedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {entityType};
}
