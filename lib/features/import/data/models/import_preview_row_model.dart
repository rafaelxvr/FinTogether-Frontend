import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/import_preview_row.dart';

part 'import_preview_row_model.g.dart';

@JsonSerializable()
class ImportPreviewRowModel {
  final int rowNumber;
  final String? date;
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

  const ImportPreviewRowModel({
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

  factory ImportPreviewRowModel.fromJson(Map<String, dynamic> json) =>
      _$ImportPreviewRowModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImportPreviewRowModelToJson(this);

  ImportPreviewRow toEntity() => ImportPreviewRow(
        rowNumber: rowNumber,
        date: date != null ? DateTime.tryParse(date!) : null,
        description: description,
        amount: amount,
        type: type,
        matchedMerchantId: matchedMerchantId,
        matchedMerchantName: matchedMerchantName,
        matchedCategoryId: matchedCategoryId,
        matchedCategoryName: matchedCategoryName,
        isDuplicate: isDuplicate,
        duplicateTransactionId: duplicateTransactionId,
        selected: selected,
      );
}

@JsonSerializable()
class ImportPreviewResponseModel {
  final List<ImportPreviewRowModel> rows;
  final int totalRows;
  final int duplicateCount;
  final String? profileUsed;

  const ImportPreviewResponseModel({
    required this.rows,
    required this.totalRows,
    required this.duplicateCount,
    this.profileUsed,
  });

  factory ImportPreviewResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ImportPreviewResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$ImportPreviewResponseModelToJson(this);

  ImportPreviewResponse toEntity() => ImportPreviewResponse(
        rows: rows.map((r) => r.toEntity()).toList(),
        totalRows: totalRows,
        duplicateCount: duplicateCount,
        profileUsed: profileUsed,
      );
}
