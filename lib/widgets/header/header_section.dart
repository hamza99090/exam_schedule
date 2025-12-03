import 'package:flutter/material.dart';
import '../../managers/date_sheet_manager.dart';

class HeaderSection extends StatefulWidget {
  final DateSheetManager manager;
  final GlobalKey<FormState> formKey;
  const HeaderSection({
    super.key,
    required this.manager,
    required this.formKey,
  });

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController schoolController;
  late TextEditingController descriptionController;
  late TextEditingController termController;

  @override
  void initState() {
    super.initState();

    // Move controllers here to prevent rebuild issues
    schoolController = TextEditingController(
      text: widget.manager.data.schoolName,
    );

    descriptionController = TextEditingController(
      text: widget.manager.data.dateSheetDescription,
    );

    termController = TextEditingController(
      text: widget.manager.data.termDescription,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // -------------------- REQUIRED FIELD --------------------
            Form(
              key: widget.formKey,
              child: TextFormField(
                controller: schoolController,
                // onChanged: widget.manager.updateSchoolName,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "School name is required";
                  }
                  return null;
                },
                style: TextStyle(
                  fontSize: 14,
                  color: widget.manager.data.schoolName.isEmpty
                      ? Colors.grey
                      : Colors.grey.shade500,
                ),
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue.shade700),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  hintText: 'Enter Your School Name *',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ),

            // ----------------------------------------------------------
            const SizedBox(height: 12),

            // -------------------- SECOND TEXTFIELD (UNCHANGED) --------------------
            TextFormField(
              controller: descriptionController,
              onChanged: widget.manager.updateDateSheetDescription,
              style: TextStyle(
                fontSize: 14,
                color: widget.manager.data.dateSheetDescription.isEmpty
                    ? Colors.grey
                    : Colors.grey.shade500,
              ),
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

            // -------------------- THIRD TEXTFIELD (UNCHANGED) --------------------
            TextFormField(
              controller: termController,
              onChanged: widget.manager.updateTermDescription,
              style: TextStyle(
                fontSize: 14,
                color: widget.manager.data.termDescription.isEmpty
                    ? Colors.grey
                    : Colors.grey.shade500,
              ),
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
