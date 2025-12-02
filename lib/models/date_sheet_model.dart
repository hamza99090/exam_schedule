import 'package:hive/hive.dart';
import 'table_row_model.dart';

part 'date_sheet_model.g.dart'; // Generated file

@HiveType(typeId: 0)
class DateSheetData {
  @HiveField(0)
  String schoolName;

  @HiveField(1)
  String dateSheetDescription;

  @HiveField(2)
  String termDescription;

  @HiveField(3)
  List<TableRowData> tableRows;

  @HiveField(4)
  String fileName;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  List<String> classNames;

  DateSheetData({
    this.schoolName = '',
    this.dateSheetDescription = '',
    this.termDescription = '',
    List<TableRowData>? tableRows,
    this.fileName = '',
    DateTime? createdAt,
    List<String>? classNames,
  }) : tableRows = tableRows ?? [TableRowData()],
       createdAt = createdAt ?? DateTime.now(),
       classNames = classNames ?? defaultClassNames;

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
          : this.tableRows.map((row) => row.copyWith()).toList(),
      fileName: fileName ?? this.fileName,
      createdAt: createdAt ?? this.createdAt,
      classNames: classNames != null
          ? List<String>.from(classNames)
          : List<String>.from(this.classNames),
    );
  }

  // Keep toMap and fromMap for PDF generation if needed
  Map<String, dynamic> toMap() {
    return {
      'schoolName': schoolName,
      'dateSheetDescription': dateSheetDescription,
      'termDescription': termDescription,
      'tableRows': tableRows.map((row) => row.toMap()).toList(),
      'fileName': fileName,
      'createdAt': createdAt.toIso8601String(),
      'classNames': classNames,
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
          defaultClassNames,
    );
  }
}
