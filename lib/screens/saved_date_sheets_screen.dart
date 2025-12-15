import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import 'package:share_plus/share_plus.dart';
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
                  // NEW: Direct download without opening detail screen
                  _downloadDateSheetDirectly(context, dateSheet);
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

  // NEW: Direct download method
  void _downloadDateSheetDirectly(
    BuildContext context,
    DateSheetData dateSheet,
  ) async {
    try {
      // Show loading message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.0,
              ),
              SizedBox(width: 16),
              Text('Preparing PDF download...'),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );

      // Generate PDF bytes
      final pdfBytes = await _generatePDFForSavedSheet(dateSheet);

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName =
          '${dateSheet.fileName.replaceAll(RegExp(r'[^\w\s-]'), '_')}.pdf';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pdfBytes);

      // Share the file
      await Share.shareXFiles(
        [XFile(tempFile.path, mimeType: 'application/pdf')],
        subject: 'Date Sheet: ${dateSheet.fileName}',
        text: 'Here is your date sheet PDF from ${dateSheet.schoolName}',
      );

      print('✅ PDF downloaded successfully from saved screen');
    } catch (e) {
      print('Error downloading PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error downloading PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // NEW: Generate PDF for saved sheet
  Future<Uint8List> _generatePDFForSavedSheet(DateSheetData dateSheet) async {
    final pdf = pw.Document();

    final totalColumns = dateSheet.classNames.length + 3;
    final shouldUseLandscape = totalColumns > 10;

    final pageFormat = shouldUseLandscape
        ? PdfPageFormat.a4.landscape
        : PdfPageFormat.a4;

    // Get logo bytes if available
    final Uint8List? logoBytes = await _getLogoBytesForSavedSheet(dateSheet);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            // Logo and School Name
            if (logoBytes != null)
              pw.Center(
                child: pw.Container(
                  width: 60,
                  height: 60,
                  margin: const pw.EdgeInsets.only(bottom: 15),
                  child: pw.Image(
                    pw.MemoryImage(logoBytes),
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ),

            // School Name
            pw.Text(
              dateSheet.schoolName,
              style: pw.TextStyle(
                fontSize: shouldUseLandscape ? 22 : 24,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),

            pw.SizedBox(height: 10),

            // Date Sheet Description
            pw.Text(
              dateSheet.dateSheetDescription,
              style: pw.TextStyle(
                fontSize: shouldUseLandscape ? 16 : 18,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),

            pw.SizedBox(height: 8),

            // Term Description
            pw.Text(
              dateSheet.termDescription,
              style: pw.TextStyle(fontSize: shouldUseLandscape ? 12 : 14),
              textAlign: pw.TextAlign.center,
            ),

            pw.SizedBox(height: 20),

            // Generation Date
            pw.Text(
              'Generated on: ${_formatDateForPDF(DateTime.now())}',
              style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
            ),

            pw.SizedBox(height: 30),

            // Data Table
            _buildPDFTableForSavedSheet(dateSheet, shouldUseLandscape),
          ];
        },
      ),
    );

    return await pdf.save();
  }

  // NEW: Get logo bytes for saved sheet
  Future<Uint8List?> _getLogoBytesForSavedSheet(DateSheetData dateSheet) async {
    try {
      if (dateSheet.logoPath != null && dateSheet.logoPath!.isNotEmpty) {
        final file = File(dateSheet.logoPath!);
        if (await file.exists()) {
          return await file.readAsBytes();
        }
      }
    } catch (e) {
      print('Error reading logo: $e');
    }
    return null;
  }

  // NEW: Build PDF table for saved sheet
  pw.Widget _buildPDFTableForSavedSheet(
    DateSheetData dateSheet,
    bool isLandscape,
  ) {
    // 1. Pehle original class names ka order preserve karein
    final List<String> originalClassNames = dateSheet.classNames;
    final classesWithData = <String>{};

    for (var row in dateSheet.tableRows) {
      for (var className in originalClassNames) {
        final subjects = row.classSubjects[className];
        if (subjects != null &&
            subjects.isNotEmpty &&
            subjects.any((s) => s.isNotEmpty && s != '-')) {
          classesWithData.add(className);
        }
      }
    }

    final headers = [
      'S.No',
      'Date',
      'Day',
      // Sirf unhi classes ko include karein jo original order mein hain
      for (var className in originalClassNames)
        if (classesWithData.isEmpty || classesWithData.contains(className))
          className,
    ];

    final rows = dateSheet.tableRows.asMap().entries.map((entry) {
      final index = entry.key;
      final row = entry.value;

      List<String> rowData = [
        (index + 1).toString(),
        row.date != null
            ? '${row.date!.day.toString().padLeft(2, '0')}/${row.date!.month.toString().padLeft(2, '0')}/${row.date!.year}'
            : '',
        row.day ?? '',
      ];

      // 4. Data ko bhi original order mein add karein
      for (var className in originalClassNames) {
        if (classesWithData.isEmpty || classesWithData.contains(className)) {
          if (row.classSubjects.containsKey(className)) {
            final subjects = row.classSubjects[className];
            if (subjects != null && subjects.isNotEmpty) {
              rowData.add(subjects.join(', '));
            } else {
              rowData.add('');
            }
          } else {
            rowData.add('');
          }
        }
      }

      return rowData;
    }).toList();

    rows.removeWhere((row) => row.skip(3).every((cell) => cell.isEmpty));

    if (rows.isEmpty) {
      rows.add(['1', '', '', ...List.filled(headers.length - 3, '')]);
    }

    return pw.Table.fromTextArray(
      headers: headers,
      data: rows,
      border: pw.TableBorder.all(width: 0.5),
      headerStyle: pw.TextStyle(
        fontWeight: pw.FontWeight.bold,
        fontSize: isLandscape ? 9 : 10,
      ),
      cellStyle: pw.TextStyle(fontSize: isLandscape ? 8 : 9),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.3),
        ),
      ),
      columnWidths: {
        0: const pw.FixedColumnWidth(28),
        1: const pw.FixedColumnWidth(65),
        2: const pw.FixedColumnWidth(50),
        for (var i = 3; i < headers.length; i++)
          i: const pw.FlexColumnWidth(1.0),
      },
      headerAlignment: pw.Alignment.center,
      cellAlignment: pw.Alignment.center,
      cellPadding: const pw.EdgeInsets.all(3),
    );
  }

  // NEW: Format date for PDF
  String _formatDateForPDF(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ';
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

  // Open for download (automatically trigger download) - THIS IS NOW COMMENTED
  // void _openForDownload(BuildContext context, DateSheetData dateSheet) {
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => DateSheetDetailScreen(
  //         dateSheet: dateSheet,
  //         manager: widget.manager,
  //         autoDownload: true, // ← NEW PARAMETER
  //       ),
  //     ),
  //   );
  // }

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
