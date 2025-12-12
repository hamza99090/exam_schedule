import 'package:flutter/material.dart';
import '../managers/date_sheet_manager.dart';
import '../models/date_sheet_model.dart';
import 'date_sheet_detail_screen.dart';

class SavedDateSheetsScreen extends StatefulWidget {
  final DateSheetManager manager;

  const SavedDateSheetsScreen({super.key, required this.manager});

  @override
  State<SavedDateSheetsScreen> createState() => _SavedDateSheetsScreenState();
}

class _SavedDateSheetsScreenState extends State<SavedDateSheetsScreen> {
  late VoidCallback listener;
  @override
  void initState() {
    super.initState();
    // Listen to manager changes
    listener = () {
      setState(() {});
    };
    widget.manager.addListener(() {
      setState(() {}); // Rebuild when manager changes
    });
  }

  @override
  void dispose() {
    // Remove listener to prevent memory leaks
    widget.manager.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Date Sheets'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: widget.manager.savedDateSheets.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.library_books, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No saved date sheets yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: widget.manager.savedDateSheets.length,
              itemBuilder: (context, index) {
                final dateSheet = widget.manager.savedDateSheets[index];
                return _buildDateSheetCard(context, dateSheet, index);
              },
            ),
    );
  }

  Widget _buildDateSheetCard(
    BuildContext context,
    DateSheetData dateSheet,
    int index,
  ) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        title: Text(
          dateSheet.fileName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Created: ${_formatDate(dateSheet.createdAt)}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            Text(
              'Rows: ${dateSheet.tableRows.length}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: Colors.grey.shade600,
                size: 20,
              ),
              onSelected: (value) async {
                if (value == 'rename') {
                  await _renameDateSheet(context, index, dateSheet);
                } else if (value == 'edit') {
                  _openForEdit(context, dateSheet);
                } else if (value == 'download') {
                  _openForDownload(context, dateSheet);
                } else if (value == 'delete') {
                  _deleteDateSheet(context, index);
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                  value: 'rename',
                  child: Row(
                    children: [
                      Icon(Icons.edit_note, color: Colors.blue),
                      SizedBox(width: 12),
                      Text('Rename'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.green),
                      SizedBox(width: 12),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'download',
                  child: Row(
                    children: [
                      Icon(Icons.download, color: Colors.purple),
                      SizedBox(width: 12),
                      Text('Download PDF'),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline, color: Colors.red),
                      SizedBox(width: 12),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
              padding: EdgeInsets.all(4),
            ),
          ],
        ),
        onTap: () => _viewDateSheet(context, dateSheet),
      ),
    );
  }

  // Rename functionality
  Future<void> _renameDateSheet(
    BuildContext context,
    int index,
    DateSheetData dateSheet,
  ) async {
    final TextEditingController renameController = TextEditingController(
      text: dateSheet.fileName,
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Date Sheet'),
        content: TextField(
          controller: renameController,
          autofocus: true,
          decoration: InputDecoration(
            labelText: 'New Name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (value) {
            _performRename(index, value.trim());
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              final newName = renameController.text.trim();
              if (newName.isNotEmpty) {
                _performRename(index, newName);
                Navigator.pop(context);
              }
            },
            child: Text('Rename'),
          ),
        ],
      ),
    );
  }

  void _performRename(int index, String newName) {
    final dateSheet = widget.manager.savedDateSheets[index];
    final updatedSheet = dateSheet.copyWith(fileName: newName);
    widget.manager.updateSavedDateSheet(index, updatedSheet);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Renamed to "$newName"'),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Open in edit mode (with edit mode enabled)
  void _openForEdit(BuildContext context, DateSheetData dateSheet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DateSheetDetailScreen(
          dateSheet: dateSheet,
          manager: widget.manager,
          openInEditMode: true, // ← NEW PARAMETER
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  // Open for download (automatically trigger download)
  void _openForDownload(BuildContext context, DateSheetData dateSheet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DateSheetDetailScreen(
          dateSheet: dateSheet,
          manager: widget.manager,
          autoDownload: true, // ← NEW PARAMETER
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _viewDateSheet(BuildContext context, DateSheetData dateSheet) {
    print('=== VIEWING SAVED SHEET ===');
    print('File: ${dateSheet.fileName}');
    print('Class names in saved sheet: ${dateSheet.classNames}');
    print(
      'Are they default? ${dateSheet.classNames == DateSheetData.defaultClassNames}',
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DateSheetDetailScreen(
          dateSheet: dateSheet,
          manager: widget.manager,
        ),
      ),
    );
  }

  void _deleteDateSheet(BuildContext context, int index) {
    final dateSheet = widget.manager.savedDateSheets[index];
    final fileName = dateSheet.fileName;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Date Sheet'),
        content: Text('Are you sure you want to delete "$fileName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              widget.manager.deleteDateSheet(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('"$fileName" deleted successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
