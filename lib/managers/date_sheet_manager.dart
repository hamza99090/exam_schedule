import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:exam_schedule/models/table_row_model.dart';
import '../models/date_sheet_model.dart';

class DateSheetManager extends ChangeNotifier {
  DateSheetData _data = DateSheetData();
  late Box<DateSheetData> _dateSheetsBox;
  List<String> _starredClassNames = [];

  // Getter for starred class names
  List<String> get starredClassNames => List.from(_starredClassNames);
  // Add this field in DateSheetManager class
  Map<String, String> _customToDefaultMapping = {}; // CustomName -> DefaultName
  // In-memory logo path for header image (not persisted in Hive)
  String? _logoPath;
  String? get logoPath => _logoPath;

  DateSheetManager() {
    _initHiveBox();
    // Ensure initial state has NO rows
    if (_data.tableRows.isNotEmpty) {
      _data.tableRows.clear();
    }
    _hasRows = false;
  }
  // Add this line after the other fields in DateSheetManager class (around line 20)
  bool _hasRows = true; // Track if we have any rows

  // Add this getter
  bool get hasRows => _hasRows;

  // Update the init method to load starred names
  Future<void> _initHiveBox() async {
    _dateSheetsBox = Hive.box<DateSheetData>('dateSheetsBox');
    await _loadStarredClassNames(); // Load starred names
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
    'Class I': ['English', 'Math'],
    'Class II': ['English', 'Math'],
    'Class III': ['English', 'Math'],
    'Class IV': ['English', 'Math'],
    'Class V': ['English', 'Math'],
    'Class VI': ['English', 'Math'],
    'Class VII': ['English', 'Math'],
    'Class VIII': ['English', 'Math'],
    'Class IX': ['English', 'Math'],
    'Class X': ['English', 'Math'],
    'Class XI': ['English', 'Math'],
    'Class XII': ['English', 'Math'],
  };

  // Get subjects for a class
  List<String> getSubjectsForClass(String className) {
    if (_defaultClassSubjects.containsKey(className)) {
      return List<String>.from(_defaultClassSubjects[className]!);
    }
    return ['English', 'Math'];
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

  // Modify addNewRow method (around line 95)
  void addNewRow() {
    _data.tableRows.add(TableRowData(classNames: _data.classNames));
    _hasRows = true; // We now have rows
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

  void updateClassName(int index, String newName, {bool star = false}) {
    if (index >= 0 && index < _data.classNames.length) {
      final oldClassName = _data.classNames[index];

      // Check if old name was a default class
      final bool wasDefault = DateSheetData.defaultClassNames.contains(
        oldClassName,
      );

      _data.classNames = List<String>.from(_data.classNames);
      _data.classNames[index] = newName;

      // Update starring
      if (star) {
        if (!_starredClassNames.contains(newName)) {
          _starredClassNames.add(newName);
        }
        // Remove old name from starred if it was starred
        _starredClassNames.remove(oldClassName);

        // Track mapping if replacing a default class with custom name
        if (wasDefault && !DateSheetData.defaultClassNames.contains(newName)) {
          _customToDefaultMapping[newName] = oldClassName;
        }
      }

      // Update rows
      for (var row in _data.tableRows) {
        if (row.classSubjects.containsKey(oldClassName)) {
          final subjects = row.classSubjects[oldClassName] ?? [];
          row.classSubjects.remove(oldClassName);
          row.classSubjects[newName] = subjects;
        } else {
          row.classSubjects[newName] = [];
        }
      }

      _saveStarredClassNames();
      notifyListeners();
    }
  }

  // Modify toggleStarClassName to track mapping
  void toggleStarClassName(String className) {
    if (_starredClassNames.contains(className)) {
      _starredClassNames.remove(className);
      // Remove from mapping when unstarred
      _customToDefaultMapping.remove(className);
    } else {
      _starredClassNames.add(className);

      // If this is a custom name (not in default classes), track what it replaced
      if (!DateSheetData.defaultClassNames.contains(className)) {
        // Find which default class this replaced based on position
        // This is tricky - we need to know which index this custom class is at
      }
    }
    _saveStarredClassNames();
    notifyListeners();
  }

  // Add a method to get the original default name for a custom class
  String? getOriginalDefaultName(String customName) {
    return _customToDefaultMapping[customName];
  }

  // Check if a class name is starred
  bool isClassNameStarred(String className) {
    return _starredClassNames.contains(className);
  }

  // Save and load the mapping in Hive
  Future<void> _saveStarredClassNames() async {
    final starredBox = Hive.box<List<String>>('starredClassesBox');
    await starredBox.put('starredClassNames', _starredClassNames);

    // Also save the mapping
    final mappingBox = Hive.box<Map<String, String>>('classMappingBox');
    await mappingBox.put('customToDefaultMapping', _customToDefaultMapping);
  }

  Future<void> _loadStarredClassNames() async {
    final starredBox = Hive.box<List<String>>('starredClassesBox');
    _starredClassNames =
        starredBox.get('starredClassNames', defaultValue: []) ?? [];

    // Also load the mapping
    final mappingBox = Hive.box<Map<String, String>>('classMappingBox');
    _customToDefaultMapping =
        mappingBox.get('customToDefaultMapping', defaultValue: {}) ?? {};
  }

  // Save date sheet to Hive
  // Add this method to DateSheetManager
  // Modify resetToDefault method (around line 142) to initialize with no rows
  void resetToDefault() {
    // Start with default class names
    List<String> initialClassNames = List.from(DateSheetData.defaultClassNames);

    // Add any starred class names that aren't already in defaults
    for (var starredName in _starredClassNames) {
      if (!initialClassNames.contains(starredName)) {
        // Add starred names at the beginning
        initialClassNames.insert(0, starredName);
      }
    }

    _data = DateSheetData(
      schoolName: '',
      dateSheetDescription: '',
      termDescription: '',
      tableRows: [], // Start with EMPTY table rows
      fileName: '',
      createdAt: DateTime.now(),
      classNames: initialClassNames,
    );
    _hasRows = false; // No rows initially
    _logoPath = null;
    notifyListeners();
  }

  // Update saveDateSheet() to use it
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
      logoPath: _logoPath, // ADD THIS LINE - include the logo!
    );

    // Add to Hive box
    _dateSheetsBox.add(savedSheet);

    // Reset to default state
    resetToDefault();
  }

  // Load a saved date sheet
  void loadDateSheet(DateSheetData dateSheet) {
    _data = dateSheet.copyWith();
    _logoPath = dateSheet.logoPath; // ADD THIS LINE - load the logo
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
    _logoPath = newData.logoPath; // Sync the logo path
    notifyListeners();
  }

  // Update logo path should also update the data
  void updateLogoPath(String? path) {
    _logoPath = path;
    // Also update the current data object
    _data = _data.copyWith(logoPath: path);
    notifyListeners();
  }

  // Add this method to DateSheetManager
  void updateSavedDateSheet(int index, DateSheetData updatedSheet) {
    if (index < _dateSheetsBox.length) {
      _dateSheetsBox.putAt(index, updatedSheet);
      notifyListeners();
    }
  }
}
