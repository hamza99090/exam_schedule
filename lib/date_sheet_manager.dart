// import 'package:flutter/material.dart';

// class DateSheetData {
//   String schoolName;
//   String dateSheetDescription;
//   String termDescription;
//   List<TableRowData> tableRows;

//   DateSheetData({
//     this.schoolName = 'Enter Your School Name',
//     this.dateSheetDescription = 'Enter Date Sheet Description ',
//     this.termDescription = 'Enter Examniation Term',
//     List<TableRowData>? tableRows,
//   }) : tableRows = tableRows ?? [TableRowData()];
// }

// class TableRowData {
//   DateTime? date;
//   String? day;
//   Map<String, List<String>> classSubjects;

//   TableRowData({this.date, this.day, Map<String, List<String>>? classSubjects})
//     : classSubjects =
//           classSubjects ??
//           {
//             'I': [],
//             'II': [],
//             'III': [],
//             'IV': [],
//             'V': [],
//             'VI': [],
//             'VII': [],
//             'VIII': [],
//             'IX': [],
//             'X': [],
//             'XI': [],
//             'XII': [],
//           };
// }

// class DateSheetManager extends ChangeNotifier {
//   DateSheetData _data = DateSheetData();

//   DateSheetData get data => _data;

//   // Header management
//   void updateSchoolName(String name) {
//     _data.schoolName = name;
//     notifyListeners();
//   }

//   void updateDateSheetDescription(String description) {
//     _data.dateSheetDescription = description;
//     notifyListeners();
//   }

//   void updateTermDescription(String term) {
//     _data.termDescription = term;
//     notifyListeners();
//   }

//   // Table management
//   void addNewRow() {
//     _data.tableRows.add(TableRowData());
//     notifyListeners();
//   }

//   void updateDate(int rowIndex, DateTime? date) {
//     if (rowIndex < _data.tableRows.length) {
//       _data.tableRows[rowIndex].date = date;
//       notifyListeners();
//     }
//   }

//   void updateDay(int rowIndex, String? day) {
//     if (rowIndex < _data.tableRows.length) {
//       _data.tableRows[rowIndex].day = day;
//       notifyListeners();
//     }
//   }

//   void updateClassSubjects(
//     int rowIndex,
//     String classNum,
//     List<String> subjects,
//   ) {
//     if (rowIndex < _data.tableRows.length) {
//       _data.tableRows[rowIndex].classSubjects[classNum] = subjects;
//       notifyListeners();
//     }
//   }
// }
