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
  final List<TextEditingController> _classControllers = [];
  final ScrollController _horizontalScrollController =
      ScrollController(); // Add this

  @override
  void initState() {
    super.initState();
    // Initialize controllers with current class names
    _initializeControllers();

    // Listen to manager changes
    widget.manager.addListener(() {
      print('=== TABLE: Manager notified, rebuilding ===');
      _initializeControllers(); // Re-initialize controllers if data changes
      setState(() {});
    });
  }

  @override
  void dispose() {
    // Dispose all controllers to prevent memory leaks
    for (var controller in _classControllers) {
      controller.dispose();
    }
    _horizontalScrollController.dispose(); // Dispose scroll controller
    super.dispose();
  }

  void _initializeControllers() {
    // Clear existing controllers
    for (var controller in _classControllers) {
      controller.dispose();
    }
    _classControllers.clear();

    // Create new controllers with current class names
    for (var className in widget.manager.data.classNames) {
      _classControllers.add(TextEditingController(text: className));
    }
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
          padding: const EdgeInsets.only(top: 8.0),
          child: Scrollbar(
            controller: _horizontalScrollController, // Add this
            thumbVisibility: true,
            trackVisibility: true,
            interactive: true,
            child: SingleChildScrollView(
              controller: _horizontalScrollController, // Add this
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
                columns: [
                  const DataColumn(label: Text('DATE')),
                  const DataColumn(label: Text('DAY')),
                  ...widget.manager.data.classNames.asMap().entries.map((
                    entry,
                  ) {
                    final index = entry.key;
                    final className = entry.value;
                    return DataColumn(
                      label: _buildClassNameEditor(index, className),
                    );
                  }).toList(),
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

  Widget _buildClassNameEditor(int index, String currentName) {
    print('=== BUILD CLASS EDITOR: index=$index, name="$currentName" ===');

    return Container(
      width: 100,
      child: TextFormField(
        controller: _classControllers[index],
        enabled: widget.isEditing,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 4,
          ),
          hintText: 'Class...',
          hintStyle: const TextStyle(color: Colors.white70),
          // filled: true,
          // fillColor: currentName.isEmpty
          //     ? Colors.red.shade100
          //     : Colors.transparent, // Visual debug
        ),
        onChanged: (value) {
          print('=== CLASS NAME CHANGED: $value ===');
          widget.manager.updateClassName(index, value);
        },
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
        enabled: false,
      ),
    );
  }

  List<DataCell> _buildClassCells(int index, TableRowData rowData) {
    return widget.manager.data.classNames.asMap().entries.map((entry) {
      final classIndex = entry.key;
      final classNum = entry.value;
      return DataCell(
        SizedBox(
          width: 100,
          child: SubjectMultiSelector(
            classNumber: classNum,
            selectedSubjects: rowData.classSubjects[classNum] ?? [],
            onSubjectsChanged: (subjects) {
              widget.manager.updateClassSubjects(index, classNum, subjects);
            },
            enabled: widget.isEditing,
          ),
        ),
      );
    }).toList();
  }
}
