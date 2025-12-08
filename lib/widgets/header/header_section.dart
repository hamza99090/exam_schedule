import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  String? _imagePath;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imagePath = widget.manager.logoPath;
    widget.manager.addListener(_onManagerUpdated);
  }

  void _onManagerUpdated() {
    if (mounted) {
      setState(() {
        _imagePath = widget.manager.logoPath;
      });
    }
  }

  @override
  void dispose() {
    widget.manager.removeListener(_onManagerUpdated);
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // ADD THIS TEXT/LABEL
            Text(
              'Upload Logo here',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
            const SizedBox(height: 16), // Add spacing
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
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          // padding: const EdgeInsets.symmetric(
                          //   horizontal: 16,
                          //   vertical: 10,
                          // ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _pickFromCamera,
                        icon: const Icon(Icons.camera_alt, size: 20),
                        label: const Text('Camera'),
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                          ),
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          // padding: const EdgeInsets.symmetric(
                          //   horizontal: 16,
                          //   vertical: 10,
                          // ),
                        ),
                      ),
                      if (_imagePath != null && _imagePath!.isNotEmpty)
                        OutlinedButton.icon(
                          onPressed: _removeImage,
                          icon: const Icon(Icons.delete_outline, size: 20),
                          label: const Text('Remove'),
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(
                                Radius.circular(4),
                              ),
                            ),
                            backgroundColor: Colors.blue.shade700,
                            foregroundColor: Colors.white,
                            // padding: const EdgeInsets.symmetric(
                            //   horizontal: 16,
                            //   vertical: 10,
                            // ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // No text fields here by design — header now contains only the image picker UI.
          ],
        ),
      ),
    );
  }
}
