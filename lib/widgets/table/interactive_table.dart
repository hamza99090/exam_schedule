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
  final ScrollController _horizontalScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Create controllers once for initial data
    for (var className in widget.manager.data.classNames) {
      _classControllers.add(TextEditingController(text: className));
    }

    // Listen to manager changes but DON'T recreate controllers every time.
    widget.manager.addListener(_onManagerChanged);
  }

  void _onManagerChanged() {
    // Sync controller texts with manager data *in-place*
    final classNames = widget.manager.data.classNames;

    // If there are more names than controllers, add new controllers
    if (classNames.length > _classControllers.length) {
      for (var i = _classControllers.length; i < classNames.length; i++) {
        _classControllers.add(TextEditingController(text: classNames[i]));
      }
    }

    // If there are fewer names than controllers, dispose extras
    if (classNames.length < _classControllers.length) {
      for (var i = _classControllers.length - 1; i >= classNames.length; i--) {
        _classControllers[i].dispose();
        _classControllers.removeAt(i);
      }
    }

    // Update existing controller texts (preserve cursor/selection when possible)
    for (
      var i = 0;
      i < classNames.length && i < _classControllers.length;
      i++
    ) {
      final ctrl = _classControllers[i];
      final newText = classNames[i];
      if (ctrl.text != newText) {
        // preserve selection as a best-effort (if selection index is valid)
        final oldSelection = ctrl.selection;
        ctrl.text = newText;
        final newOffset = oldSelection.baseOffset.clamp(0, ctrl.text.length);
        ctrl.selection = TextSelection.collapsed(offset: newOffset);
      }
    }

    // rebuild UI
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.manager.removeListener(_onManagerChanged);
    for (var controller in _classControllers) {
      controller.dispose();
    }
    _horizontalScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // If your whole table must be LTR regardless of app locale, wrap it once:
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Card(
        elevation: 4,
        child: Container(
          height: 200, // Increased height (you can adjust this value)
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.only(top: 8.0),
            child: Scrollbar(
              controller: _horizontalScrollController,
              thumbVisibility: true,
              trackVisibility: true,
              interactive: true,
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
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
                    ...widget.manager.data.classNames.asMap().entries.map((e) {
                      final index = e.key;
                      return DataColumn(
                        label: _buildClassNameEditor(index, e.value),
                      );
                    }).toList(),
                  ],
                  rows: widget.manager.data.tableRows.asMap().entries.map((e) {
                    final index = e.key;
                    final rowData = e.value;
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
      ),
    );
  }

  Widget _buildClassNameEditor(int index, String currentName) {
    // defensive: ensure controller exists
    if (index >= _classControllers.length) {
      _classControllers.add(TextEditingController(text: currentName));
    }

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
        autofocus: false,
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 8,
            horizontal: 4,
          ),
          hintText: 'Class...',
          hintStyle: const TextStyle(color: Colors.white70),
        ),
        onChanged: (value) {
          // only update manager (which will trigger _onManagerChanged) —
          // manager should update the underlying data without forcing controllers recreation.
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
            availableSubjects: widget.manager.getSubjectsForClass(
              classNum,
            ), // ADD THIS LINE
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
