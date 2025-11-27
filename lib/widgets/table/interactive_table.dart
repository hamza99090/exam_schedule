import 'package:exam_schedule/date_picker_handler.dart';
import 'package:exam_schedule/day_selector.dart';
import 'package:exam_schedule/models/table_row_model.dart';
import 'package:flutter/material.dart';
import '../../managers/date_sheet_manager.dart';

import '../cells/subject_multi_selector.dart';

class InteractiveTable extends StatelessWidget {
  final DateSheetManager manager;

  const InteractiveTable({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 12,
            ),
            headingRowColor: MaterialStateProperty.all(Colors.blue.shade700),
            dataTextStyle: const TextStyle(fontSize: 11),
            columns: const [
              DataColumn(label: Text('DATE')),
              DataColumn(label: Text('DAY')),
              DataColumn(label: Text('I')),
              DataColumn(label: Text('II')),
              DataColumn(label: Text('III')),
              DataColumn(label: Text('IV')),
              DataColumn(label: Text('V')),
              DataColumn(label: Text('VI')),
              DataColumn(label: Text('VII')),
              DataColumn(label: Text('VIII')),
              DataColumn(label: Text('IX')),
              DataColumn(label: Text('X')),
              DataColumn(label: Text('XI')),
              DataColumn(label: Text('XII')),
            ],
            rows: manager.data.tableRows.asMap().entries.map((entry) {
              final index = entry.key;
              final rowData = entry.value;
              return DataRow(
                cells: [
                  _buildDateCell(index, rowData),
                  _buildDayCell(index, rowData),
                  ..._buildClassCells(index, rowData),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  DataCell _buildDateCell(int index, TableRowData rowData) {
    return DataCell(
      DatePickerHandler(
        initialDate: rowData.date,
        onDateSelected: (date) {
          manager.updateDate(index, date);
        },
      ),
    );
  }

  DataCell _buildDayCell(int index, TableRowData rowData) {
    return DataCell(
      DaySelector(
        initialDay: rowData.day,
        onDaySelected: (day) {
          manager.updateDay(index, day);
        },
      ),
    );
  }

  List<DataCell> _buildClassCells(int index, TableRowData rowData) {
    return [
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
        ]
        .map(
          (classNum) => DataCell(
            SizedBox(
              width: 100,
              child: SubjectMultiSelector(
                classNumber: classNum,
                selectedSubjects: rowData.classSubjects[classNum] ?? [],
                onSubjectsChanged: (subjects) {
                  manager.updateClassSubjects(index, classNum, subjects);
                },
              ),
            ),
          ),
        )
        .toList();
  }
}
