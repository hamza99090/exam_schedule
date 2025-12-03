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
    // final availableSubjects = ClassSubjectsData.getSubjectsForClass(
    //   widget.classNumber,
    // );
    final availableSubjects =
        widget.availableSubjects; // Use passed availableSubjects

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Combine all subjects for the list
            final allSubjects = [...availableSubjects, ..._customSubjects];

            return AlertDialog(
              title: Text('Select Subjects for Class ${widget.classNumber}'),
              content: SizedBox(
                width: double.maxFinite,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Add Custom Subject Section
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
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
                    ),
                    // Subjects List
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: allSubjects.length + 1, // +1 for "—" option
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            // "—" option
                            return CheckboxListTile(
                              title: const Text('—'),
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
                            );
                          }

                          // Adjust index for subjects (after "—")
                          final subjectIndex = index - 1;
                          final subject = allSubjects[subjectIndex];

                          // Check if this is a custom subject
                          final isCustomSubject =
                              subjectIndex >= availableSubjects.length;

                          return CheckboxListTile(
                            title: Text(subject),
                            subtitle: isCustomSubject
                                ? const Text('Custom subject')
                                : null,
                            value: _selectedSubjects.contains(subject),
                            onChanged: (bool? value) {
                              setDialogState(() {
                                if (value == true) {
                                  _selectedSubjects.remove('—');
                                  _selectedSubjects.add(subject);
                                } else {
                                  _selectedSubjects.remove(subject);
                                  // Remove from custom subjects if it's a custom subject
                                  if (isCustomSubject) {
                                    _customSubjects.remove(subject);
                                  }
                                }
                              });
                            },
                            secondary: isCustomSubject
                                ? IconButton(
                                    icon: Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red.shade600,
                                    ),
                                    onPressed: () {
                                      setDialogState(() {
                                        _selectedSubjects.remove(subject);
                                        _customSubjects.remove(subject);
                                      });
                                    },
                                    tooltip: 'Remove custom subject',
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
                TextButton(
                  onPressed: () {
                    _customSubjectController.clear();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
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
