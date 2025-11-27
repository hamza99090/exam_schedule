import 'package:flutter/material.dart';
import 'date_sheet_manager.dart';

class HeaderSection extends StatelessWidget {
  final DateSheetManager manager;

  const HeaderSection({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // School Name
            TextFormField(
              initialValue: manager.data.schoolName,
              onChanged: manager.updateSchoolName,
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
            ),

            const SizedBox(height: 12),

            // Date Sheet Description
            TextFormField(
              initialValue: manager.data.dateSheetDescription,
              onChanged: manager.updateDateSheetDescription,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),

            const SizedBox(height: 8),

            // Term Description
            TextFormField(
              initialValue: manager.data.termDescription,
              onChanged: manager.updateTermDescription,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
