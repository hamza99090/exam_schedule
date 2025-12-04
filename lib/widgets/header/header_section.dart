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

    schoolController = TextEditingController(
      text: widget.manager.data.schoolName,
    );
    descriptionController = TextEditingController(
      text: widget.manager.data.dateSheetDescription,
    );
    termController = TextEditingController(
      text: widget.manager.data.termDescription,
    );

    // Listen for changes in manager (e.g., after saving)
    widget.manager.addListener(_updateControllers);
  }

  void _updateControllers() {
    schoolController.text = widget.manager.data.schoolName;
    descriptionController.text = widget.manager.data.dateSheetDescription;
    termController.text = widget.manager.data.termDescription;
  }

  @override
  void dispose() {
    widget.manager.removeListener(_updateControllers); // remove listener
    schoolController.dispose();
    descriptionController.dispose();
    termController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: widget.formKey, // ← full form here
          child: Column(
            children: [
              // -------------------- 1. SCHOOL NAME --------------------
              TextFormField(
                controller: schoolController,
                onChanged: (value) {
                  widget.manager.updateSchoolName(value);
                },
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

              const SizedBox(height: 12),

              // -------------------- 2. DATE SHEET DESCRIPTION --------------------
              TextFormField(
                controller: descriptionController,
                onChanged: (value) {
                  widget.manager.updateDateSheetDescription(value);
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Description is required";
                  }
                  return null;
                },
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
                  hintText: 'Enter Date Sheet Description *',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // -------------------- 3. TERM DESCRIPTION --------------------
              TextFormField(
                controller: termController,
                onChanged: (value) {
                  widget.manager.updateTermDescription(value);
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Term description is required";
                  }
                  return null;
                },
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
                  hintText: 'Enter Examination Term Description *',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
