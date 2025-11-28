import 'package:exam_schedule/date_picker_handler.dart';
import 'package:exam_schedule/day_selector.dart';
import 'package:exam_schedule/models/table_row_model.dart';
import 'package:flutter/material.dart';
import '../../managers/date_sheet_manager.dart';

import '../cells/subject_multi_selector.dart';

class InteractiveTable extends StatefulWidget {
  final DateSheetManager manager;
  final bool isEditing; // This parameter controls edit behavior

  const InteractiveTable({
    super.key,
    required this.manager,
    this.isEditing = true,
  });

  @override
  State<InteractiveTable> createState() => _InteractiveTableState();
}

class _InteractiveTableState extends State<InteractiveTable> {
  @override
  void initState() {
    super.initState();
    // Listen to manager changes
    widget.manager.addListener(() {
      print('=== TABLE: Manager notified, rebuilding ===');
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    print(
      '=== TABLE: Building with ${widget.manager.data.tableRows.length} rows ===',
    );

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.only(top: 8.0), // Add top padding here
          child: Scrollbar(
            thumbVisibility: true,
            trackVisibility: true,
            interactive: true,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingTextStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 12,
                ),
                headingRowColor: MaterialStateProperty.all(
                  Colors.blue.shade700,
                ),
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
                rows: widget.manager.data.tableRows.asMap().entries.map((
                  entry,
                ) {
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
        ),
      ),
    );
  }

  DataCell _buildDateCell(int index, TableRowData rowData) {
    return DataCell(
      DatePickerHandler(
        initialDate: rowData.date,
        onDateSelected: (date) {
          print('=== TABLE: Date selected: $date ===');
          widget.manager.updateDate(index, date);
        },
        onDayUpdated: (day) {
          print('=== TABLE: Auto-updating day to: $day ===');
          widget.manager.updateDay(index, day);
        },
        enabled: widget.isEditing,
      ),
    );
  }

  DataCell _buildDayCell(int index, TableRowData rowData) {
    return DataCell(
      DaySelector(
        selectedDay: rowData.day,
        onDaySelected: (day) {
          print('=== TABLE: Day selected manually: $day ===');
          widget.manager.updateDay(index, day);
        },
        enabled: false, // Add this to disable the dropdown
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
                  widget.manager.updateClassSubjects(index, classNum, subjects);
                },
                enabled: widget.isEditing, // Add this line
              ),
            ),
          ),
        )
        .toList();
  }
}
