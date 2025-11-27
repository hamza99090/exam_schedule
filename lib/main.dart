import 'package:flutter/material.dart';
import 'managers/date_sheet_manager.dart';
import 'widgets/header/header_section.dart';
import 'widgets/table/interactive_table.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Sheet Generator'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            HeaderSection(manager: dateSheetManager),
            const SizedBox(height: 24),
            InteractiveTable(manager: dateSheetManager),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  dateSheetManager.addNewRow();
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Add New Row'),
            ),
          ],
        ),
      ),
    );
  }
}
