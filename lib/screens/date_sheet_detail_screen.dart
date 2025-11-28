import 'package:exam_schedule/models/table_row_model.dart';
import 'package:flutter/material.dart';
import '../managers/date_sheet_manager.dart';
import '../models/date_sheet_model.dart';
import '../widgets/header/header_section.dart';
import '../widgets/table/interactive_table.dart';

class DateSheetDetailScreen extends StatelessWidget {
  final DateSheetData dateSheet;

  const DateSheetDetailScreen({super.key, required this.dateSheet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dateSheet.fileName),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () => _printDateSheet(context),
            tooltip: 'Print Date Sheet',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareDateSheet(context),
            tooltip: 'Share Date Sheet',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Section
            _buildHeaderCard(),
            const SizedBox(height: 16),

            // Date Sheet Table
            _buildDateSheetTable(),
            const SizedBox(height: 16),

            // Summary Information
            _buildSummaryCard(),
          ],
        ),
      ),
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
            Text(
              dateSheet.schoolName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              dateSheet.dateSheetDescription,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              dateSheet.termDescription,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Saved on: ${_formatDate(dateSheet.createdAt)}',
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
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingTextStyle: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontSize: 12,
            ),
            headingRowColor: MaterialStateProperty.all(Colors.blue.shade700),
            dataTextStyle: const TextStyle(fontSize: 11),
            columns: const [
              DataColumn(label: Text('DATE')),
              DataColumn(label: Text('DAY')),
              DataColumn(label: Text('I')),
              DataColumn(label: Text('II')),
              DataColumn(label: Text('III')),
              DataColumn(label: Text('IV')),
              DataColumn(label: Text('V')),
              DataColumn(label: Text('VI')),
              DataColumn(label: Text('VII')),
              DataColumn(label: Text('VIII')),
              DataColumn(label: Text('IX')),
              DataColumn(label: Text('X')),
              DataColumn(label: Text('XI')),
              DataColumn(label: Text('XII')),
            ],
            rows: dateSheet.tableRows.map((rowData) {
              return DataRow(
                cells: [
                  _buildDateCell(rowData),
                  _buildDayCell(rowData),
                  ..._buildClassCells(rowData),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  DataCell _buildDateCell(TableRowData rowData) {
    return DataCell(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Text(
              _formatTableDate(rowData.date),
              style: const TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  DataCell _buildDayCell(TableRowData rowData) {
    return DataCell(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Text(
          rowData.day ?? 'Not set',
          style: TextStyle(
            color: rowData.day == null ? Colors.grey : Colors.black87,
          ),
        ),
      ),
    );
  }

  List<DataCell> _buildClassCells(TableRowData rowData) {
    return [
          'I',
          'II',
          'III',
          'IV',
          'V',
          'VI',
          'VII',
          'VIII',
          'IX',
          'X',
          'XI',
          'XII',
        ]
        .map(
          (classNum) => DataCell(
            SizedBox(
              width: 100,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  color: _getSubjectColor(rowData.classSubjects[classNum]),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _formatSubjects(rowData.classSubjects[classNum]),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getTextColor(rowData.classSubjects[classNum]),
                  ),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _buildSummaryCard() {
    final totalRows = dateSheet.tableRows.length;
    final rowsWithDate = dateSheet.tableRows
        .where((row) => row.date != null)
        .length;
    final rowsWithDay = dateSheet.tableRows
        .where((row) => row.day != null)
        .length;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Date Sheet Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total Rows:'),
                Text(
                  '$totalRows',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rows with Date:'),
                Text(
                  '$rowsWithDate',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Rows with Day:'),
                Text(
                  '$rowsWithDay',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} at ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatTableDate(DateTime? date) {
    if (date == null) return 'Not set';
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  String _formatSubjects(List<String>? subjects) {
    if (subjects == null || subjects.isEmpty) return 'No subjects';
    if (subjects.contains('—') && subjects.length == 1) return '—';
    final validSubjects = subjects.where((subject) => subject != '—').toList();
    if (validSubjects.isEmpty) return '—';
    return validSubjects.join(' / ');
  }

  Color _getSubjectColor(List<String>? subjects) {
    if (subjects == null || subjects.isEmpty) return Colors.grey.shade100;
    if (subjects.contains('—') && subjects.length == 1)
      return Colors.orange.shade100;
    return Colors.green.shade50;
  }

  Color _getTextColor(List<String>? subjects) {
    if (subjects == null || subjects.isEmpty) return Colors.grey;
    if (subjects.contains('—') && subjects.length == 1)
      return Colors.orange.shade800;
    return Colors.green.shade800;
  }

  void _printDateSheet(BuildContext context) {
    // TODO: Implement print functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print functionality coming soon!')),
    );
  }

  void _shareDateSheet(BuildContext context) {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }
}
