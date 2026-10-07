import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/dashboard_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/budget/presentation/pages/budget_list_page.dart';
import '../../features/budget/presentation/pages/budget_details_page.dart';
import '../../features/account/presentation/pages/account_list_page.dart';
import '../../features/account/presentation/pages/transfer_page.dart';
import '../../features/category/presentation/pages/category_list_page.dart';
import '../../features/transaction/presentation/pages/transaction_list_page.dart';
import '../../features/transaction/presentation/pages/transaction_form_page.dart';
import '../../features/credit_card/presentation/pages/credit_card_list_page.dart';
import '../../features/credit_card/presentation/pages/invoice_detail_page.dart';
import '../../features/credit_card/presentation/pages/invoice_list_page.dart';
import '../../features/dashboard/presentation/pages/analytics_dashboard_page.dart';
import '../../features/transaction/presentation/pages/installment_groups_page.dart';
import '../../features/transaction/presentation/pages/create_installment_page.dart';
import '../../features/transaction/presentation/pages/installment_progress_page.dart';
import '../../features/batch_entry/presentation/pages/batch_entry_page.dart';
import '../../features/savings_goal/presentation/pages/savings_goal_list_page.dart';
import '../../features/savings_goal/presentation/pages/savings_goal_detail_page.dart';
import '../../features/savings_goal/presentation/pages/create_savings_goal_page.dart';
import '../../features/savings_goal/domain/entities/savings_goal.dart';
import '../../features/merchant/presentation/pages/merchant_list_page.dart';
import '../../features/merchant/presentation/pages/merchant_details_page.dart';
import '../../features/recurring/domain/entities/recurring_transaction_template.dart';
import '../../features/recurring/presentation/pages/recurring_template_list_page.dart';
import '../../features/recurring/presentation/pages/recurring_template_form_page.dart';
import '../../features/recurring/presentation/pages/fixed_expense_list_page.dart';
import '../../features/settings/presentation/pages/more_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/budget_allocation/presentation/pages/budget_plan_page.dart';
import '../../features/budget_allocation/presentation/pages/allocation_form_page.dart';
import '../../shared/widgets/scaffold_with_nav_bar.dart';
import '../../features/transaction/domain/entities/transaction.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    // Authentication Routes (outside shell)
    GoRoute(
      path: '/',
      name: 'splash',
      pageBuilder: (context, state) => const MaterialPage(child: SplashPage()),
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      pageBuilder: (context, state) => const MaterialPage(child: LoginPage()),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      pageBuilder: (context, state) => const MaterialPage(child: RegisterPage()),
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      pageBuilder: (context, state) => const MaterialPage(child: OnboardingPage()),
    ),

    // Main app with bottom navigation
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          ScaffoldWithNavBar(navigationShell: navigationShell),
      branches: [
        // Branch 0: Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/dashboard',
              name: 'dashboard',
              pageBuilder: (context, state) =>
                  const MaterialPage(child: DashboardPage()),
            ),
          ],
        ),
        // Branch 1: Transactions
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/transactions',
              name: 'transactions',
              pageBuilder: (context, state) {
                final budgetId = state.uri.queryParameters['budgetId'];
                return MaterialPage(
                  child: TransactionListPage(budgetId: budgetId ?? ''),
                );
              },
            ),
          ],
        ),
        // Branch 2: Credit Cards
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cards',
              name: 'credit-cards',
              pageBuilder: (context, state) {
                final budgetId = state.uri.queryParameters['budgetId'];
                return MaterialPage(
                  child: CreditCardListPage(budgetId: budgetId ?? ''),
                );
              },
            ),
          ],
        ),
        // Branch 3: Accounts
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/accounts',
              name: 'accounts',
              pageBuilder: (context, state) {
                final budgetId = state.uri.queryParameters['budgetId'];
                return MaterialPage(
                  child: AccountListPage(budgetId: budgetId ?? ''),
                );
              },
            ),
          ],
        ),
        // Branch 4: More
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/more',
              name: 'more',
              pageBuilder: (context, state) =>
                  const MaterialPage(child: MorePage()),
            ),
          ],
        ),
      ],
    ),

    // Routes outside shell (push over the nav bar)
    GoRoute(
      path: '/more/settings',
      name: 'settings',
      pageBuilder: (context, state) =>
          const MaterialPage(child: SettingsPage()),
    ),
    GoRoute(
      path: '/transactions/create',
      name: 'create-transaction',
      pageBuilder: (context, state) {
        final budgetId = state.extra as String? ?? '';
        return MaterialPage(
          child: TransactionFormPage(budgetId: budgetId),
        );
      },
    ),
    GoRoute(
      path: '/transactions/:id/edit',
      name: 'edit-transaction',
      pageBuilder: (context, state) {
        final transaction = state.extra as Transaction?;
        return MaterialPage(
          child: TransactionFormPage(
            budgetId: transaction?.budgetId ?? '',
            transaction: transaction,
          ),
        );
      },
    ),
    GoRoute(
      path: '/budgets',
      name: 'budgets',
      pageBuilder: (context, state) =>
          const MaterialPage(child: BudgetListPage()),
    ),
    GoRoute(
      path: '/budgets/:id/details',
      name: 'budget-details',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['id']!;
        return MaterialPage(child: BudgetDetailsPage(budgetId: budgetId));
      },
    ),
    GoRoute(
      path: '/budgets/:budgetId/accounts',
      name: 'budget-accounts',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        return MaterialPage(child: AccountListPage(budgetId: budgetId));
      },
    ),
    GoRoute(
      path: '/budgets/:budgetId/accounts/transfer',
      name: 'transfer',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        return MaterialPage(child: TransferPage(budgetId: budgetId));
      },
    ),
    GoRoute(
      path: '/budgets/:budgetId/categories',
      name: 'budget-categories',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        return MaterialPage(child: CategoryListPage(budgetId: budgetId));
      },
    ),
    GoRoute(
      path: '/categories',
      name: 'categories',
      pageBuilder: (context, state) =>
          const MaterialPage(child: CategoryListPage(budgetId: '')),
    ),
    GoRoute(
      path: '/budgets/:budgetId/transactions',
      name: 'budget-transactions',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        return MaterialPage(child: TransactionListPage(budgetId: budgetId));
      },
    ),
    GoRoute(
      path: '/budgets/:budgetId/credit-cards',
      name: 'budget-credit-cards',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        return MaterialPage(child: CreditCardListPage(budgetId: budgetId));
      },
    ),
    GoRoute(
      path: '/credit-cards/:id/invoice',
      name: 'credit-card-invoice',
      pageBuilder: (context, state) {
        final cardId = state.pathParameters['id']!;
        final month = state.uri.queryParameters['month'];
        return MaterialPage(child: InvoiceDetailPage(cardId: cardId, month: month));
      },
    ),
    GoRoute(
      path: '/credit-cards/:id/invoices',
      name: 'credit-card-invoices',
      pageBuilder: (context, state) {
        final cardId = state.pathParameters['id']!;
        final cardName = state.uri.queryParameters['cardName'];
        return MaterialPage(child: InvoiceListPage(cardId: cardId, cardName: cardName));
      },
    ),
    GoRoute(
      path: '/budgets/:budgetId/installments',
      name: 'installments',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        return MaterialPage(child: InstallmentGroupsPage(budgetId: budgetId));
      },
    ),
    GoRoute(
      path: '/budgets/:budgetId/installments/create',
      name: 'create-installment',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        return MaterialPage(child: CreateInstallmentPage(budgetId: budgetId));
      },
    ),
    GoRoute(
      path: '/installments/:groupId',
      name: 'installment-progress',
      pageBuilder: (context, state) {
        final groupId = state.pathParameters['groupId']!;
        return MaterialPage(child: InstallmentProgressPage(groupId: groupId));
      },
    ),
    GoRoute(
      path: '/budgets/:budgetId/batch-entry',
      name: 'batch-entry',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        return MaterialPage(child: BatchEntryPage(budgetId: budgetId));
      },
    ),
    GoRoute(
      path: '/recurring-templates',
      name: 'recurring-templates-standalone',
      pageBuilder: (context, state) =>
          const MaterialPage(child: RecurringTemplateListPage(budgetId: '')),
    ),
    GoRoute(
      path: '/budgets/:budgetId/recurring-templates',
      name: 'recurring-templates',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        return MaterialPage(child: RecurringTemplateListPage(budgetId: budgetId));
      },
    ),
    GoRoute(
      path: '/budgets/:budgetId/recurring-templates/new',
      name: 'create-recurring-template',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        return MaterialPage(child: RecurringTemplateFormPage(budgetId: budgetId));
      },
    ),
    GoRoute(
      path: '/budgets/:budgetId/recurring-templates/:id/edit',
      name: 'edit-recurring-template',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        final template = state.extra as RecurringTransactionTemplate?;
        return MaterialPage(
          child: RecurringTemplateFormPage(budgetId: budgetId, template: template),
        );
      },
    ),
    GoRoute(
      path: '/budgets/:budgetId/fixed-expenses',
      name: 'fixed-expenses',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        return MaterialPage(child: FixedExpenseListPage(budgetId: budgetId));
      },
    ),
    GoRoute(
      path: '/budgets/:budgetId/savings-goals',
      name: 'savings-goals',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        return MaterialPage(child: SavingsGoalListPage(budgetId: budgetId));
      },
    ),
    GoRoute(
      path: '/budgets/:budgetId/savings-goals/create',
      name: 'create-savings-goal',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        return MaterialPage(child: CreateSavingsGoalPage(budgetId: budgetId));
      },
    ),
    GoRoute(
      path: '/savings-goals/:id',
      name: 'savings-goal-detail',
      pageBuilder: (context, state) {
        final goalId = state.pathParameters['id']!;
        final budgetId = state.uri.queryParameters['budgetId'] ?? '';
        return MaterialPage(child: SavingsGoalDetailPage(goalId: goalId, budgetId: budgetId));
      },
    ),
    GoRoute(
      path: '/savings-goals/:id/edit',
      name: 'edit-savings-goal',
      pageBuilder: (context, state) {
        final budgetId = state.uri.queryParameters['budgetId'] ?? '';
        final goal = state.extra as SavingsGoal?;
        return MaterialPage(child: CreateSavingsGoalPage(budgetId: budgetId, goal: goal));
      },
    ),
    GoRoute(
      path: '/budgets/:budgetId/merchants',
      name: 'merchants',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        return MaterialPage(child: MerchantListPage(budgetId: budgetId));
      },
    ),
    GoRoute(
      path: '/budgets/:budgetId/merchants/:id',
      name: 'merchant-details',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        final merchantId = state.pathParameters['id']!;
        return MaterialPage(
          child: MerchantDetailsPage(budgetId: budgetId, merchantId: merchantId),
        );
      },
    ),
    GoRoute(
      path: '/budgets/:budgetId/budget-plan',
      name: 'budget-plan',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        return MaterialPage(child: BudgetPlanPage(budgetId: budgetId));
      },
    ),
    GoRoute(
      path: '/budgets/:budgetId/budget-plan/edit',
      name: 'edit-allocations',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        final month = state.uri.queryParameters['month'];
        return MaterialPage(child: AllocationFormPage(budgetId: budgetId, month: month));
      },
    ),
    GoRoute(
      path: '/budgets/:budgetId/analytics',
      name: 'analytics',
      pageBuilder: (context, state) {
        final budgetId = state.pathParameters['budgetId']!;
        return MaterialPage(child: AnalyticsDashboardPage(budgetId: budgetId));
      },
    ),
  ],
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Text('Page not found: ${state.uri}'),
    ),
  ),
);
