// UPDATED InteractiveTable widget ka code - Action column RIGHT side
import 'package:exam_schedule/date_picker_handler.dart';
import 'package:exam_schedule/day_selector.dart';
import 'package:exam_schedule/models/table_row_model.dart';
import 'package:flutter/material.dart';
import '../../managers/date_sheet_manager.dart';
import '../cells/subject_multi_selector.dart';

class InteractiveTable extends StatefulWidget {
  final DateSheetManager manager;
  final bool isEditing;
  final Map<String, List<String>>? alreadySelectedSubjectsMap;
  const InteractiveTable({
    super.key,
    required this.manager,
    this.isEditing = true,
    this.alreadySelectedSubjectsMap,
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

  void _resetRow(int rowIndex) {
    setState(() {
      final row = widget.manager.data.tableRows[rowIndex];
      // Reset date and day
      row.date = null;
      row.day = null;

      // Reset all class subjects - remove the key completely
      for (var className in widget.manager.data.classNames) {
        row.classSubjects.remove(className); // Remove the entry
      }

      // Notify manager
      widget.manager.notifyListeners();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Row ${rowIndex + 1} reset successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
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
    if (widget.manager.data.tableRows.isEmpty) {
      return SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // SCROLLABLE TABLE (without Action column)
                Expanded(
                  child: Scrollbar(
                    controller: _horizontalScrollController,
                    thumbVisibility: true,
                    interactive: true,
                    child: SingleChildScrollView(
                      controller: _horizontalScrollController,
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 10.0),
                        child: DataTable(
                          headingTextStyle: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          headingRowColor: MaterialStateProperty.all(
                            Colors.blue.shade600,
                          ),
                          headingRowHeight: 42,
                          dataTextStyle: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.w500,
                          ),
                          columnSpacing: 14,
                          dataRowMinHeight: 42,
                          dataRowMaxHeight: 52,
                          horizontalMargin: 10,
                          dividerThickness: 0.3,
                          border: TableBorder(
                            horizontalInside: BorderSide(
                              color: Colors.grey.shade200,
                              width: 0.3,
                            ),
                            verticalInside: BorderSide(
                              color: Colors.grey.shade200,
                              width: 0.3,
                            ),
                          ),
                          columns: [
                            DataColumn(
                              label: SizedBox(
                                width: 80,
                                child: Text(
                                  'Date',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            DataColumn(
                              label: SizedBox(
                                width: 60,
                                child: Text(
                                  'Day',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ),
                            ...widget.manager.data.classNames
                                .asMap()
                                .entries
                                .map((e) {
                                  final index = e.key;
                                  return DataColumn(
                                    label: SizedBox(
                                      width: 100,
                                      child: _buildClassNameEditor(
                                        index,
                                        e.value,
                                      ),
                                    ),
                                  );
                                })
                                .toList(),
                          ],
                          rows: widget.manager.data.tableRows
                              .asMap()
                              .entries
                              .map((e) {
                                final index = e.key;
                                final rowData = e.value;
                                return DataRow(
                                  cells: [
                                    _buildDateCell(index, rowData),
                                    _buildDayCell(index, rowData),
                                    ..._buildClassCells(index, rowData),
                                  ],
                                );
                              })
                              .toList(),
                        ),
                      ),
                    ),
                  ),
                ),

                // FIXED ACTION COLUMN (right side, doesn't scroll)
                if (widget.isEditing)
                  Container(
                    width: 50, // Very small width
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Colors.grey.shade300, // ✅ VERTICAL LINE
                          width: 1.0,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        // EMPTY SPACE FOR HEADER
                        SizedBox(height: 42),

                        // Action buttons for each row
                        ...widget.manager.data.tableRows.asMap().entries.map((
                          e,
                        ) {
                          final index = e.key;
                          return Container(
                            height: 52,
                            child: PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.blue, // ✅ BLUE COLOR
                                size: 20,
                              ),
                              onSelected: (value) {
                                if (value == 'reset') {
                                  _resetRow(index);
                                } else if (value == 'delete') {
                                  _showDeleteConfirmation(index);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'reset',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.restart_alt,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Reset'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                      SizedBox(width: 8),
                                      Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildClassNameEditor(int index, String currentName) {
    if (index >= _classControllers.length) {
      _classControllers.add(TextEditingController(text: currentName));
    }

    return MouseRegion(
      cursor: widget.isEditing
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: widget.isEditing ? () => _showClassSelectionPopup(index) : null,
        child: Container(
          padding: EdgeInsets.zero,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  currentName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.isEditing)
                Icon(Icons.edit, size: 14, color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }

  DataCell _buildDateCell(int index, TableRowData rowData) {
    return DataCell(
      Container(
        padding: EdgeInsets.zero,
        margin: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
        child: DatePickerHandler(
          initialDate: rowData.date,
          onDateSelected: (date) {
            widget.manager.updateDate(index, date);
          },
          onDayUpdated: (day) {
            widget.manager.updateDay(index, day);
          },
          enabled: widget.isEditing,
        ),
      ),
    );
  }

  DataCell _buildDayCell(int index, TableRowData rowData) {
    String? getDayNameFromDate(DateTime? date) {
      if (date == null) return null;
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      return days[date.weekday - 1];
    }

    return DataCell(
      DaySelector(
        key: ValueKey('day_${index}_${rowData.date}_${rowData.day}'),
        selectedDay: getDayNameFromDate(rowData.date),
        onDaySelected: (day) {
          widget.manager.updateDay(index, day);
        },
        enabled: false,
      ),
    );
  }

  List<DataCell> _buildClassCells(int rowIndex, TableRowData rowData) {
    return widget.manager.data.classNames.asMap().entries.map((entry) {
      final classIndex = entry.key;
      final classNum = entry.value;
      final bool hasDate = rowData.date != null;

      List<String> alreadySelectedSubjects = [];
      for (int i = 0; i < widget.manager.data.tableRows.length; i++) {
        if (i != rowIndex) {
          final otherRow = widget.manager.data.tableRows[i];
          final subjects = otherRow.classSubjects[classNum] ?? [];
          alreadySelectedSubjects.addAll(subjects);
        }
      }

      return DataCell(
        SizedBox(
          width: 100,
          child: SubjectMultiSelector(
            classNumber: classNum,
            availableSubjects: widget.manager.getSubjectsForClass(classNum),
            selectedSubjects: rowData.classSubjects[classNum] ?? [],
            alreadySelectedSubjects: alreadySelectedSubjects,
            onSubjectsChanged: (subjects) {
              if (!hasDate && widget.isEditing) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please select a date first for row ${rowIndex + 1}',
                    ),
                    backgroundColor: Colors.red,
                    duration: Duration(seconds: 2),
                  ),
                );
                return;
              }
              widget.manager.updateClassSubjects(rowIndex, classNum, subjects);
            },
            enabled: widget.isEditing,
          ),
        ),
      );
    }).toList();
  }

  void _showClassSelectionPopup(int index) {
    final TextEditingController customController = TextEditingController();
    final List<String> defaultClasses = [
      "Class I",
      "Class II",
      "Class III",
      "Class IV",
      "Class V",
      "Class VI",
      "Class VII",
      "Class VIII",
      "Class IX",
      "Class X",
      "Class XI",
      "Class XII",
    ];

    List<String> customClasses = List.from(widget.manager.starredClassNames);
    String selectedClass = widget.manager.data.classNames[index];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            List<String> allClasses = [...customClasses, ...defaultClasses];

            return AlertDialog(
              title: Text("Select Class"),
              content: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: customController,
                            decoration: InputDecoration(
                              hintText: "Add custom class",
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            final name = customController.text.trim();
                            if (name.isEmpty) return;

                            setState(() {
                              customClasses.insert(0, name);
                              selectedClass = name;
                              widget.manager.toggleStarClassName(name);
                            });

                            customController.clear();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    Expanded(
                      child: ListView.builder(
                        itemCount: allClasses.length,
                        itemBuilder: (context, i) {
                          final item = allClasses[i];
                          final isCustom = customClasses.contains(item);

                          return ListTile(
                            leading: Radio<String>(
                              value: item,
                              groupValue: selectedClass,
                              onChanged: (value) {
                                setState(() {
                                  selectedClass = value!;
                                });
                              },
                            ),
                            title: Text(item),
                            trailing: isCustom
                                ? PopupMenuButton<String>(
                                    icon: Icon(Icons.more_vert, size: 20),
                                    onSelected: (choice) async {
                                      if (choice == 'Edit') {
                                        final editController =
                                            TextEditingController(text: item);
                                        await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text("Edit Custom Class"),
                                              content: TextField(
                                                controller: editController,
                                                decoration: InputDecoration(
                                                  hintText: "Class name",
                                                  border: OutlineInputBorder(),
                                                ),
                                              ),
                                              actions: [
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  4,
                                                                ),
                                                              ),
                                                        ),
                                                  ),
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: Text("Cancel"),
                                                ),
                                                ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                Radius.circular(
                                                                  4,
                                                                ),
                                                              ),
                                                        ),
                                                    backgroundColor:
                                                        Colors.blue.shade700,
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    final newName =
                                                        editController.text
                                                            .trim();
                                                    if (newName.isNotEmpty) {
                                                      setState(() {
                                                        final idx =
                                                            customClasses
                                                                .indexOf(item);
                                                        customClasses[idx] =
                                                            newName;

                                                        if (selectedClass ==
                                                            item) {
                                                          selectedClass =
                                                              newName;
                                                        }

                                                        widget.manager
                                                            .toggleStarClassName(
                                                              item,
                                                            );
                                                        widget.manager
                                                            .toggleStarClassName(
                                                              newName,
                                                            );
                                                      });
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  child: Text("Save"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else if (choice == 'Delete') {
                                        setState(() {
                                          customClasses.remove(item);

                                          if (widget.manager.starredClassNames
                                              .contains(item)) {
                                            widget.manager.toggleStarClassName(
                                              item,
                                            );
                                          }

                                          if (selectedClass == item) {
                                            if (index < defaultClasses.length) {
                                              selectedClass =
                                                  defaultClasses[index];
                                            } else {
                                              selectedClass =
                                                  defaultClasses.first;
                                            }
                                          }
                                        });
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      PopupMenuItem(
                                        value: 'Edit',
                                        child: Text('Edit'),
                                      ),
                                      PopupMenuItem(
                                        value: 'Delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  )
                                : null,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(4)),
                    ),
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    widget.manager.updateClassName(index, selectedClass);
                    Navigator.pop(context);
                  },
                  child: Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
