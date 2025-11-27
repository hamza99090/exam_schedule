import 'package:flutter/material.dart';
import 'date_sheet_manager.dart';
import 'date_picker_handler.dart';
import 'day_selector.dart';
import 'subject_multi_selector.dart';

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
            ),
            headingRowColor: MaterialStateProperty.all(Colors.blue.shade700),
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
                  // Date Cell
                  DataCell(
                    DatePickerHandler(
                      initialDate: rowData.date,
                      onDateSelected: (date) {
                        manager.updateDate(index, date);
                      },
                    ),
                  ),

                  // Day Cell
                  DataCell(
                    DaySelector(
                      initialDay: rowData.day,
                      onDaySelected: (day) {
                        manager.updateDay(index, day);
                      },
                    ),
                  ),

                  // Class VI-XII Cells
                  ...[
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
                  ].map((classNum) {
                    return DataCell(
                      SubjectMultiSelector(
                        classNumber: classNum,
                        selectedSubjects: rowData.classSubjects[classNum] ?? [],
                        onSubjectsChanged: (subjects) {
                          manager.updateClassSubjects(
                            index,
                            classNum,
                            subjects,
                          );
                        },
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
