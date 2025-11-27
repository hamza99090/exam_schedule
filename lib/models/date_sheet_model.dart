import 'table_row_model.dart';

class DateSheetData {
  String schoolName;
  String dateSheetDescription;
  String termDescription;
  List<TableRowData> tableRows;
  String fileName;
  DateTime createdAt;

  DateSheetData({
    this.schoolName = 'Enter Your School Name',
    this.dateSheetDescription = 'Enter Date Sheet Description',
    this.termDescription = 'Enter Examination Term Description',
    List<TableRowData>? tableRows,
    this.fileName = '',
    DateTime? createdAt,
  }) : tableRows = tableRows ?? [TableRowData()],
       createdAt = createdAt ?? DateTime.now();

  // Add a copyWith method for easier cloning
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
