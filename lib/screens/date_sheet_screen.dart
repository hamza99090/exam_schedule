import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../managers/date_sheet_manager.dart';
import '../widgets/header/header_section.dart';
import '../widgets/table/interactive_table.dart';

class DateSheetScreen extends StatefulWidget {
  final DateSheetManager manager;

  const DateSheetScreen({super.key, required this.manager});

  @override
  State<DateSheetScreen> createState() => _DateSheetScreenState();
}

class _DateSheetScreenState extends State<DateSheetScreen> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<FormState> _headerFormKey = GlobalKey<FormState>();

  void _showSaveDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String fileName = '';
        return AlertDialog(
          title: const Text('Save Date Sheet'),
          content: TextField(
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'File Name',
              hintText: 'Enter DateSheet Name',
            ),
            onChanged: (value) {
              fileName = value;
            },
            onSubmitted: (value) {
              _saveDateSheet(value);
              Navigator.of(context).pop();
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (fileName.isNotEmpty) {
                  _saveDateSheet(fileName);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _saveDateSheet(String fileName) {
    setState(() {
      widget.manager.saveDateSheet(fileName);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Date sheet "$fileName" saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _addNewRowAndScroll() {
    setState(() {
      widget.manager.addNewRow();
    });

    // Scroll to bottom after a short delay to allow the UI to update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        SystemChannels.textInput.invokeMethod('TextInput.hide');
      },
      behavior: HitTestBehavior.opaque,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Date Sheet'),
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () {
                // validate header
                if (_headerFormKey.currentState!.validate()) {
                  _showSaveDialog(); // Only open save dialog if valid
                } else {
                  // If header invalid, show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        "Please fill required fields before saving.",
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },

              tooltip: 'Save Date Sheet',
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(16.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Section
                    HeaderSection(
                      manager: widget.manager,
                      formKey: _headerFormKey,
                    ),

                    const SizedBox(height: 24),

                    // "Create Date Sheet" title
                    Text(
                      'Create Date Sheet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Interactive Table - This grows with rows
                    InteractiveTable(manager: widget.manager, isEditing: true),

                    // Add New Row Button - Outside the card, moves down as table grows
                    Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.blue.shade600,
                              Colors.blue.shade800,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ElevatedButton.icon(
                          onPressed: _addNewRowAndScroll,
                          icon: const Icon(Icons.add),
                          label: const Text('Add New Row'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 32,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
