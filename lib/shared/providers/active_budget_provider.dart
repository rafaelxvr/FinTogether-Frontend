import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/di/injection.dart';

/// Manages the currently active budget selection across all tabs.
class ActiveBudgetNotifier extends StateNotifier<String?> {
  final SharedPreferences _prefs;
  static const _key = 'active_budget_id';

  ActiveBudgetNotifier({required SharedPreferences prefs})
      : _prefs = prefs,
        super(null) {
    // Load persisted selection
    state = _prefs.getString(_key);
  }

  void setActiveBudget(String budgetId) {
    state = budgetId;
    _prefs.setString(_key, budgetId);
  }

  void clearActiveBudget() {
    state = null;
    _prefs.remove(_key);
  }

  /// Auto-select first budget if none is selected
  void autoSelectIfNeeded(List<dynamic> budgets) {
    if (state == null && budgets.isNotEmpty) {
      setActiveBudget(budgets[0].id);
    }
  }
}

final activeBudgetProvider =
    StateNotifierProvider<ActiveBudgetNotifier, String?>((ref) {
  return ActiveBudgetNotifier(prefs: getIt<SharedPreferences>());
});
