import 'package:flutter/material.dart';
import 'managers/date_sheet_manager.dart';
import 'widgets/header/header_section.dart';
import 'widgets/table/interactive_table.dart';
import 'screens/saved_date_sheets_screen.dart'; // We'll create this next

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Date Sheet Generator',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const DateSheetScreen(),
    );
  }
}

class DateSheetScreen extends StatefulWidget {
  const DateSheetScreen({super.key});

  @override
  State<DateSheetScreen> createState() => _DateSheetScreenState();
}

class _DateSheetScreenState extends State<DateSheetScreen> {
  final DateSheetManager dateSheetManager = DateSheetManager();

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
              hintText: 'Enter file name for your date sheet',
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
      dateSheetManager.saveDateSheet(fileName);
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Date sheet "$fileName" saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _navigateToSavedSheets() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavedDateSheetsScreen(manager: dateSheetManager),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Sheet Generator'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.library_books),
            onPressed: _navigateToSavedSheets,
            tooltip: 'View Saved Date Sheets',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            HeaderSection(manager: dateSheetManager),
            const SizedBox(height: 24),
            InteractiveTable(manager: dateSheetManager),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      dateSheetManager.addNewRow();
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add New Row'),
                ),
                ElevatedButton.icon(
                  onPressed: _showSaveDialog,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Date Sheet'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
