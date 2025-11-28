import 'package:exam_schedule/models/table_row_model.dart';
import 'package:flutter/material.dart';
import '../models/date_sheet_model.dart';

class DateSheetManager extends ChangeNotifier {
  DateSheetData _data = DateSheetData();
  final List<DateSheetData> _savedDateSheets = [];

  DateSheetData get data => _data;
  List<DateSheetData> get savedDateSheets => _savedDateSheets;

  void updateSchoolName(String name) {
    _data.schoolName = name;
    notifyListeners();
  }

  void updateDateSheetDescription(String description) {
    _data.dateSheetDescription = description;
    notifyListeners();
  }

  void updateTermDescription(String term) {
    _data.termDescription = term;
    notifyListeners();
  }

  void addNewRow() {
    _data.tableRows.add(TableRowData());
    notifyListeners();
  }

  void updateDate(int rowIndex, DateTime? date) {
    if (rowIndex < _data.tableRows.length) {
      _data.tableRows[rowIndex].date = date;
      notifyListeners();
    }
  }

  void updateDay(int rowIndex, String? day) {
    if (rowIndex < _data.tableRows.length) {
      _data.tableRows[rowIndex].day = day;
      notifyListeners();
    }
  }

  void updateClassSubjects(
    int rowIndex,
    String classNum,
    List<String> subjects,
  ) {
    if (rowIndex < _data.tableRows.length) {
      _data.tableRows[rowIndex].classSubjects[classNum] = subjects;
      notifyListeners();
    }
  }

  // New method to save current date sheet
  void saveDateSheet(String fileName) {
    final savedSheet = _data.copyWith(
      fileName: fileName,
      createdAt: DateTime.now(),
    );
    _savedDateSheets.add(savedSheet);

    // Reset current data to empty state
    _data = DateSheetData();
    notifyListeners();
  }

  // Method to load a saved date sheet
  void loadDateSheet(DateSheetData dateSheet) {
    _data = dateSheet.copyWith();
    notifyListeners();
  }

  // Method to delete a saved date sheet
  void deleteDateSheet(int index) {
    if (index < _savedDateSheets.length) {
      _savedDateSheets.removeAt(index);
      notifyListeners();
    }
  }
}
