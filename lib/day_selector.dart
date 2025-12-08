import 'package:flutter/material.dart';

class DaySelector extends StatelessWidget {
  final String? selectedDay;
  final Function(String?) onDaySelected;
  final bool enabled; // Add this parameter

  DaySelector({
    super.key,
    required this.selectedDay,
    required this.onDaySelected,
    this.enabled = false, // Default to false to disable dropdown
  });

  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  Widget build(BuildContext context) {
    print('=== DAY SELECTOR: Building with selectedDay: $selectedDay ===');

    if (!enabled) {
      // Read-only display when not enabled
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          selectedDay ?? ' Day',
          style: TextStyle(
            color: selectedDay == null ? Colors.grey : Colors.black87,
            fontSize: 11,
          ),
        ),
      );
    }

    // Editable dropdown when enabled (though you'll probably never use this)
    return DropdownButtonFormField<String>(
      value: selectedDay,
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
      onChanged: onDaySelected,
    );
  }
}
