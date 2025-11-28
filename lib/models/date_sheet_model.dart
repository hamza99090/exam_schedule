import 'table_row_model.dart';

class DateSheetData {
  String schoolName;
  String dateSheetDescription;
  String termDescription;
  List<TableRowData> tableRows;
  String fileName;
  DateTime createdAt;

  DateSheetData({
    this.schoolName = '',
    this.dateSheetDescription = '',
    this.termDescription = '',
    List<TableRowData>? tableRows,
    this.fileName = '',
    DateTime? createdAt,
  }) : tableRows = tableRows ?? [TableRowData()],
       createdAt = createdAt ?? DateTime.now();

  DateSheetData copyWith({
    String? schoolName,
    String? dateSheetDescription,
    String? termDescription,
    List<TableRowData>? tableRows,
    String? fileName,
    DateTime? createdAt,
  }) {
    return DateSheetData(
      schoolName: schoolName ?? this.schoolName,
      dateSheetDescription: dateSheetDescription ?? this.dateSheetDescription,
      termDescription: termDescription ?? this.termDescription,
      tableRows: tableRows ?? List.from(this.tableRows),
      fileName: fileName ?? this.fileName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
