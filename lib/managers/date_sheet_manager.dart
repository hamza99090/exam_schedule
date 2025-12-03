import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:exam_schedule/models/table_row_model.dart';
import '../models/date_sheet_model.dart';

class DateSheetManager extends ChangeNotifier {
  DateSheetData _data = DateSheetData();
  late Box<DateSheetData> _dateSheetsBox;

  DateSheetManager() {
    _initHiveBox();
  }

  Future<void> _initHiveBox() async {
    _dateSheetsBox = Hive.box<DateSheetData>('dateSheetsBox');
    notifyListeners();
  }

  DateSheetData get data => _data;

  // Get saved date sheets from Hive
  List<DateSheetData> get savedDateSheets {
    return _dateSheetsBox.values.toList();
  }

  // Getter for class names
  List<String> get classNames => _data.classNames;

  // Default subjects for standard classes
  static final Map<String, List<String>> _defaultClassSubjects = {
    'Class I': ['English', 'Math', 'Urdu', 'Science', 'Drawing'],
    'Class II': ['English', 'Math', 'Urdu', 'Science', 'Drawing'],
    'Class III': ['English', 'Math', 'Urdu', 'Science', 'Drawing'],
    'Class IV': ['English', 'Math', 'Urdu', 'Science', 'Drawing'],
    'Class V': ['English', 'Math', 'Urdu', 'Science', 'Drawing'],
    'Class VI': ['English', 'Math', 'Urdu', 'Science', 'Drawing'],
    'Class VII': ['English', 'Math', 'Urdu', 'Science', 'Drawing'],
    'Class VIII': ['English', 'Math', 'Urdu', 'Science', 'Drawing'],
    'Class IX': ['English', 'Math', 'Urdu', 'Science', 'Drawing'],
    'Class X': ['English', 'Math', 'Urdu', 'Science', 'Drawing'],
    'Class XI': ['English', 'Math', 'Urdu', 'Science', 'Drawing'],
    'Class XII': ['English', 'Math', 'Urdu', 'Science', 'Drawing'],
  };

  // Get subjects for a class
  List<String> getSubjectsForClass(String className) {
    if (_defaultClassSubjects.containsKey(className)) {
      return List<String>.from(_defaultClassSubjects[className]!);
    }
    return ['English', 'Math', 'Science', 'Social Studies', 'Urdu'];
  }

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
    _data.tableRows.add(TableRowData(classNames: _data.classNames));
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

  void updateClassName(int index, String newName) {
    if (index >= 0 && index < _data.classNames.length) {
      final oldClassName = _data.classNames[index];

      _data.classNames = List<String>.from(_data.classNames);
      _data.classNames[index] = newName;

      for (var row in _data.tableRows) {
        if (row.classSubjects.containsKey(oldClassName)) {
          final subjects = row.classSubjects[oldClassName] ?? [];
          row.classSubjects.remove(oldClassName);
          row.classSubjects[newName] = subjects;
        } else {
          row.classSubjects[newName] = [];
        }
      }

      notifyListeners();
    }
  }

  // Save date sheet to Hive
  void saveDateSheet(String fileName) {
    // Create a DEEP copy with all data
    final savedSheet = DateSheetData(
      schoolName: _data.schoolName,
      dateSheetDescription: _data.dateSheetDescription,
      termDescription: _data.termDescription,
      tableRows: _data.tableRows.map((row) => row.copyWith()).toList(),
      fileName: fileName,
      createdAt: DateTime.now(),
      classNames: List<String>.from(_data.classNames),
    );

    // Add to Hive box with auto-generated key
    _dateSheetsBox.add(savedSheet);

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

  // Load a saved date sheet
  void loadDateSheet(DateSheetData dateSheet) {
    _data = dateSheet.copyWith();
    notifyListeners();
  }

  // Delete a saved date sheet
  void deleteDateSheet(int index) {
    if (index < _dateSheetsBox.length) {
      final key = _dateSheetsBox.keyAt(index);
      _dateSheetsBox.delete(key);
      notifyListeners();
    }
  }

  // Add this method to your DateSheetManager class (in date_sheet_manager.dart)
  void deleteRow(int rowIndex) {
    if (rowIndex >= 0 && rowIndex < _data.tableRows.length) {
      _data.tableRows.removeAt(rowIndex);
      // If all rows are deleted, add one empty row
      if (_data.tableRows.isEmpty) {
        _data.tableRows.add(TableRowData(classNames: _data.classNames));
      }
      notifyListeners();
    }
  }

  // Get date sheet by index
  DateSheetData getDateSheetByIndex(int index) {
    return _dateSheetsBox.getAt(index)!;
  }

  // Setter for data
  set data(DateSheetData newData) {
    _data = newData;
    notifyListeners();
  }
}
