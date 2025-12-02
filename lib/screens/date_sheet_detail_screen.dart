import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:exam_schedule/models/table_row_model.dart';
import 'package:flutter/material.dart';
import '../managers/date_sheet_manager.dart';
import '../models/date_sheet_model.dart';
import '../widgets/header/header_section.dart';
import '../widgets/table/interactive_table.dart';

class DateSheetDetailScreen extends StatefulWidget {
  final DateSheetData dateSheet;
  final DateSheetManager manager;

  const DateSheetDetailScreen({
    super.key,
    required this.dateSheet,
    required this.manager,
  });

  @override
  State<DateSheetDetailScreen> createState() => _DateSheetDetailScreenState();
}

class _DateSheetDetailScreenState extends State<DateSheetDetailScreen> {
  late DateSheetData _editableDateSheet;
  bool _isEditing = false;
  late DateSheetManager _tempManager; // Add this line

  @override
  void initState() {
    super.initState();

    print('=== DETAIL SCREEN INIT ===');
    print('Received classNames: ${widget.dateSheet.classNames}');
    print(
      'First 3 classNames: ${widget.dateSheet.classNames.take(3).toList()}',
    );

    _editableDateSheet = widget.dateSheet.copyWith();
    _initializeTempManager();
  }

  // ADD THIS METHOD
  void _initializeTempManager() {
    print('=== INITIALIZING TEMP MANAGER ===');
    print('Editable sheet classNames: ${_editableDateSheet.classNames}');

    _tempManager = DateSheetManager();
    _tempManager.data = _editableDateSheet.copyWith();

    print('Temp manager classNames: ${_tempManager.data.classNames}');

    // Listen to changes from the InteractiveTable
    _tempManager.addListener(() {
      print('=== DETAIL: Temp manager notified ===');
      print('New classNames in tempManager: ${_tempManager.data.classNames}');
      setState(() {
        // Update our local copy with changes from the table
        _editableDateSheet = _tempManager.data.copyWith(
          fileName: _editableDateSheet.fileName,
          createdAt: _editableDateSheet.createdAt,
        );
      });
    });
  }

