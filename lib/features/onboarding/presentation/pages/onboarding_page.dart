import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/injection.dart';
import '../widgets/onboarding_step.dart';

/// First-launch onboarding flow with 4 steps.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _currentPage = 0;
  static const _totalPages = 4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _complete,
                child: Text(l10n.skip),
              ),
            ),
            // Pages
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                children: [
                  OnboardingStep(
                    icon: Icons.account_balance_wallet,
                    color: Colors.blue,
                    title: l10n.onboardingWelcome,
                    description: l10n.onboardingWelcomeDesc,
                  ),
                  OnboardingStep(
                    icon: Icons.pie_chart,
                    color: Colors.green,
                    title: l10n.onboardingBudget,
                    description: l10n.onboardingBudgetDesc,
                  ),
                  OnboardingStep(
                    icon: Icons.receipt_long,
                    color: Colors.orange,
                    title: l10n.onboardingTrack,
                    description: l10n.onboardingTrackDesc,
                  ),
                  OnboardingStep(
                    icon: Icons.group,
                    color: Colors.purple,
                    title: l10n.onboardingShare,
                    description: l10n.onboardingShareDesc,
                  ),
                ],
              ),
            ),
            // Dots + button
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Dots
                  Row(
                    children: List.generate(_totalPages, (index) {
                      return Container(
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Theme.of(context).colorScheme.primary
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  // Button
                  _currentPage == _totalPages - 1
                      ? ElevatedButton(
                          onPressed: _complete,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 16,
                            ),
                          ),
                          child: Text(l10n.getStarted),
                        )
                      : ElevatedButton(
                          onPressed: () {
                            _controller.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(l10n.next),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _complete() async {
    final prefs = getIt<SharedPreferences>();
    await prefs.setBool('onboarding_complete', true);
    if (mounted) {
      context.go('/dashboard');
    }
  }
}
