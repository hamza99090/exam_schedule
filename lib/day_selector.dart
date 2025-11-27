import 'package:flutter/material.dart';

class DaySelector extends StatefulWidget {
  final String? initialDay;
  final Function(String?) onDaySelected;

  const DaySelector({super.key, this.initialDay, required this.onDaySelected});

  @override
  State<DaySelector> createState() => _DaySelectorState();
}

class _DaySelectorState extends State<DaySelector> {
  String? _selectedDay;

  final List<String> _days = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDay = widget.initialDay;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: _selectedDay,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      hint: const Text('Select Day'),
      items: _days.map((String day) {
        return DropdownMenuItem(value: day, child: Text(day));
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedDay = newValue;
        });
        widget.onDaySelected(newValue);
      },
    );
  }
}