  void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });

    // If entering edit mode and there are rows, automatically open calendar for first row
    // if (_isEditing && _editableDateSheet.tableRows.isNotEmpty) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     _showDatePickerForFirstRow();
    //   });
    // }
  }

  void _showDatePickerForFirstRow() async {
    final currentDate = _editableDateSheet.tableRows[0].date;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _editableDateSheet.tableRows[0].date = picked;
        _editableDateSheet.tableRows[0].day = _getDayName(picked.weekday);
      });
    }
  }

  void _saveChanges() {
    // Update the original date sheet in manager
    final index = widget.manager.savedDateSheets.indexOf(widget.dateSheet);
    if (index != -1) {
      widget.manager.savedDateSheets[index] = _editableDateSheet.copyWith(
        createdAt: DateTime.now(),
      );
      widget.manager.notifyListeners();
    }

    setState(() {
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Changes saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _discardChanges() {
    setState(() {
      _editableDateSheet = widget.dateSheet.copyWith();
      _isEditing = false;
    });
  }

  void _addNewRow() {
    // Use tempManager instead of directly manipulating data
    _tempManager.addNewRow();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return '';
    }
  }

  // PDF Download functionality
  // PDF Download functionality - Saves to visible Downloads folder
  void _downloadDateSheet() async {
    try {
      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 2.0,
              ),
              SizedBox(width: 16),
              Text('Generating PDF...'),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 3),
        ),
      );

      // Generate PDF bytes
      final pdfBytes = await _generatePDFBytes();

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final fileName =
          '${_editableDateSheet.fileName.replaceAll(RegExp(r'[^\w\s-]'), '_')}.pdf';
      final tempFile = File('${tempDir.path}/$fileName');
      await tempFile.writeAsBytes(pdfBytes);

      // Share the file - User can save it wherever they want
      await Share.shareXFiles(
        [XFile(tempFile.path, mimeType: 'application/pdf')],
        subject: 'Date Sheet: ${_editableDateSheet.fileName}',
        text:
            'Here is your date sheet PDF. You can save it to your Downloads folder.',
      );

      print('✅ PDF shared successfully from: ${tempFile.path}');
    } catch (e) {
      print('Error saving/sharing PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Save to Downloads folder using different methods based on Android version
  Future<String> _saveToDownloadsFolder(Uint8List pdfBytes) async {
    final fileName =
        '${_editableDateSheet.fileName.replaceAll(RegExp(r'[^\w\s-]'), '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';

    if (Platform.isAndroid) {
      try {
        // Method 1: Try to get Downloads directory using getExternalStorageDirectory
        final directory = await getExternalStorageDirectory();
        if (directory != null) {
          // For Android 10+, we need to use scoped storage properly
          // Check Android version
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          final sdkVersion = androidInfo.version.sdkInt;

          String filePath;

          if (sdkVersion >= 29) {
            // Android 10+ - Save to app-specific Downloads folder
            final downloadsDir = await getDownloadsDirectory();
            if (downloadsDir != null) {
              filePath = '${downloadsDir.path}/$fileName';
            } else {
              // Fallback to app's external storage
              filePath = '${directory.path}/$fileName';
            }
          } else {
            // Android 9 and below - Save to public Downloads folder
            filePath = '${directory.path}/Download/$fileName';
            // Create Download folder if it doesn't exist
            final downloadDir = Directory('${directory.path}/Download');
            if (!await downloadDir.exists()) {
              await downloadDir.create(recursive: true);
            }
          }

          final file = File(filePath);
          await file.writeAsBytes(pdfBytes);
          print('✅ PDF saved to: $filePath');
          return filePath;
        }
      } catch (e) {
        print('External storage method failed: $e');
      }

      // Method 2: Try app's documents directory
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final file = File('${appDocDir.path}/$fileName');
        await file.writeAsBytes(pdfBytes);
        print('📁 Saved to app directory: ${file.path}');
        return file.path;
      } catch (e) {
        print('App directory method failed: $e');
        throw e;
      }
    }

    // For iOS or other platforms
    final appDocDir = await getApplicationDocumentsDirectory();
    final file = File('${appDocDir.path}/$fileName');
    await file.writeAsBytes(pdfBytes);
    return file.path;
  }

  // Helper method for Android 10+
  Future<String?> _saveUsingDownloadsDirectory(
    String fileName,
    Uint8List pdfBytes,
  ) async {
    try {
      // Try to get the Downloads directory
      final downloadsDir = await getDownloadsDirectory();
      if (downloadsDir != null) {
        final file = File('${downloadsDir.path}/$fileName');
        await file.writeAsBytes(pdfBytes);
        print('✅ Saved to Downloads directory: ${file.path}');
        return file.path;
      }
    } catch (e) {
      print('Downloads directory method failed: $e');
    }
    return null;
  }

  // Open the downloaded file
  void _openDownloadedFile(String filePath) async {
    try {
      // First check if file exists
      final file = File(filePath);
      if (await file.exists()) {
        // Open with share sheet so user can choose PDF viewer
        await Share.shareXFiles(
          [XFile(filePath, mimeType: 'application/pdf')],
          subject: 'Date Sheet PDF',
          text: 'Open this PDF file',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('File not found. Try downloading again.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error opening file: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cannot open file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _getFileNameFromPath(String path) {
    return path.split('/').last;
  }

  Future<Uint8List> _generatePDFBytes() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            // Header Section
            pw.Header(
              level: 0,
              child: pw.Text(
                _editableDateSheet.schoolName,
                style: pw.TextStyle(
                  fontSize: 24,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
            ),

            pw.SizedBox(height: 10),

            // Date Sheet Description
            pw.Text(
              _editableDateSheet.dateSheetDescription,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              textAlign: pw.TextAlign.center,
            ),

            pw.SizedBox(height: 8),

            // Term Description
            pw.Text(
              _editableDateSheet.termDescription,
              style: const pw.TextStyle(fontSize: 14),
              textAlign: pw.TextAlign.center,
            ),

            pw.SizedBox(height: 20),

            // Generation Date
            pw.Text(
              'Generated on: ${_formatDateForPDF(DateTime.now())}',
              style: pw.TextStyle(fontSize: 12, fontStyle: pw.FontStyle.italic),
            ),

            pw.SizedBox(height: 30),

            // Data Table
            _buildPDFTable(),

            pw.SizedBox(height: 30),

            // Footer
            pw.Text(
              'Official document - ${_editableDateSheet.schoolName}',
              style: pw.TextStyle(fontSize: 10, fontStyle: pw.FontStyle.italic),
              textAlign: pw.TextAlign.center,
            ),
          ];
        },
      ),
    );

    return await pdf.save();
  }

  pw.Widget _buildPDFTable() {
    final headers = ['S.No', 'Date', 'Day', ..._editableDateSheet.classNames];

    final rows = _editableDateSheet.tableRows.asMap().entries.map((entry) {
      final index = entry.key;
      final row = entry.value;

      // Build a list for this row
      List<String> rowData = [
        (index + 1).toString(), // S.No (starting from 1)
        row.date != null
            ? '${row.date!.day.toString().padLeft(2, '0')}/${row.date!.month.toString().padLeft(2, '0')}/${row.date!.year}'
            : '',
        row.day ?? '',
      ];

      // Add data for each class
      for (var className in _editableDateSheet.classNames) {
        if (row.classSubjects.containsKey(className)) {
          final subjects = row.classSubjects[className];
          if (subjects != null && subjects.isNotEmpty) {
            // Join multiple subjects with comma
            rowData.add(subjects.join(', '));
          } else {
            rowData.add('');
          }
        } else {
          rowData.add('');
        }
      }

      return rowData;
    }).toList();

    return pw.Table.fromTextArray(
      headers: headers,
      data: rows,
      border: pw.TableBorder.all(),
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12),
      cellStyle: const pw.TextStyle(fontSize: 10),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      rowDecoration: const pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5),
        ),
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(0.5), // S.No
        1: const pw.FlexColumnWidth(1.0), // Date
        2: const pw.FlexColumnWidth(0.8), // Day
        for (var i = 3; i < headers.length; i++)
          i: const pw.FlexColumnWidth(1.0),
      },
    );
  }

  String _formatDateForPDF(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editableDateSheet.fileName),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          // Add Download button here (first in the list)
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _downloadDateSheet,
            tooltip: 'Download as PDF',
          ),
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditing,
              tooltip: 'Edit Date Sheet',
            ),
          if (_isEditing) ...[
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: _discardChanges,
              tooltip: 'Discard Changes',
            ),
          ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildDateSheetTable(),
            const SizedBox(height: 16),
            if (_isEditing) _buildAddRowButton(),
          ],
        ),
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
              onPressed: _saveChanges,
              backgroundColor: Colors.green,
              child: const Icon(Icons.save, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // School Name - Only editable when in edit mode
            _isEditing
                ? TextFormField(
                    initialValue: _editableDateSheet.schoolName,
                    onChanged: (value) {
                      setState(() {
                        _editableDateSheet.schoolName = value;
                        _tempManager.updateSchoolName(value);
                      });
                    },
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Text(
                    _editableDateSheet.schoolName,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
            const SizedBox(height: 12),
            // Date Sheet Description - Only editable when in edit mode
            _isEditing
                ? TextFormField(
                    initialValue: _editableDateSheet.dateSheetDescription,
                    onChanged: (value) {
                      setState(() {
                        _editableDateSheet.dateSheetDescription =
                            value; // ← FIXED
                        _tempManager.updateDateSheetDescription(value);
                      });
                    },
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Text(
                    _editableDateSheet.dateSheetDescription,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),
            const SizedBox(height: 8),
            // Term Description - Only editable when in edit mode
            _isEditing
                ? TextFormField(
                    initialValue: _editableDateSheet.termDescription,
                    onChanged: (value) {
                      setState(() {
                        _editableDateSheet.termDescription = value; // ← FIXED
                        _tempManager.updateTermDescription(value);
                      });
                    },
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  )
                : Text(
                    _editableDateSheet.termDescription,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                    textAlign: TextAlign.center,
                  ),
            const SizedBox(height: 16),
            Text(
              '${_isEditing ? 'Editing' : 'Saved'} on: ${_formatDate(_editableDateSheet.createdAt)}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSheetTable() {
    // Use the persistent temp manager, not create a new one
    return InteractiveTable(
      manager: _tempManager, // ← Use _tempManager, not create new
      isEditing: _isEditing,
    );
  }

  Widget _buildAddRowButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ElevatedButton.icon(
        onPressed: _addNewRow,
        icon: const Icon(Icons.add),
        label: const Text('Add New Row'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade600,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
