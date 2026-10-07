import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/providers/theme_provider.dart';
import '../../../../shared/providers/accessibility_provider.dart';
import '../../../../shared/providers/locale_provider.dart';
import '../widgets/notification_settings_section.dart';

/// Settings page with theme, accessibility, and language toggles.
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final a11y = ref.watch(accessibilityProvider);
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: ListView(
        children: [
          // Appearance section
          _buildSectionHeader(context, l10n.appearance),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Icon(Icons.palette),
                const SizedBox(width: 16),
                Expanded(child: Text(l10n.theme)),
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.system,
                      label: Text(l10n.system),
                      icon: const Icon(Icons.settings_suggest),
                    ),
                    ButtonSegment(
                      value: ThemeMode.light,
                      label: Text(l10n.light),
                      icon: const Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      label: Text(l10n.dark),
                      icon: const Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (selection) {
                    ref.read(themeProvider.notifier).setThemeMode(selection.first);
                  },
                ),
              ],
            ),
          ),
          const Divider(),

          // Language section
          _buildSectionHeader(context, l10n.language),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(l10n.language),
            trailing: DropdownButton<String>(
              value: locale.languageCode,
              underline: const SizedBox.shrink(),
              items: [
                DropdownMenuItem(value: 'pt', child: Text(l10n.portuguese)),
                DropdownMenuItem(value: 'en', child: Text(l10n.english)),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(localeProvider.notifier).setLocale(Locale(val));
                }
              },
            ),
          ),
          const Divider(),

          // Accessibility section
          _buildSectionHeader(context, l10n.accessibility),
          SwitchListTile(
            secondary: const Icon(Icons.visibility),
            title: Text(l10n.reducedCognitiveLoad),
            subtitle: Text(l10n.reducedCognitiveLoadDescription),
            value: a11y.reducedCognitiveLoad,
            onChanged: (_) {
              ref.read(accessibilityProvider.notifier).toggleReducedMode();
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration),
            title: Text(l10n.hapticFeedback),
            subtitle: Text(l10n.hapticFeedbackDescription),
            value: a11y.hapticFeedback,
            onChanged: (_) {
              ref.read(accessibilityProvider.notifier).toggleHapticFeedback();
            },
          ),
          SwitchListTile(
            secondary: const Icon(Icons.center_focus_strong),
            title: Text(l10n.focusMode),
            subtitle: Text(l10n.focusModeDescription),
            value: a11y.focusModeEnabled,
            onChanged: (_) {
              ref.read(accessibilityProvider.notifier).toggleFocusMode();
            },
          ),
          const Divider(),

          // Notifications section
          _buildSectionHeader(context, l10n.notifications),
          const NotificationSettingsSection(),
          const Divider(),

          // Onboarding
          ListTile(
            leading: const Icon(Icons.replay),
            title: Text(l10n.replayOnboarding),
            onTap: () async {
              final prefs = getIt<SharedPreferences>();
              await prefs.setBool('onboarding_complete', false);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.onboardingWillShowNextLogin)),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
      ),
    );
  }
}
