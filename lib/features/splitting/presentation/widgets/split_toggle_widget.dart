import 'package:flutter/material.dart';

/// Data class representing a single split entry for the API.
class CreateSplitEntry {
  final String userId;
  final String userName;
  final double amount;

  const CreateSplitEntry({
    required this.userId,
    required this.userName,
    required this.amount,
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'amount': amount,
      };
}

/// Member info needed by the split toggle widget.
class SplitMember {
  final String userId;
  final String userName;
  bool isSelected;

  SplitMember({
    required this.userId,
    required this.userName,
    this.isSelected = true,
  });
}

enum SplitMode { equal, custom }

/// A widget that toggles expense splitting on/off and lets the user
/// choose between equal and custom splits among budget members.
class SplitToggleWidget extends StatefulWidget {
  final double transactionAmount;
  final List<SplitMember> members;
  final ValueChanged<List<CreateSplitEntry>?> onSplitsChanged;

  const SplitToggleWidget({
    super.key,
    required this.transactionAmount,
    required this.members,
    required this.onSplitsChanged,
  });

  @override
  State<SplitToggleWidget> createState() => _SplitToggleWidgetState();
}

class _SplitToggleWidgetState extends State<SplitToggleWidget> {
  bool _splitEnabled = false;
  SplitMode _splitMode = SplitMode.equal;
  final Map<String, TextEditingController> _customControllers = {};
  String? _validationError;

  @override
  void initState() {
    super.initState();
    for (final member in widget.members) {
      _customControllers[member.userId] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final controller in _customControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(SplitToggleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.transactionAmount != widget.transactionAmount) {
      _notifySplits();
    }
  }

  List<SplitMember> get _selectedMembers =>
      widget.members.where((m) => m.isSelected).toList();

  void _notifySplits() {
    if (!_splitEnabled || _selectedMembers.isEmpty) {
      widget.onSplitsChanged(null);
      return;
    }

    if (_splitMode == SplitMode.equal) {
      final perPerson =
          widget.transactionAmount / _selectedMembers.length;
      final entries = _selectedMembers
          .map((m) => CreateSplitEntry(
                userId: m.userId,
                userName: m.userName,
                amount: double.parse(perPerson.toStringAsFixed(2)),
              ))
          .toList();
      widget.onSplitsChanged(entries);
      setState(() => _validationError = null);
    } else {
      // Custom mode
      double sum = 0;
      final entries = <CreateSplitEntry>[];
      for (final member in _selectedMembers) {
        final text = _customControllers[member.userId]?.text ?? '0';
        final amount = double.tryParse(text) ?? 0;
        sum += amount;
        entries.add(CreateSplitEntry(
          userId: member.userId,
          userName: member.userName,
          amount: amount,
        ));
      }

      final diff = (sum - widget.transactionAmount).abs();
      if (diff > 0.01) {
        setState(() => _validationError =
            'Amounts must sum to R\$ ${widget.transactionAmount.toStringAsFixed(2)} (current: R\$ ${sum.toStringAsFixed(2)})');
        widget.onSplitsChanged(null);
      } else {
        setState(() => _validationError = null);
        widget.onSplitsChanged(entries);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: const Text('Split this expense'),
          subtitle: const Text('Divide among budget members'),
          value: _splitEnabled,
          onChanged: (val) {
            setState(() => _splitEnabled = val);
            _notifySplits();
          },
        ),
        if (_splitEnabled) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<SplitMode>(
              segments: const [
                ButtonSegment(
                  value: SplitMode.equal,
                  label: Text('Equal'),
                  icon: Icon(Icons.balance),
                ),
                ButtonSegment(
                  value: SplitMode.custom,
                  label: Text('Custom'),
                  icon: Icon(Icons.tune),
                ),
              ],
              selected: {_splitMode},
              onSelectionChanged: (set) {
                setState(() => _splitMode = set.first);
                _notifySplits();
              },
            ),
          ),
          const SizedBox(height: 12),
          ...widget.members.map((member) => _buildMemberRow(member)),
          if (_validationError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                _validationError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 12,
                ),
              ),
            ),
          if (_splitMode == SplitMode.equal && _selectedMembers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                'R\$ ${(widget.transactionAmount / _selectedMembers.length).toStringAsFixed(2)} per person',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildMemberRow(SplitMember member) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Checkbox(
            value: member.isSelected,
            onChanged: (val) {
              setState(() => member.isSelected = val ?? false);
              _notifySplits();
            },
          ),
          CircleAvatar(
            radius: 16,
            child: Text(
              member.userName.isNotEmpty ? member.userName[0].toUpperCase() : '?',
              style: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              member.userName,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          if (_splitMode == SplitMode.custom && member.isSelected)
            SizedBox(
              width: 100,
              child: TextField(
                controller: _customControllers[member.userId],
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  prefixText: 'R\$ ',
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => _notifySplits(),
              ),
            ),
          if (_splitMode == SplitMode.equal && member.isSelected)
            Text(
              'R\$ ${_selectedMembers.isNotEmpty ? (widget.transactionAmount / _selectedMembers.length).toStringAsFixed(2) : '0.00'}',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
        ],
      ),
    );
  }
}
