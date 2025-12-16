import 'package:device_info_plus/device_info_plus.dart';
import 'package:image_picker/image_picker.dart';
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
  final bool openInEditMode; // ← NEW
  final bool autoDownload; // ← NEW

  const DateSheetDetailScreen({
    super.key,
    required this.dateSheet,
    required this.manager,
    this.openInEditMode = false, // Default false
    this.autoDownload = false, // Default false
  });

  @override
  State<DateSheetDetailScreen> createState() => _DateSheetDetailScreenState();
}

class _DateSheetDetailScreenState extends State<DateSheetDetailScreen> {
  late DateSheetData _editableDateSheet;
  bool _isEditing = false;
  late DateSheetManager _tempManager; // Add this line
  bool _hasAutoDownloaded = false; // Track if auto-download already happened
  // ADD THESE IMAGE PICKER METHODS:
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromGallery() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _editableDateSheet.logoPath = picked.path;
          _tempManager.updateLogoPath(picked.path);
        });
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
        setState(() {
          _editableDateSheet.logoPath = picked.path;
          _tempManager.updateLogoPath(picked.path);
        });
      }
    } catch (e) {
      debugPrint('Camera pick error: $e');
    }
  }

  void _removeImage() {
    // Manual object creation
    final newSheet = DateSheetData(
      schoolName: _editableDateSheet.schoolName,
      dateSheetDescription: _editableDateSheet.dateSheetDescription,
      termDescription: _editableDateSheet.termDescription,
      tableRows: List.from(
        _editableDateSheet.tableRows,
      ), // Important: create new list
      fileName: _editableDateSheet.fileName,
      createdAt: _editableDateSheet.createdAt,
      classNames: List.from(_editableDateSheet.classNames), // Create new list
      logoPath: null, // ← This is what matters
    );

    setState(() {
      _editableDateSheet = newSheet;
    });

    // Update temp manager
    _tempManager.data = newSheet;
    _tempManager.notifyListeners();
  }

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
    // If opened in edit mode, enable editing immediately
    if (widget.openInEditMode) {
      _isEditing = true;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Auto-download after first build
    if (widget.autoDownload && !_hasAutoDownloaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _performAutoDownload();
      });
    }
  }

  void _performAutoDownload() {
    _hasAutoDownloaded = true;
    print('=== AUTO DOWNLOAD TRIGGERED ===');

    // Show preparing message
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
        duration: Duration(seconds: 2),
      ),
    );

    // Trigger download after short delay
    Future.delayed(Duration(milliseconds: 500), () {
      _downloadDateSheet();

      // Automatically go back after download starts
      Future.delayed(Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    });
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
          logoPath: _tempManager.logoPath, // ADD THIS LINE
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
    // Check if there's any data
    bool hasData = false;
    for (var row in _editableDateSheet.tableRows) {
      for (var className in _editableDateSheet.classNames) {
        final subjects = row.classSubjects[className] ?? [];
        if (subjects.isNotEmpty &&
            subjects.any((s) => s.isNotEmpty && s != '-')) {
          hasData = true;
          break;
        }
      }
      if (hasData) break;
    }

    if (!hasData) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cannot save empty date sheet. Add some subjects first.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Find the index of this date sheet
    final index = widget.manager.savedDateSheets.indexOf(widget.dateSheet);
    if (index != -1) {
      // Create updated sheet
      final updatedSheet = _editableDateSheet.copyWith(
        createdAt: DateTime.now(),
      );

      // Save to Hive via manager
      widget.manager.updateSavedDateSheet(index, updatedSheet);

      // Also update the local reference
      _editableDateSheet = updatedSheet;
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

    final totalColumns = _editableDateSheet.classNames.length + 3;
    final shouldUseLandscape = totalColumns > 10;

    final pageFormat = shouldUseLandscape
        ? PdfPageFormat.a4.landscape
        : PdfPageFormat.a4;

    // Get logo bytes if available
    final Uint8List? logoBytes = await _getLogoBytes();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            // Logo and School Name in a Row
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
              _editableDateSheet.schoolName,
              style: pw.TextStyle(
                fontSize: shouldUseLandscape ? 22 : 24,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),

            pw.SizedBox(height: 10),

            // Date Sheet Description
            pw.Text(
              _editableDateSheet.dateSheetDescription,
              style: pw.TextStyle(
                fontSize: shouldUseLandscape ? 16 : 18,
                fontWeight: pw.FontWeight.bold,
              ),
              textAlign: pw.TextAlign.center,
            ),

            pw.SizedBox(height: 8),

            // Term Description
            pw.Text(
              _editableDateSheet.termDescription,
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
            _buildPDFTable(shouldUseLandscape),

            pw.SizedBox(height: 30),

            // // Footer
            // pw.Text(
            //   'Official document - ${_editableDateSheet.schoolName}',
            //   style: pw.TextStyle(fontSize: 9, fontStyle: pw.FontStyle.italic),
            //   textAlign: pw.TextAlign.center,
            // ),
          ];
        },
      ),
    );

    return await pdf.save();
  }

  // Add this helper method
  Future<Uint8List?> _getLogoBytes() async {
    try {
      // Check if logoPath exists and is not empty
      if (_editableDateSheet.logoPath != null &&
          _editableDateSheet.logoPath!.isNotEmpty) {
        final file = File(_editableDateSheet.logoPath!);

        // Check if file exists
        if (await file.exists()) {
          final bytes = await file.readAsBytes();

          // Debug log
          print('✅ Logo loaded for PDF: ${bytes.length} bytes');

          return bytes;
        } else {
          print('❌ Logo file does not exist: ${_editableDateSheet.logoPath}');
        }
      } else {
        print('ℹ️ No logo path available for PDF');
      }
    } catch (e) {
      print('❌ Error reading logo file: $e');
    }

    return null;
  }

  pw.Widget _buildPDFTable(bool isLandscape) {
    // 1. FIRST CHANGE: Original class names ka order preserve karein
    final List<String> originalClassNames = _editableDateSheet.classNames;

    // Filter to only include classes that have at least one subject in any row
    final classesWithData = <String>{};

    for (var row in _editableDateSheet.tableRows) {
      for (var className in originalClassNames) {
        // 2. SECOND CHANGE: originalClassNames use karein
        final subjects = row.classSubjects[className];
        if (subjects != null &&
            subjects.isNotEmpty &&
            subjects.any((s) => s.isNotEmpty && s != '-')) {
          classesWithData.add(className);
        }
      }
    }

    // If no classes have data, use all class names
    final headers = [
      'S.No',
      'Date',
      'Day',
      // 3. THIRD CHANGE: Original order mein classes add karein
      ...(classesWithData.isNotEmpty
          ? originalClassNames
                .where((className) => classesWithData.contains(className))
                .toList()
          : originalClassNames),
    ];

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

      // Add data only for classes with data (or all classes if none have data)
      // 4. FOURTH CHANGE: Original order mein classesToShow banaein
      final classesToShow = classesWithData.isNotEmpty
          ? originalClassNames
                .where((className) => classesWithData.contains(className))
                .toList()
          : originalClassNames;

      for (var className in classesToShow) {
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

    // Remove empty rows (rows with no data in any class)
    rows.removeWhere((row) => row.skip(3).every((cell) => cell.isEmpty));

    // If after filtering there are no rows, add a placeholder
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
        0: const pw.FixedColumnWidth(28), // S.No
        1: const pw.FixedColumnWidth(65), // Date
        2: const pw.FixedColumnWidth(50), // Day
        // For class columns, let them be flexible
        for (var i = 3; i < headers.length; i++)
          i: const pw.FlexColumnWidth(1.0),
      },
      headerAlignment: pw.Alignment.center,
      cellAlignment: pw.Alignment.center,
      cellPadding: const pw.EdgeInsets.all(3),
    );
  }

  String _formatDateForPDF(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _editableDateSheet.fileName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,

        actions: [
          // Show edit button only if NOT in auto-download mode
          if (!widget.autoDownload && !_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditing,
              tooltip: 'Edit Date Sheet',
            ),
          // Download button - show only if NOT in auto-download mode
          if (!widget.autoDownload)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: _downloadDateSheet,
              tooltip: 'Download as PDF',
            ),
          // if (_isEditing) ...[
          //   IconButton(
          //     icon: const Icon(Icons.cancel),
          //     onPressed: _discardChanges,
          //     tooltip: 'Discard Changes',
          //   ),
          // ],
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 16),
            _buildDateSheetTable(),
            const SizedBox(height: 16),
            if (_isEditing)
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: _buildAddRowButton(),
              ),
          ],
        ),
      ),
      floatingActionButton: _isEditing
          ? FloatingActionButton(
              onPressed: _saveChanges,
              backgroundColor: Colors.blue.shade700,
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
            // LOGO SECTION - Editable in edit mode
            if (_isEditing) ...[
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
                          (_editableDateSheet.logoPath != null &&
                              _editableDateSheet.logoPath!.isNotEmpty)
                          ? FileImage(File(_editableDateSheet.logoPath!))
                                as ImageProvider
                          : null,
                      child:
                          (_editableDateSheet.logoPath == null ||
                              _editableDateSheet.logoPath!.isEmpty)
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
                        if (_editableDateSheet.logoPath != null &&
                            _editableDateSheet.logoPath!.isNotEmpty)
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
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ] else if (_editableDateSheet.logoPath != null &&
                _editableDateSheet.logoPath!.isNotEmpty) ...[
              // Show logo in view mode if exists
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage:
                      FileImage(File(_editableDateSheet.logoPath!))
                          as ImageProvider,
                ),
              ),
            ],

            const SizedBox(height: 12),

            // // School Name - Editable when in edit mode
            // _isEditing
            //     ? TextFormField(
            //         initialValue: _editableDateSheet.schoolName,
            //         onChanged: (value) {
            //           setState(() {
            //             _editableDateSheet.schoolName = value;
            //             _tempManager.updateSchoolName(value);
            //           });
            //         },
            //         style: TextStyle(
            //           fontSize: 20,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.blue.shade800,
            //         ),
            //         textAlign: TextAlign.center,
            //         decoration: const InputDecoration(
            //           border: InputBorder.none,
            //           contentPadding: EdgeInsets.zero,
            //         ),
            //       )
            //     : Text(
            //         _editableDateSheet.schoolName,
            //         style: TextStyle(
            //           fontSize: 20,
            //           fontWeight: FontWeight.bold,
            //           color: Colors.blue.shade800,
            //         ),
            //         textAlign: TextAlign.center,
            //       ),

            // const SizedBox(height: 12),

            // // Date Sheet Description
            // _isEditing
            //     ? TextFormField(
            //         initialValue: _editableDateSheet.dateSheetDescription,
            //         onChanged: (value) {
            //           setState(() {
            //             _editableDateSheet.dateSheetDescription = value;
            //             _tempManager.updateDateSheetDescription(value);
            //           });
            //         },
            //         style: const TextStyle(
            //           fontSize: 16,
            //           fontWeight: FontWeight.w600,
            //         ),
            //         textAlign: TextAlign.center,
            //         decoration: const InputDecoration(
            //           border: InputBorder.none,
            //           contentPadding: EdgeInsets.zero,
            //         ),
            //       )
            //     : Text(
            //         _editableDateSheet.dateSheetDescription,
            //         style: const TextStyle(
            //           fontSize: 16,
            //           fontWeight: FontWeight.w600,
            //         ),
            //         textAlign: TextAlign.center,
            //       ),

            // const SizedBox(height: 8),

            // Term Description
            // _isEditing
            //     ? TextFormField(
            //         initialValue: _editableDateSheet.termDescription,
            //         onChanged: (value) {
            //           setState(() {
            //             _editableDateSheet.termDescription = value;
            //             _tempManager.updateTermDescription(value);
            //           });
            //         },
            //         style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            //         textAlign: TextAlign.center,
            //         decoration: const InputDecoration(
            //           border: InputBorder.none,
            //           contentPadding: EdgeInsets.zero,
            //         ),
            //       )
            //     : Text(
            //         _editableDateSheet.termDescription,
            //         style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            //         textAlign: TextAlign.center,
            //       ),
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
      padding: const EdgeInsets.only(top: 16.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade700,
          borderRadius: BorderRadius.circular(12),
        ),
        child: ElevatedButton.icon(
          onPressed: _addNewRow,
          icon: const Icon(Icons.add),
          label: const Text('Add New Row'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 120),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            elevation: 0,
          ),
        ),
      ),
    );
  }
}
