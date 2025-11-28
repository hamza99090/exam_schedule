import 'package:flutter/material.dart';

class EditableClassHeader extends StatefulWidget {
  final String initialName;
  final Function(String) onNameChanged;
  final int classIndex;

  const EditableClassHeader({
    super.key,
    required this.initialName,
    required this.onNameChanged,
    required this.classIndex,
  });

  @override
  State<EditableClassHeader> createState() => _EditableClassHeaderState();
}

class _EditableClassHeaderState extends State<EditableClassHeader> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  Widget build(BuildContext context) {
    return _isEditing ? _buildEditField() : _buildDisplayText();
  }

  Widget _buildDisplayText() {
    return InkWell(
      onTap: () {
        setState(() {
          _isEditing = true;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          widget.initialName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildEditField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: _controller,
        autofocus: true,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 12,
        ),
        decoration: const InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        onSubmitted: (value) => _saveChanges(value),
      ),
    );
  }

  void _saveChanges(String newName) {
    if (newName.trim().isNotEmpty) {
      widget.onNameChanged(newName.trim());
    }
    setState(() {
      _isEditing = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
