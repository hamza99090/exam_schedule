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
  @HiveField(7) // Add this - new field for logo
  String? logoPath; // Make it nullable since logo is optional

  DateSheetData({
    this.schoolName = '',
    this.dateSheetDescription = '',
    this.termDescription = '',
    List<TableRowData>? tableRows,
    this.fileName = '',
    DateTime? createdAt,
    List<String>? classNames,
    this.logoPath, // Add to constructor
  }) : tableRows = tableRows ?? [TableRowData()],
       createdAt = createdAt ?? DateTime.now(),
       classNames = classNames ?? defaultClassNames;

  // Default class names
  static const List<String> defaultClassNames = [
    'Class I',
    'Class II',
    'Class III',
    'Class IV',
    'Class V',
    'Class VI',
    'Class VII',
    'Class VIII',
    'Class IX',
    'Class X',
    'Class XI',
    'Class XII',
  ];

  DateSheetData copyWith({
    String? schoolName,
    String? dateSheetDescription,
    String? termDescription,
    List<TableRowData>? tableRows,
    String? fileName,
    DateTime? createdAt,
    List<String>? classNames,
    String? logoPath, // Add this
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
      logoPath: logoPath ?? this.logoPath, // Add this
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
      'logoPath': logoPath, // Add this
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
      logoPath: map['logoPath'], // Add this
    );
  }
}
