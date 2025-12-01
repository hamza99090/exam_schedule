import 'package:exam_schedule/models/table_row_model.dart';
import 'package:flutter/material.dart';
import '../managers/date_sheet_manager.dart';
import '../models/date_sheet_model.dart';
import '../widgets/header/header_section.dart';
import '../widgets/table/interactive_table.dart';

class DateSheetDetailScreen extends StatefulWidget {
  final DateSheetData dateSheet;
  final DateSheetManager manager;

  const DateSheetDetailScreen({
    super.key,
    required this.dateSheet,
    required this.manager,
  });

  @override
  State<DateSheetDetailScreen> createState() => _DateSheetDetailScreenState();
}

class _DateSheetDetailScreenState extends State<DateSheetDetailScreen> {
  late DateSheetData _editableDateSheet;
  bool _isEditing = false;
  late DateSheetManager _tempManager; // Add this line

  @override
  void initState() {
    super.initState();

    print('=== DETAIL SCREEN INIT ===');
    print('Received classNames: ${widget.dateSheet.classNames}');
    print(
      'First 3 classNames: ${widget.dateSheet.classNames.take(3).toList()}',
    );

    _editableDateSheet = widget.dateSheet.copyWith();
    _initializeTempManager();
  }

  // ADD THIS METHOD
  void _initializeTempManager() {
    print('=== INITIALIZING TEMP MANAGER ===');
    print('Editable sheet classNames: ${_editableDateSheet.classNames}');

    _tempManager = DateSheetManager();
    _tempManager.data = _editableDateSheet.copyWith();

    print('Temp manager classNames: ${_tempManager.data.classNames}');

    // Listen to changes from the InteractiveTable
    _tempManager.addListener(() {
      print('=== DETAIL: Temp manager notified ===');
      print('New classNames in tempManager: ${_tempManager.data.classNames}');
      setState(() {
        // Update our local copy with changes from the table
        _editableDateSheet = _tempManager.data.copyWith(
          fileName: _editableDateSheet.fileName,
          createdAt: _editableDateSheet.createdAt,
        );
      });
    });
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });

    // If entering edit mode and there are rows, automatically open calendar for first row
    // if (_isEditing && _editableDateSheet.tableRows.isNotEmpty) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _showDatePickerForFirstRow();
    //   });
    // }
  }

  void _showDatePickerForFirstRow() async {
    final currentDate = _editableDateSheet.tableRows[0].date;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _editableDateSheet.tableRows[0].date = picked;
        _editableDateSheet.tableRows[0].day = _getDayName(picked.weekday);
      });
    }
  }

  void _saveChanges() {
    // Update the original date sheet in manager
    final index = widget.manager.savedDateSheets.indexOf(widget.dateSheet);
    if (index != -1) {
      widget.manager.savedDateSheets[index] = _editableDateSheet.copyWith(
        createdAt: DateTime.now(),
      );
      widget.manager.notifyListeners();
    }

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _discardChanges() {
    setState(() {
      _editableDateSheet = widget.dateSheet.copyWith();
      _isEditing = false;
    });
  }

  void _addNewRow() {
    setState(() {
      _editableDateSheet.tableRows.add(TableRowData());
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editableDateSheet.fileName),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditing,
              tooltip: 'Edit Date Sheet',
            ),
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _discardChanges,
              tooltip: 'Discard Changes',
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildDateSheetTable(),
            const SizedBox(height: 16),
            if (_isEditing) _buildAddRowButton(),
          ],
        ),
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
              onPressed: _saveChanges,
              backgroundColor: Colors.green,
              child: const Icon(Icons.save, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // School Name - Only editable when in edit mode
            _isEditing
                ? TextFormField(
                    initialValue: _editableDateSheet.schoolName,
                    onChanged: (value) {
                      setState(() {
                        _editableDateSheet.schoolName = value;
                      });
                    },
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Text(
                    _editableDateSheet.schoolName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
            const SizedBox(height: 12),
            // Date Sheet Description - Only editable when in edit mode
            _isEditing
                ? TextFormField(
                    initialValue: _editableDateSheet.dateSheetDescription,
                    onChanged: (value) {
                      setState(() {
                        _editableDateSheet.dateSheetDescription = value;
                      });
                    },
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Text(
                    _editableDateSheet.dateSheetDescription,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
            const SizedBox(height: 8),
            // Term Description - Only editable when in edit mode
            _isEditing
                ? TextFormField(
                    initialValue: _editableDateSheet.termDescription,
                    onChanged: (value) {
                      setState(() {
                        _editableDateSheet.termDescription = value;
                      });
                    },
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Text(
                    _editableDateSheet.termDescription,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
            const SizedBox(height: 16),
            Text(
              '${_isEditing ? 'Editing' : 'Saved'} on: ${_formatDate(_editableDateSheet.createdAt)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSheetTable() {
    // Create a temporary manager for the table
    final tempManager = DateSheetManager();
    tempManager.data = _editableDateSheet;

    return InteractiveTable(
      manager: tempManager,
      isEditing: _isEditing, // This is the key line!
    );
  }

  Widget _buildAddRowButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton.icon(
        onPressed: _addNewRow,
        icon: const Icon(Icons.add),
        label: const Text('Add New Row'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
