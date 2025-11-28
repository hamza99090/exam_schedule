import 'package:flutter/material.dart';
import '../managers/date_sheet_manager.dart';
import '../models/date_sheet_model.dart';
import 'date_sheet_detail_screen.dart'; // Add this import

class SavedDateSheetsScreen extends StatelessWidget {
  final DateSheetManager manager;

  const SavedDateSheetsScreen({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Date Sheets'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: manager.savedDateSheets.isEmpty
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
              itemCount: manager.savedDateSheets.length,
              itemBuilder: (context, index) {
                final dateSheet = manager.savedDateSheets[index];
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
        leading: const Icon(Icons.assignment, color: Colors.blue),
        title: Text(
          dateSheet.fileName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(dateSheet.schoolName),
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
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.blue),
              onPressed: () => _viewDateSheet(context, dateSheet),
              tooltip: 'View Date Sheet',
            ),
            IconButton(
              icon: const Icon(Icons.download, color: Colors.green),
              onPressed: () => _loadDateSheet(context, dateSheet),
              tooltip: 'Load Date Sheet',
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteDateSheet(context, index),
              tooltip: 'Delete Date Sheet',
            ),
          ],
        ),
        onTap: () => _viewDateSheet(context, dateSheet),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _viewDateSheet(BuildContext context, DateSheetData dateSheet) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DateSheetDetailScreen(dateSheet: dateSheet),
      ),
    );
  }

  void _loadDateSheet(BuildContext context, DateSheetData dateSheet) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Load Date Sheet'),
        content: Text(
          'Load "${dateSheet.fileName}" to editor? This will replace your current work.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              manager.loadDateSheet(dateSheet);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to main screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Loaded "${dateSheet.fileName}" successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Load'),
          ),
        ],
      ),
    );
  }

  void _deleteDateSheet(BuildContext context, int index) {
    final fileName = manager.savedDateSheets[index].fileName;
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
              manager.deleteDateSheet(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Deleted "$fileName" successfully!'),
                  backgroundColor: Colors.red,
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
