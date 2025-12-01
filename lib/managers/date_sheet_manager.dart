import 'package:exam_schedule/models/table_row_model.dart';
import 'package:flutter/material.dart';
import '../models/date_sheet_model.dart';

class DateSheetManager extends ChangeNotifier {
  DateSheetData _data = DateSheetData();
  final List<DateSheetData> _savedDateSheets = [];

  DateSheetData get data => _data;
  List<DateSheetData> get savedDateSheets => _savedDateSheets;

  // Getter for class names - defaults to I through XII
  List<String> get classNames => _data.classNames;

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
      print('=== MANAGER: Updating DATE at row $rowIndex to: $date ===');
      _data.tableRows[rowIndex].date = date;
      notifyListeners();
    }
  }

  void updateDay(int rowIndex, String? day) {
    if (rowIndex < _data.tableRows.length) {
      print('=== MANAGER: Updating DAY at row $rowIndex to: $day ===');
      _data.tableRows[rowIndex].day = day;
      notifyListeners();

      // Debug: Verify the update
      print(
        '=== VERIFY: Current day in row $rowIndex is now: ${_data.tableRows[rowIndex].day} ===',
      );
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

  // NEW METHOD: Update class name
  void updateClassName(int index, String newName) {
    print('=== UPDATE CLASS NAME CALLED ===');
    print('Index: $index, New name: "$newName"');
    print('Current classNames before: ${_data.classNames}');

    if (index >= 0 && index < _data.classNames.length) {
      final oldClassName = _data.classNames[index];

      // Make sure we're not modifying a const list
      _data.classNames = List<String>.from(_data.classNames);
      _data.classNames[index] = newName;

      // Migrate all existing subject data from old class name to new class name
      for (var row in _data.tableRows) {
        if (row.classSubjects.containsKey(oldClassName)) {
          final subjects = row.classSubjects[oldClassName] ?? [];
          row.classSubjects.remove(oldClassName);
          row.classSubjects[newName] = subjects;
        }
      }

      notifyListeners();
      print(
        '=== MANAGER: Updated class name at index $index from "$oldClassName" to "$newName" ===',
      );
    }
  }

  // Update the saveDateSheet method to preserve class names
  void saveDateSheet(String fileName) {
    print('=== SAVE: Current classNames: ${_data.classNames} ===');

    // Create a DEEP copy with all data including classNames
    final savedSheet = DateSheetData(
      schoolName: _data.schoolName,
      dateSheetDescription: _data.dateSheetDescription,
      termDescription: _data.termDescription,
      tableRows: _data.tableRows.map((row) => row.copyWith()).toList(),
      fileName: fileName,
      createdAt: DateTime.now(),
      classNames: List<String>.from(_data.classNames), // IMPORTANT: Deep copy
    );

    print('=== SAVE: Saving classNames: ${savedSheet.classNames} ===');

    _savedDateSheets.add(savedSheet);

    // Reset current data
    _data = DateSheetData(
      schoolName: '',
      dateSheetDescription: '',
      termDescription: '',
      tableRows: [TableRowData()],
      fileName: '',
      createdAt: DateTime.now(),
    );
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

  // Add this setter
  set data(DateSheetData newData) {
    _data = newData;
    notifyListeners();
  }
}
