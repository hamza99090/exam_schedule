import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../managers/date_sheet_manager.dart';

class HeaderSection extends StatefulWidget {
  final DateSheetManager manager;
  final GlobalKey<FormState> formKey;
  final bool isEditing;

  const HeaderSection({
    super.key,
    required this.manager,
    required this.formKey,
    required this.isEditing,
  });

  @override
  State<HeaderSection> createState() => _HeaderSectionState();
}

class _HeaderSectionState extends State<HeaderSection> {
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  // Controllers for text fields
  final TextEditingController _schoolNameController = TextEditingController();
  final TextEditingController _examDescController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _imagePath = widget.manager.logoPath;

    // Initialize controllers with current data
    _schoolNameController.text = widget.manager.data.schoolName;
    _examDescController.text = widget.manager.data.dateSheetDescription;

    widget.manager.addListener(_onManagerUpdated);
  }

  void _onManagerUpdated() {
    if (mounted) {
      setState(() {
        _imagePath = widget.manager.logoPath;

        // Update controllers if manager data changes
        if (_schoolNameController.text != widget.manager.data.schoolName) {
          _schoolNameController.text = widget.manager.data.schoolName;
        }
        if (_examDescController.text !=
            widget.manager.data.dateSheetDescription) {
          _examDescController.text = widget.manager.data.dateSheetDescription;
        }
      });
    }
  }

  @override
  void dispose() {
    widget.manager.removeListener(_onManagerUpdated);
    _schoolNameController.dispose();
    _examDescController.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        widget.manager.updateLogoPath(picked.path);
      }
    } catch (e) {
      debugPrint('Gallery pick error: $e');
    }
  }

  Future<void> _pickFromCamera() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        widget.manager.updateLogoPath(picked.path);
      }
    } catch (e) {
      debugPrint('Camera pick error: $e');
    }
  }

  void _removeImage() {
    widget.manager.updateLogoPath(null);
  }

  // Method to validate school name field
  String? _validateSchoolName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'School name is required';
    }
    return null;
  }

  // Method to save school name to manager
  void _saveSchoolName(String value) {
    if (value.trim().isNotEmpty) {
      widget.manager.updateSchoolName(value.trim());
    }
  }

  // Method to save exam description to manager
  void _saveExamDescription(String value) {
    widget.manager.updateDateSheetDescription(value.trim());
  }

  // Show dialog for editing header info
  Future<void> _showHeaderInfoDialog() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Header Information'),
          content: SingleChildScrollView(
            child: Form(
              key: widget.formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // School Name Field
                  Text(
                    'School Name *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _schoolNameController,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Enter school name',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.blue.shade700,
                          width: 2.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    validator: _validateSchoolName,
                    onChanged: _saveSchoolName,
                    textInputAction: TextInputAction.next,
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  // Exam Description Field
                  Text(
                    'Exam Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _examDescController,
                    decoration: InputDecoration(
                      hintText: 'Enter exam description (e.g., Final Exams)',
                      hintStyle: TextStyle(color: Colors.grey.shade400),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.blue.shade700,
                          width: 2.0,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onChanged: _saveExamDescription,
                    maxLines: 3,
                    textInputAction: TextInputAction.done,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (widget.formKey.currentState!.validate()) {
                  widget.formKey.currentState!.save();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo upload section
            Column(
              children: [
                Text(
                  'Upload Logo here',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage:
                            (_imagePath != null && _imagePath!.isNotEmpty)
                            ? FileImage(File(_imagePath!)) as ImageProvider
                            : null,
                        child: (_imagePath == null || _imagePath!.isEmpty)
                            ? Icon(
                                Icons.add_photo_alternate_sharp,
                                size: 48,
                                color: Colors.grey.shade600,
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      if (widget.isEditing) // Show buttons only in edit mode
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickFromGallery,
                              icon: const Icon(Icons.photo_library, size: 20),
                              label: const Text('Gallery'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _pickFromCamera,
                              icon: const Icon(Icons.camera_alt, size: 20),
                              label: const Text('Camera'),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(4),
                                  ),
                                ),
                                backgroundColor: Colors.blue.shade700,
                                foregroundColor: Colors.white,
                              ),
                            ),
                            if (_imagePath != null && _imagePath!.isNotEmpty)
                              OutlinedButton.icon(
                                onPressed: _removeImage,
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 20,
                                ),
                                label: const Text('Remove'),
                                style: OutlinedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(4),
                                    ),
                                  ),
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Header Information Display with Edit Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Header Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      if (widget.isEditing)
                        IconButton(
                          onPressed: _showHeaderInfoDialog,
                          icon: const Icon(Icons.edit),
                          color: Colors.blue.shade700,
                          tooltip: 'Edit Header Info',
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // School Name Display
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.school, size: 18, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _schoolNameController.text.isNotEmpty
                              ? _schoolNameController.text
                              : 'No school name entered',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: _schoolNameController.text.isNotEmpty
                                ? Colors.grey.shade800
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Exam Description Display
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.description,
                        size: 18,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _examDescController.text.isNotEmpty
                              ? _examDescController.text
                              : 'No exam description entered',
                          style: TextStyle(
                            fontSize: 16,
                            color: _examDescController.text.isNotEmpty
                                ? Colors.grey.shade700
                                : Colors.grey.shade500,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (!widget.isEditing) ...[
                    const SizedBox(height: 12),
                    Text(
                      'Read-only mode',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
