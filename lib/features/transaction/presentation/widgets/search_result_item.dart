import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/transaction.dart';

class SearchResultItem extends StatelessWidget {
  final Transaction transaction;
  final String? highlightQuery;
  final VoidCallback onTap;

  const SearchResultItem({
    super.key,
    required this.transaction,
    this.highlightQuery,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = transaction.isIncome
        ? Colors.green
        : (transaction.isExpense ? Colors.red : Colors.blue);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
          child: Text(transaction.displayIcon,
              style: const TextStyle(fontSize: 20)),
        ),
        title: _buildHighlightedText(
          transaction.description ?? transaction.displayType,
          context,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(DateFormat('MMM dd, yyyy')
                .format(transaction.transactionDate)),
            if (transaction.hasNotes && highlightQuery != null)
              _buildHighlightedText(
                transaction.notes!,
                context,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                maxLines: 1,
              ),
          ],
        ),
        trailing: Text(
          transaction.amountWithSign,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildHighlightedText(
    String text,
    BuildContext context, {
    TextStyle? style,
    int? maxLines,
  }) {
    final baseStyle =
        style ?? const TextStyle(fontWeight: FontWeight.w600);

    if (highlightQuery == null || highlightQuery!.isEmpty) {
      return Text(text, style: baseStyle, maxLines: maxLines,
          overflow: maxLines != null ? TextOverflow.ellipsis : null);
    }

    final query = highlightQuery!.toLowerCase();
    final textLower = text.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (start < text.length) {
      final index = textLower.indexOf(query, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }
      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: const TextStyle(
          backgroundColor: Color(0x40FFEB3B),
          fontWeight: FontWeight.bold,
        ),
      ));
      start = index + query.length;
    }

    return RichText(
      text: TextSpan(
        style: baseStyle.copyWith(
          color: baseStyle.color ?? Theme.of(context).textTheme.bodyLarge?.color,
        ),
        children: spans,
      ),
      maxLines: maxLines,
      overflow: maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
    );
  }
}
