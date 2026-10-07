import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AmountKeypad extends StatefulWidget {
  final ValueChanged<double> onAmountChanged;

  const AmountKeypad({
    super.key,
    required this.onAmountChanged,
  });

  @override
  State<AmountKeypad> createState() => AmountKeypadState();
}

class AmountKeypadState extends State<AmountKeypad> {
  String _centsString = '';

  double get currentAmount {
    if (_centsString.isEmpty) return 0.0;
    return int.parse(_centsString) / 100.0;
  }

  String get formattedAmount {
    return 'R\$ ${currentAmount.toStringAsFixed(2)}';
  }

  void clear() {
    setState(() {
      _centsString = '';
    });
    widget.onAmountChanged(0.0);
  }

  void _onDigitPressed(String digit) {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}

    setState(() {
      if (_centsString.length < 10) {
        _centsString += digit;
      }
    });
    widget.onAmountChanged(currentAmount);
  }

  void _onBackspacePressed() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}

    setState(() {
      if (_centsString.isNotEmpty) {
        _centsString = _centsString.substring(0, _centsString.length - 1);
      }
    });
    widget.onAmountChanged(currentAmount);
  }

  void _onBackspaceLongPress() {
    try {
      HapticFeedback.mediumImpact();
    } catch (_) {}

    clear();
  }

  void _onDoubleZeroPressed() {
    try {
      HapticFeedback.lightImpact();
    } catch (_) {}

    setState(() {
      if (_centsString.length < 9) {
        _centsString += '00';
      }
    });
    widget.onAmountChanged(currentAmount);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Amount display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          child: Text(
            formattedAmount,
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineLarge?.copyWith(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: currentAmount > 0
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            semanticsLabel:
                '${currentAmount.toStringAsFixed(2)} reais',
          ),
        ),
        const SizedBox(height: 8),
        // Keypad grid
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildKeypadRow(['1', '2', '3']),
              const SizedBox(height: 8),
              _buildKeypadRow(['4', '5', '6']),
              const SizedBox(height: 8),
              _buildKeypadRow(['7', '8', '9']),
              const SizedBox(height: 8),
              _buildBottomRow(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildKeypadRow(List<String> digits) {
    return Row(
      children: digits
          .map((digit) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: _KeypadButton(
                    label: digit,
                    onTap: () => _onDigitPressed(digit),
                    semanticLabel: 'Number $digit',
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildBottomRow() {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _KeypadButton(
              label: '00',
              onTap: _onDoubleZeroPressed,
              semanticLabel: 'Double zero',
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _KeypadButton(
              label: '0',
              onTap: () => _onDigitPressed('0'),
              semanticLabel: 'Number 0',
            ),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: _KeypadButton(
              icon: Icons.backspace_outlined,
              onTap: _onBackspacePressed,
              onLongPress: _onBackspaceLongPress,
              semanticLabel: 'Backspace. Long press to clear all',
            ),
          ),
        ),
      ],
    );
  }
}

class _KeypadButton extends StatefulWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final String semanticLabel;

  const _KeypadButton({
    this.label,
    this.icon,
    required this.onTap,
    this.onLongPress,
    required this.semanticLabel,
  });

  @override
  State<_KeypadButton> createState() => _KeypadButtonState();
}

class _KeypadButtonState extends State<_KeypadButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: widget.semanticLabel,
      button: true,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Material(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              _scaleController.forward().then((_) => _scaleController.reverse());
              widget.onTap();
            },
            onLongPress: widget.onLongPress,
            child: Container(
              height: 56,
              alignment: Alignment.center,
              child: widget.icon != null
                  ? Icon(widget.icon, size: 24)
                  : Text(
                      widget.label ?? '',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
