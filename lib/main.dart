import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:exam_schedule/models/date_sheet_model.dart';
import 'package:exam_schedule/models/table_row_model.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(DateSheetDataAdapter());
  Hive.registerAdapter(TableRowDataAdapter());

  // Open the dateSheets box
  await Hive.openBox<DateSheetData>('dateSheetsBox');

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
      home: HomeScreen(), // Changed to HomeScreen
    );
  }
}
