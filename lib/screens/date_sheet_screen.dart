import 'package:exam_schedule/screens/saved_date_sheets_screen.dart';
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
  // bool _hasUnsavedChanges = false;
  bool _showTable = false; // Track if table should be visible

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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                // backgroundColor: Colors.red.shade700,
                // foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            // In _showSaveDialog method, update the Save button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                if (fileName.isNotEmpty) {
                  // Check if there's any data to save
                  if (widget.manager.hasData) {
                    _saveDateSheet(fileName);
                    Navigator.of(context).pop();
                  } else {
                    // Show error - no data to save
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Please add some subjects before saving.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    // Don't close the dialog - let user add data first
                  }
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
      // _hasUnsavedChanges = false; // Reset after saving
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
      // _hasUnsavedChanges = true; // Track changes
      _showTable = true; // Show table when first row is added
    });

    // Scroll to bottom after a short delay to allow the UI to update
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Show the three-button popup when trying to exit
  // Future<bool> _showExitConfirmationDialog() async {
  //   final result = await showDialog<bool>(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (context) => AlertDialog(
  //       title: const Text('Unsaved Changes'),
  //       content: const Text(
  //         'You have unsaved changes. What would you like to do?',
  //       ),
  //       actions: [
  //         // Keep Editing button
  //         TextButton(
  //           onPressed: () => Navigator.pop(context, false),
  //           child: const Text('Keep Editing'),
  //         ),

  //         // Save button
  //         TextButton(
  //           onPressed: () {
  //             // Validate header first
  //             if (_headerFormKey.currentState!.validate()) {
  //               Navigator.pop(context, true); // Close confirmation dialog
  //               _showSaveDialog(); // Show save dialog
  //             } else {
  //               ScaffoldMessenger.of(context).showSnackBar(
  //                 const SnackBar(
  //                   content: Text('Please fill required fields before saving.'),
  //                   backgroundColor: Colors.red,
  //                 ),
  //               );
  //               Navigator.pop(context, false); // Stay on screen
  //             }
  //           },
  //           child: const Text('Save', style: TextStyle(color: Colors.green)),
  //         ),

  //         // Cancel (discard) button
  //         // Update the Discard button in the _showExitConfirmationDialog method
  //         TextButton(
  //           onPressed: () {
  //             // Reset the form to empty/default state
  //             widget.manager.resetToDefault();
  //             // _hasUnsavedChanges = false;
  //             Navigator.pop(context, true); // Allow navigation
  //           },
  //           child: const Text('Discard', style: TextStyle(color: Colors.red)),
  //         ),
  //       ],
  //     ),
  //   );

  //   // If result is true, allow navigation (either saved or discarded)
  //   // If result is false, stay on screen
  //   return result ?? false;
  // }

  @override
  void initState() {
    super.initState();

    // Listen to manager changes to track unsaved changes
    widget.manager.addListener(() {
      if (mounted) {
        setState(() {
          // _hasUnsavedChanges = true;
          _showTable = widget.manager.hasRows;
        });
      }
    });
    // Initialize table visibility
    _showTable = widget.manager.hasRows;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Only show dialog if there are unsaved changes
        // if (_hasUnsavedChanges) {
        //   return await _showExitConfirmationDialog();
        // }
        return true; // Allow exit if no unsaved changes
      },
      child: GestureDetector(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
        },
        behavior: HitTestBehavior.opaque,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Create Date Sheet'),
            backgroundColor: Colors.blue.shade700,
            foregroundColor: Colors.white,
            actions: [
              // Saved files button with badge
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.folder_copy_rounded),
                    tooltip: "Saved Date Sheets",
                    onPressed: () {
                      // Check for unsaved changes before navigating
                      // if (_hasUnsavedChanges) {
                      //   _showExitConfirmationDialog().then((allowNavigation) {
                      //     if (allowNavigation) {
                      //       Navigator.push(
                      //         context,
                      //         MaterialPageRoute(
                      //           builder: (_) => SavedDateSheetsScreen(
                      //             manager: widget.manager,
                      //           ),
                      //         ),
                      //       );
                      //     }
                      //   });
                      // } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              SavedDateSheetsScreen(manager: widget.manager),
                        ),
                      );
                    },
                  ),

                  // Badge
                  if (widget.manager.savedDateSheets.isNotEmpty)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          widget.manager.savedDateSheets.length.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Create Date Sheet',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              // If a header Form exists, validate it first. Otherwise proceed.
                              final formState = _headerFormKey.currentState;
                              if (formState != null) {
                                if (formState.validate()) {
                                  // Check if there's data to save
                                  if (widget.manager.hasData) {
                                    _showSaveDialog();
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Please add some subjects before saving.',
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please fill required fields before saving.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              } else {
                                // No form in header (image-only header), check data
                                if (widget.manager.hasData) {
                                  _showSaveDialog();
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please add some subjects before saving.',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.save, size: 20),
                            label: const Text('Save'),
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(4),
                                ),
                              ),
                              backgroundColor: Colors.blue.shade700,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Replace the InteractiveTable section (around line 265-268) with:
                      if (_showTable) ...[
                        // Interactive Table - This grows with rows
                        InteractiveTable(
                          manager: widget.manager,
                          isEditing: true,
                        ),
                        const SizedBox(height: 16),
                      ],

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
      ),
    );
  }
}
