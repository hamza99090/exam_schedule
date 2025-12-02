import 'package:hive/hive.dart';
import 'package:exam_schedule/models/date_sheet_model.dart';

part 'table_row_model.g.dart'; // Generated file

@HiveType(typeId: 1)
class TableRowData {
  @HiveField(0)
  DateTime? date;

  @HiveField(1)
  String? day;

  @HiveField(2)
  Map<String, List<String>> classSubjects;

  TableRowData({
    this.date,
    this.day,
    Map<String, List<String>>? classSubjects,
    List<String>? classNames,
  }) : classSubjects =
           classSubjects ??
           {
             for (var className
                 in (classNames ?? DateSheetData.defaultClassNames))
               className: [],
           };

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
