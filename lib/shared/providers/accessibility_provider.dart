import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/di/injection.dart';

/// Accessibility preferences state
class AccessibilityPreferences extends Equatable {
  final bool reducedCognitiveLoad;
  final bool hapticFeedback;
  final bool focusModeEnabled;

  const AccessibilityPreferences({
    this.reducedCognitiveLoad = false,
    this.hapticFeedback = true,
    this.focusModeEnabled = false,
  });

  AccessibilityPreferences copyWith({
    bool? reducedCognitiveLoad,
    bool? hapticFeedback,
    bool? focusModeEnabled,
  }) {
    return AccessibilityPreferences(
      reducedCognitiveLoad: reducedCognitiveLoad ?? this.reducedCognitiveLoad,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      focusModeEnabled: focusModeEnabled ?? this.focusModeEnabled,
    );
  }

  @override
  List<Object?> get props => [reducedCognitiveLoad, hapticFeedback, focusModeEnabled];
}

/// Manages accessibility preferences with SharedPreferences persistence.
class AccessibilityNotifier extends StateNotifier<AccessibilityPreferences> {
  final SharedPreferences _prefs;

  AccessibilityNotifier({required SharedPreferences prefs})
      : _prefs = prefs,
        super(const AccessibilityPreferences()) {
    _load();
  }

  void _load() {
    state = AccessibilityPreferences(
      reducedCognitiveLoad: _prefs.getBool('accessibility_reduced_mode') ?? false,
      hapticFeedback: _prefs.getBool('accessibility_haptic') ?? true,
      focusModeEnabled: _prefs.getBool('accessibility_focus_mode') ?? false,
    );
  }

  void toggleReducedMode() {
    final newVal = !state.reducedCognitiveLoad;
    state = state.copyWith(reducedCognitiveLoad: newVal);
    _prefs.setBool('accessibility_reduced_mode', newVal);
  }

  void toggleHapticFeedback() {
    final newVal = !state.hapticFeedback;
    state = state.copyWith(hapticFeedback: newVal);
    _prefs.setBool('accessibility_haptic', newVal);
  }

  void toggleFocusMode() {
    final newVal = !state.focusModeEnabled;
    state = state.copyWith(focusModeEnabled: newVal);
    _prefs.setBool('accessibility_focus_mode', newVal);
  }
}

final accessibilityProvider =
    StateNotifierProvider<AccessibilityNotifier, AccessibilityPreferences>(
        (ref) {
  return AccessibilityNotifier(prefs: getIt<SharedPreferences>());
});
