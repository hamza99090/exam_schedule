import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

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
      home: HomeScreen(), // Changed to HomeScreen
    );
  }
}
