import 'package:exam_schedule/header_section.dart';
import 'package:exam_schedule/interactive_table.dart';
import 'package:flutter/material.dart';
import 'date_sheet_manager.dart';

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
            // Header Section
            HeaderSection(manager: dateSheetManager),

            const SizedBox(height: 24),

            // Interactive Table
            InteractiveTable(manager: dateSheetManager),

            const SizedBox(height: 16),

            // Add Row Button
            TextButton.icon(
              onPressed: () {
                setState(() {
                  dateSheetManager.addNewRow();
                });
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // Text and icon color
                backgroundColor: Colors.blue.withOpacity(
                  0.1,
                ), // Background color
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Add New Row'),
            ),
          ],
        ),
      ),
    );
  }
}
