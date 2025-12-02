import 'package:flutter/material.dart';
import '../../managers/date_sheet_manager.dart';

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
            TextFormField(
              controller: TextEditingController(
                text: manager.data.schoolName.isEmpty
                    ? ''
                    : manager.data.schoolName,
              ),
              onChanged: manager.updateSchoolName,
              style: TextStyle(
                fontSize: 14, // Changed to match third TextFormField
                color: manager.data.schoolName.isEmpty
                    ? Colors.grey
                    : Colors
                          .grey
                          .shade500, // Changed to match third TextFormField
              ),
              // textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade700),
                ),
                contentPadding: const EdgeInsets.all(12),
                hintText: 'Enter Your School Name',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: TextEditingController(
                text: manager.data.dateSheetDescription.isEmpty
                    ? ''
                    : manager.data.dateSheetDescription,
              ),
              onChanged: manager.updateDateSheetDescription,
              style: TextStyle(
                fontSize: 14, // Changed to match third TextFormField
                color: manager.data.dateSheetDescription.isEmpty
                    ? Colors.grey
                    : Colors
                          .grey
                          .shade500, // Changed to match third TextFormField
              ),
              // textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade700),
                ),
                contentPadding: const EdgeInsets.all(12),
                hintText: 'Enter Date Sheet Description',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: TextEditingController(
                text: manager.data.termDescription.isEmpty
                    ? ''
                    : manager.data.termDescription,
              ),
              onChanged: manager.updateTermDescription,
              style: TextStyle(
                fontSize: 14,
                color: manager.data.termDescription.isEmpty
                    ? Colors.grey
                    : Colors.grey.shade500,
              ),
              // textAlign: TextAlign.center,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade700),
                ),
                contentPadding: const EdgeInsets.all(12),
                hintText: 'Enter Examination Term Description',
                hintStyle: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
