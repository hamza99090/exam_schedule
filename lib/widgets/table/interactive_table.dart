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
    // Return empty widget if no rows
    if (widget.manager.data.tableRows.isEmpty) {
      return SizedBox.shrink();
    }
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
                headingTextStyle: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontSize: 12,
                ),
                headingRowColor: MaterialStateProperty.all(
                  Colors.blue.shade600, // Slightly lighter blue than current
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
                // Add subtle horizontal dividers
                border: TableBorder(
                  horizontalInside: BorderSide(
                    color: Colors.grey.shade200,
                    width: 0.3,
                  ),
                  verticalInside: BorderSide(
                    color: Colors.grey.shade200,
                    width: 0.3,
                  ),
                ), // ← ADD THIS LINE - removes left/right padding
                columns: [
                  // Add Actions column for delete buttons - NOW FIRST
                  if (widget.isEditing)
                    DataColumn(
                      label: SizedBox(
                        width: 40,
                        child: Text(
                          'Action',
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
                      width: 80, // Set fixed width for Date column
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
                      width: 60, // Set fixed width for Day column
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
                  ...widget.manager.data.classNames.asMap().entries.map((e) {
                    final index = e.key;
                    return DataColumn(
                      label: SizedBox(
                        width: 100, // Fixed width for all class columns
                        child: _buildClassNameEditor(index, e.value),
                      ),
                    );
                  }).toList(),
                ],
                rows: widget.manager.data.tableRows.asMap().entries.map((e) {
                  final index = e.key;
                  final rowData = e.value;
                  return DataRow(
                    cells: [
                      // Delete button cell - only show in edit mode - NOW FIRST
                      if (widget.isEditing)
                        DataCell(
                          Container(
                            width: 40,
                            child: PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              onSelected: (value) {
                                if (value == 'delete') {
                                  _showDeleteConfirmation(index);
                                }
                              },
                              itemBuilder: (BuildContext context) =>
                                  <PopupMenuEntry<String>>[
                                    PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline),
                                          SizedBox(width: 12),
                                          Text('Delete'),
                                        ],
                                      ),
                                    ),
                                  ],
                              padding: EdgeInsets.all(
                                4,
                              ), // Adjust padding as needed
                            ),
                          ),
                        ),
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
        padding: EdgeInsets.zero, // ← Remove any container padding
        margin: EdgeInsets.zero, // ← Remove any container margin
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

  void _showClassSelectionPopup(int index) {
    final TextEditingController customController = TextEditingController();

    // Default classes (always present)
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

    // Custom classes (your starred ones)
    List<String> customClasses = List.from(widget.manager.starredClassNames);

    // Selected class (current column's class)
    String selectedClass = widget.manager.data.classNames[index];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Merge custom + default classes, custom first
            List<String> allClasses = [...customClasses, ...defaultClasses];

            return AlertDialog(
              title: Text("Select Class"),
              content: SizedBox(
                width: 400,
                height: 400,
                child: Column(
                  children: [
                    /// Add custom class
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
                              // Add to custom list on top
                              customClasses.insert(0, name);

                              // Select it immediately
                              selectedClass = name;
                              widget.manager.toggleStarClassName(name);
                            });

                            customController.clear();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    /// Class list
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
                                        // Edit custom class
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
                                                    // backgroundColor: Colors.red.shade700,
                                                    // foregroundColor: Colors.white,
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

                                                        // Update selection if needed
                                                        if (selectedClass ==
                                                            item) {
                                                          selectedClass =
                                                              newName;
                                                        }

                                                        // Update in manager starred list
                                                        widget.manager
                                                            .toggleStarClassName(
                                                              item,
                                                            ); // remove old
                                                        widget.manager
                                                            .toggleStarClassName(
                                                              newName,
                                                            ); // add new
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

                                          // Remove from starred
                                          if (widget.manager.starredClassNames
                                              .contains(item)) {
                                            widget.manager.toggleStarClassName(
                                              item,
                                            );
                                          }

                                          // If it was selected, reset selection
                                          if (selectedClass == item) {
                                            selectedClass =
                                                defaultClasses.first;
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
                    // backgroundColor: Colors.red.shade700,
                    // foregroundColor: Colors.white,
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
                    // Update the class name in table column
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
