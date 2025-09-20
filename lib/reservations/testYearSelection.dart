import 'package:flutter/material.dart';

class AcademicYearSelector extends StatefulWidget {
  final ValueChanged<String> onYearSelected;
  final String? initialValue;

  const AcademicYearSelector({
    super.key,
    required this.onYearSelected,
    this.initialValue,
  });

  @override
  State<AcademicYearSelector> createState() => _AcademicYearSelectorState();
}

class _AcademicYearSelectorState extends State<AcademicYearSelector> {
  String? _selectedYear;
  final List<String> _availableYears = [];

  @override
  void initState() {
    super.initState();
    _generateAcademicYears();
    _selectedYear = widget.initialValue;
  }

  void _generateAcademicYears() {
    final currentYear = DateTime.now().year;
    // Generate years from 10 years ago to 10 years in the future
    for (int year = currentYear - 100; year <= currentYear + 100; year++) {
      _availableYears.add('$year-${year + 1}');
    }
  }

  String _getCurrentAcademicYear() {
    final now = DateTime.now();
    final currentYear = now.year;
    // If current month is after June, it's the next academic year
    if (now.month >= 6) {
      return '$currentYear-${currentYear + 1}';
    } else {
      return '${currentYear - 1}-$currentYear';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: DropdownButtonFormField<String>(
          value: _selectedYear ?? _getCurrentAcademicYear(),
          decoration: InputDecoration(
            labelText: 'Academic Year',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: _availableYears.map((String year) {
            return DropdownMenuItem<String>(
              value: year,
              child: Text(
                year,
                style: const TextStyle(fontSize: 16),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedYear = newValue;
            });
            if (newValue != null) {
              widget.onYearSelected(newValue);
            }
          },
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
