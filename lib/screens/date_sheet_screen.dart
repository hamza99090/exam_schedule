import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../managers/date_sheet_manager.dart';
import '../widgets/header/header_section.dart';
import '../widgets/table/interactive_table.dart';

class DateSheetScreen extends StatefulWidget {
  final DateSheetManager manager;

  const DateSheetScreen({super.key, required this.manager});

  @override
  State<DateSheetScreen> createState() => _DateSheetScreenState();
}

class _DateSheetScreenState extends State<DateSheetScreen> {
  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String fileName = '';
        return AlertDialog(
          title: const Text('Save Date Sheet'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'File Name',
              hintText: 'Enter DateSheet Name',
            ),
            onChanged: (value) {
              fileName = value;
            },
            onSubmitted: (value) {
              _saveDateSheet(value);
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (fileName.isNotEmpty) {
                  _saveDateSheet(fileName);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveDateSheet(String fileName) {
    setState(() {
      widget.manager.saveDateSheet(fileName);
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Date sheet "$fileName" saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Hide keyboard when tapping anywhere on screen
        SystemChannels.textInput.invokeMethod('TextInput.hide');
        // Alternative: FocusScope.of(context).unfocus();
      },
      behavior: HitTestBehavior.opaque, // This makes sure taps pass through(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Date Sheet'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _showSaveDialog,
              tooltip: 'Save Date Sheet',
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // This should show textfields, not plain text
              HeaderSection(manager: widget.manager),
              const SizedBox(height: 24),
              InteractiveTable(manager: widget.manager, isEditing: true),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    widget.manager.addNewRow();
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Add New Row'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
