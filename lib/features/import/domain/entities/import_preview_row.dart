import 'package:equatable/equatable.dart';

class ImportPreviewRow extends Equatable {
  final int rowNumber;
  final DateTime? date;
  final String? description;
  final double? amount;
  final String? type;
  final String? matchedMerchantId;
  final String? matchedMerchantName;
  final String? matchedCategoryId;
  final String? matchedCategoryName;
  final bool isDuplicate;
  final String? duplicateTransactionId;
  final bool selected;

  const ImportPreviewRow({
    required this.rowNumber,
    this.date,
    this.description,
    this.amount,
    this.type,
    this.matchedMerchantId,
    this.matchedMerchantName,
    this.matchedCategoryId,
    this.matchedCategoryName,
    this.isDuplicate = false,
    this.duplicateTransactionId,
    this.selected = true,
  });

  ImportPreviewRow copyWith({bool? selected}) {
    return ImportPreviewRow(
      rowNumber: rowNumber,
      date: date,
      description: description,
      amount: amount,
      type: type,
      matchedMerchantId: matchedMerchantId,
      matchedMerchantName: matchedMerchantName,
      matchedCategoryId: matchedCategoryId,
      matchedCategoryName: matchedCategoryName,
      isDuplicate: isDuplicate,
      duplicateTransactionId: duplicateTransactionId,
      selected: selected ?? this.selected,
    );
  }

  @override
  List<Object?> get props => [
        rowNumber,
        date,
        description,
        amount,
        type,
        matchedMerchantId,
        matchedMerchantName,
        matchedCategoryId,
        matchedCategoryName,
        isDuplicate,
        duplicateTransactionId,
        selected,
      ];
}

class ImportPreviewResponse extends Equatable {
  final List<ImportPreviewRow> rows;
  final int totalRows;
  final int duplicateCount;
  final String? profileUsed;

  const ImportPreviewResponse({
    required this.rows,
    required this.totalRows,
    required this.duplicateCount,
    this.profileUsed,
  });

  @override
  List<Object?> get props => [rows, totalRows, duplicateCount, profileUsed];
}
