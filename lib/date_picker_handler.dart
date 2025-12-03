import 'package:flutter/material.dart';

class DatePickerHandler extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime?) onDateSelected;
  final Function(String) onDayUpdated;
  final bool enabled;

  const DatePickerHandler({
    super.key,
    this.initialDate,
    required this.onDateSelected,
    required this.onDayUpdated,
    this.enabled = true,
  });

  @override
  State<DatePickerHandler> createState() => _DatePickerHandlerState();
}

class _DatePickerHandlerState extends State<DatePickerHandler> {
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });

      // Call both callbacks
      widget.onDateSelected(picked);

      // Force day update
      final dayName = _getDayName(picked.weekday);
      print('Setting day to: $dayName for date: $picked');
      widget.onDayUpdated(dayName);
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return 'Mon';
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Tap to add date';
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.enabled ? _selectDate : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.calendar_today, size: 16, color: Colors.blue.shade600),
            const SizedBox(width: 8),
            Text(
              _formatDate(_selectedDate),
              style: TextStyle(
                color: _selectedDate == null ? Colors.grey : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
