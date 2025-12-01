import 'package:exam_schedule/models/date_sheet_model.dart';

class TableRowData {
  DateTime? date;
  String? day;
  Map<String, List<String>> classSubjects;

  TableRowData({
    this.date,
    this.day,
    Map<String, List<String>>? classSubjects,
    List<String>? classNames, // NEW: Accept class names to initialize
  }) : classSubjects =
           classSubjects ??
           {
             // Initialize with empty lists for default class names
             for (var className
                 in (classNames ?? DateSheetData.defaultClassNames))
               className: [],
           };

  // Add copyWith method for TableRowData
  TableRowData copyWith({
    DateTime? date,
    String? day,
    Map<String, List<String>>? classSubjects,
  }) {
    return TableRowData(
      date: date ?? this.date,
      day: day ?? this.day,
      classSubjects: classSubjects ?? Map.from(this.classSubjects),
    );
  }

  // Optional: Add toMap and fromMap methods for serialization
  Map<String, dynamic> toMap() {
    return {
      'date': date?.toIso8601String(),
      'day': day,
      'classSubjects': classSubjects,
    };
  }

  factory TableRowData.fromMap(Map<String, dynamic> map) {
    return TableRowData(
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      day: map['day'],
      classSubjects: Map<String, List<String>>.from(map['classSubjects'] ?? {}),
    );
  }
}
