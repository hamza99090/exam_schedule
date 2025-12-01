import 'table_row_model.dart';

class DateSheetData {
  String schoolName;
  String dateSheetDescription;
  String termDescription;
  List<TableRowData> tableRows;
  String fileName;
  DateTime createdAt;
  List<String> classNames; // NEW: Added classNames property

  DateSheetData({
    this.schoolName = '',
    this.dateSheetDescription = '',
    this.termDescription = '',
    List<TableRowData>? tableRows,
    this.fileName = '',
    DateTime? createdAt,
    List<String>? classNames, // NEW: Added classNames parameter
  }) : tableRows = tableRows ?? [TableRowData()],
       createdAt = createdAt ?? DateTime.now(),
       classNames =
           classNames ?? defaultClassNames; // NEW: Initialize with defaults

  // Default class names
  static const List<String> defaultClassNames = [
    'I',
    'II',
    'III',
    'IV',
    'V',
    'VI',
    'VII',
    'VIII',
    'IX',
    'X',
    'XI',
    'XII',
  ];

  DateSheetData copyWith({
    String? schoolName,
    String? dateSheetDescription,
    String? termDescription,
    List<TableRowData>? tableRows,
    String? fileName,
    DateTime? createdAt,
    List<String>? classNames,
  }) {
    return DateSheetData(
      schoolName: schoolName ?? this.schoolName,
      dateSheetDescription: dateSheetDescription ?? this.dateSheetDescription,
      termDescription: termDescription ?? this.termDescription,
      tableRows: tableRows != null
          ? List<TableRowData>.from(tableRows)
          : this.tableRows.map((row) => row.copyWith()).toList(), // Deep copy
      fileName: fileName ?? this.fileName,
      createdAt: createdAt ?? this.createdAt,
      classNames: classNames != null
          ? List<String>.from(classNames)
          : List<String>.from(this.classNames), // Deep copy
    );
  }

  // Optional: Add toMap and fromMap methods if you need serialization
  Map<String, dynamic> toMap() {
    return {
      'schoolName': schoolName,
      'dateSheetDescription': dateSheetDescription,
      'termDescription': termDescription,
      'tableRows': tableRows.map((row) => row.toMap()).toList(),
      'fileName': fileName,
      'createdAt': createdAt.toIso8601String(),
      'classNames': classNames, // NEW: Include in serialization
    };
  }

  factory DateSheetData.fromMap(Map<String, dynamic> map) {
    return DateSheetData(
      schoolName: map['schoolName'] ?? '',
      dateSheetDescription: map['dateSheetDescription'] ?? '',
      termDescription: map['termDescription'] ?? '',
      tableRows:
          (map['tableRows'] as List<dynamic>?)
              ?.map((row) => TableRowData.fromMap(row))
              .toList() ??
          [TableRowData()],
      fileName: map['fileName'] ?? '',
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
      classNames:
          (map['classNames'] as List<dynamic>?)?.cast<String>() ??
          defaultClassNames, // NEW: Load from map
    );
  }
}
