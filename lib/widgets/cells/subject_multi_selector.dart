import 'package:flutter/material.dart';
import '../../data/class_subjects_data.dart';

class SubjectMultiSelector extends StatefulWidget {
  final String classNumber;
  final List<String> selectedSubjects;
  final Function(List<String>) onSubjectsChanged;

  const SubjectMultiSelector({
    super.key,
    required this.classNumber,
    required this.selectedSubjects,
    required this.onSubjectsChanged,
  });

  @override
  State<SubjectMultiSelector> createState() => _SubjectMultiSelectorState();
}

class _SubjectMultiSelectorState extends State<SubjectMultiSelector> {
  List<String> _selectedSubjects = [];

  @override
  void initState() {
    super.initState();
    _selectedSubjects = List.from(widget.selectedSubjects);
  }

  void _showSubjectSelectionDialog() {
    final availableSubjects = ClassSubjectsData.getSubjectsForClass(
      widget.classNumber,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Select Subjects for Class ${widget.classNumber}'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: availableSubjects.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
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

                    final subject = availableSubjects[index - 1];
                    return CheckboxListTile(
                      title: Text(subject),
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
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      widget.onSubjectsChanged(_selectedSubjects);
                    });
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

  String _getDisplayText() {
    if (_selectedSubjects.isEmpty) return 'Add Subjects';
    if (_selectedSubjects.contains('—') && _selectedSubjects.length == 1)
      return '—';
    final subjectsToShow = _selectedSubjects
        .where((subject) => subject != '—')
        .toList();
    return subjectsToShow.join(' / ');
  }

  @override
  Widget build(BuildContext context) {
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
