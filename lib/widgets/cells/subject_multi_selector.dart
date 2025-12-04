import 'package:flutter/material.dart';
import '../../data/class_subjects_data.dart';

class SubjectMultiSelector extends StatefulWidget {
  final String classNumber;
  final List<String> availableSubjects; // NEW PARAMETER
  final List<String> selectedSubjects;
  final Function(List<String>) onSubjectsChanged;
  final bool enabled; // Add this parameter

  const SubjectMultiSelector({
    super.key,
    required this.classNumber,
    required this.availableSubjects, // ADD THIS
    required this.selectedSubjects,
    required this.onSubjectsChanged,
    this.enabled = true, // Default to enabled
  });

  @override
  State<SubjectMultiSelector> createState() => _SubjectMultiSelectorState();
}

class _SubjectMultiSelectorState extends State<SubjectMultiSelector> {
  List<String> _selectedSubjects = [];
  List<String> _customSubjects = [];
  final TextEditingController _customSubjectController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedSubjects = List.from(widget.selectedSubjects);

    // Extract custom subjects from selected subjects
    // final availableSubjects = ClassSubjectsData.getSubjectsForClass(
    //   widget.classNumber,
    // );

    //   _customSubjects = _selectedSubjects
    //       .where(
    //         (subject) => subject != '—' && !availableSubjects.contains(subject),
    //       )
    //       .toList();
    // }
    _selectedSubjects = List.from(widget.selectedSubjects);
    _customSubjects = _selectedSubjects
        .where(
          (subject) =>
              subject != '—' && !widget.availableSubjects.contains(subject),
        )
        .toList();
  }

  @override
  void didUpdateWidget(SubjectMultiSelector oldWidget) {
    super.didUpdateWidget(oldWidget);

    // CRITICAL: Update local state when parent data changes
    if (widget.selectedSubjects != oldWidget.selectedSubjects) {
      setState(() {
        _selectedSubjects = List.from(widget.selectedSubjects);

        // Also update custom subjects
        _customSubjects = _selectedSubjects
            .where(
              (subject) =>
                  subject != '—' && !widget.availableSubjects.contains(subject),
            )
            .toList();
      });
    }
  }

  void _showSubjectSelectionDialog() {
    final availableSubjects = widget.availableSubjects;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Merge default + custom subjects
            List<String> allSubjects = [
              ..._customSubjects,
              ...availableSubjects,
            ];

            return AlertDialog(
              title: Text('Select Subjects for Class ${widget.classNumber}'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    /// Add custom subject
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _customSubjectController,
                            decoration: const InputDecoration(
                              labelText: 'Add Custom Subject',
                              hintText: 'Enter subject name',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            onSubmitted: (value) {
                              _addCustomSubject(value, setDialogState);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () {
                            _addCustomSubject(
                              _customSubjectController.text,
                              setDialogState,
                            );
                          },
                          tooltip: 'Add Custom Subject',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    /// Subjects list
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: allSubjects.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // "—" option with checkbox on left
                            return ListTile(
                              leading: Checkbox(
                                value: _selectedSubjects.contains('—'),
                                onChanged: (bool? value) {
                                  setDialogState(() {
                                    if (value == true) {
                                      _selectedSubjects = ['—'];
                                    } else {
                                      _selectedSubjects.remove('—');
                                    }
                                  });
                                },
                              ),
                              title: const Text('—'),
                              onTap: () {
                                setDialogState(() {
                                  final currentValue = _selectedSubjects
                                      .contains('—');
                                  if (!currentValue) {
                                    _selectedSubjects = ['—'];
                                  } else {
                                    _selectedSubjects.remove('—');
                                  }
                                });
                              },
                            );
                          }

                          final subjectIndex = index - 1;
                          final subject = allSubjects[subjectIndex];
                          final isCustomSubject =
                              subjectIndex < _customSubjects.length;

                          return ListTile(
                            leading: Checkbox(
                              value: _selectedSubjects.contains(subject),
                              onChanged: (bool? value) {
                                setDialogState(() {
                                  if (value == true) {
                                    _selectedSubjects.remove('—');
                                    _selectedSubjects.add(subject);
                                  } else {
                                    _selectedSubjects.remove(subject);
                                  }
                                });
                              },
                            ),
                            title: Text(subject),
                            subtitle: isCustomSubject
                                ? const Text('Custom subject')
                                : null,
                            trailing: isCustomSubject
                                ? PopupMenuButton<String>(
                                    icon: const Icon(Icons.more_vert, size: 20),
                                    onSelected: (choice) async {
                                      if (choice == 'Edit') {
                                        final editController =
                                            TextEditingController(
                                              text: subject,
                                            );
                                        await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: const Text(
                                                'Edit Custom Subject',
                                              ),
                                              content: TextField(
                                                controller: editController,
                                                decoration:
                                                    const InputDecoration(
                                                      hintText: 'Subject name',
                                                      border:
                                                          OutlineInputBorder(),
                                                    ),
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(context),
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    final newName =
                                                        editController.text
                                                            .trim();
                                                    if (newName.isNotEmpty) {
                                                      setDialogState(() {
                                                        final idx =
                                                            _customSubjects
                                                                .indexOf(
                                                                  subject,
                                                                );
                                                        _customSubjects[idx] =
                                                            newName;

                                                        if (_selectedSubjects
                                                            .contains(
                                                              subject,
                                                            )) {
                                                          _selectedSubjects
                                                              .remove(subject);
                                                          _selectedSubjects.add(
                                                            newName,
                                                          );
                                                        }
                                                      });
                                                      Navigator.pop(context);
                                                    }
                                                  },
                                                  child: const Text('Save'),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      } else if (choice == 'Delete') {
                                        setDialogState(() {
                                          _customSubjects.remove(subject);
                                          _selectedSubjects.remove(subject);
                                        });
                                      }
                                    },
                                    itemBuilder: (context) => [
                                      const PopupMenuItem(
                                        value: 'Edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem(
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
                    // backgroundColor: Colors.grey.shade300,
                    // foregroundColor: Colors.black,
                  ),

                  onPressed: () {
                    _customSubjectController.clear();
                    Navigator.of(context).pop();
                  },
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
                    setState(() {
                      widget.onSubjectsChanged(_selectedSubjects);
                    });
                    _customSubjectController.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addCustomSubject(
    String subjectName,
    void Function(void Function()) setDialogState,
  ) {
    final subject = subjectName.trim();
    if (subject.isNotEmpty && !_customSubjects.contains(subject)) {
      setDialogState(() {
        _customSubjects.add(subject);
        _selectedSubjects.remove('—');
        if (!_selectedSubjects.contains(subject)) {
          _selectedSubjects.add(subject);
        }
        _customSubjectController.clear();
      });
    }
  }

  String _getDisplayText() {
    if (_selectedSubjects.isEmpty) return 'Add Subjects';
    if (_selectedSubjects.contains('—') && _selectedSubjects.length == 1)
      return '—';
    final subjectsToShow = _selectedSubjects
        .where((subject) => subject != '—')
        .toList();

    if (subjectsToShow.length <= 2) {
      return subjectsToShow.join(' / ');
    } else {
      return '${subjectsToShow.length} subjects';
    }
  }

  @override
  void dispose() {
    _customSubjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Read-only mode when not enabled
    if (!widget.enabled) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          _getDisplayText(),
          style: TextStyle(
            fontSize: 10,
            color: _selectedSubjects.isEmpty ? Colors.grey : Colors.black87,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      );
    }

    // Editable mode when enabled
    return ElevatedButton(
      onPressed: _showSubjectSelectionDialog,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade50,
        foregroundColor: Colors.blue.shade800,
        elevation: 1,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      child: Text(
        _getDisplayText(),
        style: TextStyle(
          fontSize: 10,
          color: _selectedSubjects.isEmpty ? Colors.grey : Colors.blue.shade800,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
