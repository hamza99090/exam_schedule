import 'package:exam_schedule/date_picker_handler.dart';
import 'package:exam_schedule/day_selector.dart';
import 'package:exam_schedule/models/table_row_model.dart';
import 'package:flutter/material.dart';
import '../../managers/date_sheet_manager.dart';
import '../cells/subject_multi_selector.dart';

class InteractiveTable extends StatefulWidget {
  final DateSheetManager manager;
  final bool isEditing;

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
    for (var className in widget.manager.data.classNames) {
      _classControllers.add(TextEditingController(text: className));
    }
    widget.manager.addListener(_onManagerChanged);
  }

  void _onManagerChanged() {
    final classNames = widget.manager.data.classNames;

    if (classNames.length > _classControllers.length) {
      for (var i = _classControllers.length; i < classNames.length; i++) {
        _classControllers.add(TextEditingController(text: classNames[i]));
      }
    }

    if (classNames.length < _classControllers.length) {
      for (var i = _classControllers.length - 1; i >= classNames.length; i--) {
        _classControllers[i].dispose();
        _classControllers.removeAt(i);
      }
    }

    for (
      var i = 0;
      i < classNames.length && i < _classControllers.length;
      i++
    ) {
      final ctrl = _classControllers[i];
      final newText = classNames[i];
      if (ctrl.text != newText) {
        final oldSelection = ctrl.selection;
        ctrl.text = newText;
        final newOffset = oldSelection.baseOffset.clamp(0, ctrl.text.length);
        ctrl.selection = TextSelection.collapsed(offset: newOffset);
      }
    }

    if (mounted) setState(() {});
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Row'),
        content: const Text('Are you sure you want to delete this row?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.manager.deleteRow(index);
              Navigator.pop(context);
              // Show undo snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Row deleted'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Scrollbar(
          controller: _horizontalScrollController,
          thumbVisibility: true,
          interactive: true,
          child: Container(
            margin: const EdgeInsets.only(
              bottom: 10.0,
            ), // ← Space between table and scrollbar
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
                columnSpacing: 8, // Reduced from default (56.0) to 8
                dataRowMinHeight: 40, // Reduced row height
                dataRowMaxHeight: 50,
                columns: [
                  const DataColumn(label: Text('DATE')),
                  const DataColumn(label: Text('DAY')),
                  ...widget.manager.data.classNames.asMap().entries.map((e) {
                    final index = e.key;
                    return DataColumn(
                      label: _buildClassNameEditor(index, e.value),
                    );
                  }).toList(),
                  // Add Actions column for delete buttons
                  if (widget.isEditing)
                    const DataColumn(
                      label: Text(
                        'ACTION',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
                rows: widget.manager.data.tableRows.asMap().entries.map((e) {
                  final index = e.key;
                  final rowData = e.value;
                  return DataRow(
                    cells: [
                      _buildDateCell(index, rowData),
                      _buildDayCell(index, rowData),
                      ..._buildClassCells(index, rowData),
                      // Delete button cell - only show in edit mode
                      if (widget.isEditing)
                        DataCell(
                          Container(
                            width: 40,
                            child: IconButton(
                              icon: Icon(
                                Icons.delete_outline,
                                color: Colors.red.shade600,
                                size: 18,
                              ),
                              onPressed: () {
                                _showDeleteConfirmation(index);
                              },
                              padding: EdgeInsets.zero,
                              tooltip: 'Delete row',
                            ),
                          ),
                        ),
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
    if (index >= _classControllers.length) {
      _classControllers.add(TextEditingController(text: currentName));
    }

    final isStarred = widget.manager.isClassNameStarred(currentName);

    return Container(
      width: 100,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextFormField(
            controller: _classControllers[index],
            enabled: widget.isEditing,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
            autofocus: false,
            readOnly: true, // Make it read-only, will handle tap separately
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
            ),
            onTap: () {
              _showClassNameEditDialog(index, currentName, isStarred);
            },
          ),

          // Star Icon (on the left)
          if (isStarred)
            Positioned(
              left: 4,
              child: Icon(Icons.star, size: 14, color: Colors.yellow),
            ),

          // Edit Icon (on the right)
          Positioned(
            right: 4,
            child: Icon(Icons.edit, size: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  void _showClassNameEditDialog(int index, String currentName, bool isStarred) {
    if (!widget.isEditing) return;

    final TextEditingController editController = TextEditingController(
      text: currentName,
    );
    bool starValue = isStarred;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Class Name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Class Name',
                  hintText: 'Enter class name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: starValue,
                    onChanged: (value) {
                      starValue = value ?? false;
                      (context as Element).markNeedsBuild();
                    },
                  ),
                  SizedBox(width: 8),
                  Text('Star this class name'),
                  SizedBox(width: 8),
                  Icon(
                    Icons.star,
                    color: starValue ? Colors.yellow : Colors.grey,
                    size: 20,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Starred class names will appear in new date sheets',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newName = editController.text.trim();
                if (newName.isNotEmpty) {
                  // Update the class name
                  widget.manager.updateClassName(
                    index,
                    newName,
                    star: starValue,
                  );

                  // If star status changed, toggle it
                  if (starValue != isStarred) {
                    widget.manager.toggleStarClassName(newName);
                  }

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Class name updated${starValue ? ' and starred' : ''}',
                      ),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  DataCell _buildDateCell(int index, TableRowData rowData) {
    return DataCell(
      DatePickerHandler(
        initialDate: rowData.date,
        onDateSelected: (date) {
          widget.manager.updateDate(index, date);
        },
        onDayUpdated: (day) {
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
            availableSubjects: widget.manager.getSubjectsForClass(classNum),
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
