import 'table_row_model.dart';

class DateSheetData {
  String schoolName;
  String dateSheetDescription;
  String termDescription;
  List<TableRowData> tableRows;

  DateSheetData({
    this.schoolName = 'Enter Your School Name',
    this.dateSheetDescription = 'Enter Date Sheet Description',
    this.termDescription = 'Enter Examination Term Description',
    List<TableRowData>? tableRows,
  }) : tableRows = tableRows ?? [TableRowData()];
}
