import 'package:flutter/material.dart';

/// Circular progress indicator with text overlay showing installment progress.
class InstallmentProgressIndicator extends StatelessWidget {
  final int paidCount;
  final int totalCount;
  final double size;
  final double strokeWidth;
  final Color? progressColor;
  final Color? backgroundColor;

  const InstallmentProgressIndicator({
    super.key,
    required this.paidCount,
    required this.totalCount,
    this.size = 80,
    this.strokeWidth = 6,
    this.progressColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final progress = totalCount > 0 ? paidCount / totalCount : 0.0;
    final effectiveProgressColor =
        progressColor ?? Theme.of(context).colorScheme.primary;
    final effectiveBackgroundColor = backgroundColor ?? Colors.grey[300]!;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              valueColor:
                  AlwaysStoppedAnimation<Color>(effectiveProgressColor),
              backgroundColor: effectiveBackgroundColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$paidCount/$totalCount',
                style: TextStyle(
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.bold,
                  color: effectiveProgressColor,
                ),
              ),
              Text(
                'paid',
                style: TextStyle(
                  fontSize: size * 0.12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
