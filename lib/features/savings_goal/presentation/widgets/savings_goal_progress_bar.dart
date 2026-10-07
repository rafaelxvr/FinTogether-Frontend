import 'package:flutter/material.dart';

class SavingsGoalProgressBar extends StatelessWidget {
  final double currentAmount;
  final double targetAmount;
  final Color? color;
  final double height;

  const SavingsGoalProgressBar({
    super.key,
    required this.currentAmount,
    required this.targetAmount,
    this.color,
    this.height = 20,
  });

  double get _progress {
    if (targetAmount <= 0) return 0.0;
    return (currentAmount / targetAmount).clamp(0.0, 1.0);
  }

  int get _percent => (_progress * 100).toInt();

  Color get _progressColor {
    if (color != null) return color!;
    if (_progress >= 1.0) return const Color(0xFFFFD700); // Gold
    if (_progress >= 0.5) return Colors.green;
    if (_progress > 0) return Colors.blue;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            // Background
            Container(
              height: height,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            // Progress fill
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: height,
              width: double.infinity,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: _progress,
                child: Container(
                  decoration: BoxDecoration(
                    color: _progressColor,
                    borderRadius: BorderRadius.circular(height / 2),
                    boxShadow: _progress >= 1.0
                        ? [
                            BoxShadow(
                              color: _progressColor.withOpacity(0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                ),
              ),
            ),
            // Percentage text overlay
            if (height >= 16)
              Positioned.fill(
                child: Center(
                  child: Text(
                    '$_percent%',
                    style: TextStyle(
                      fontSize: height * 0.55,
                      fontWeight: FontWeight.bold,
                      color: _progress > 0.4 ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
