import 'dart:convert';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../utils/api_client.dart';
import 'app_text_field.dart';

/// Course / department dropdown loaded from GET /academic-programs, so the
/// mobile app offers exactly the same list as the web portal. Falls back to
/// a text field when the list cannot be loaded (offline).
class CourseDropdownField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CourseDropdownField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
  });

  @override
  State<CourseDropdownField> createState() => _CourseDropdownFieldState();
}

class _CourseDropdownFieldState extends State<CourseDropdownField> {
  final ApiClient _apiClient = ApiClient();
  List<({String department, List<String> courses})> _groups = [];
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    try {
      final res = await _apiClient.get('/academic-programs');
      if (res.statusCode != 200) throw Exception('Failed to load courses');
      final data = (jsonDecode(res.body)['data'] as List?) ?? [];
      final groups = data
          .map((g) => (
                department: (g['department'] ?? '').toString(),
                courses: ((g['courses'] as List?) ?? []).map((c) => c.toString()).toList(),
              ))
          .where((g) => g.courses.isNotEmpty)
          .toList();
      if (!mounted) return;
      setState(() {
        _groups = groups;
        _loading = false;
        _failed = groups.isEmpty;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed) {
      return AppTextField(
        label: widget.label,
        hintText: 'e.g. BS Information Technology',
        controller: widget.controller,
        validator: widget.validator,
      );
    }

    final isDark = AppTheme.isDark(context);
    final ink = AppTheme.getInk(context);
    final mutedLight = AppTheme.getMutedLight(context);
    final line = AppTheme.getLine(context);
    final allCourses = _groups.expand((g) => g.courses).toList();
    final current = widget.controller.text;
    final hasLegacyValue = current.isNotEmpty && !allCourses.contains(current);

    final items = <DropdownMenuItem<String>>[
      if (hasLegacyValue) DropdownMenuItem(value: current, child: Text('$current (current)')),
      for (final group in _groups) ...[
        DropdownMenuItem<String>(
          enabled: false,
          value: '__${group.department}',
          child: Text(
            group.department.toUpperCase(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.primary),
          ),
        ),
        for (final course in group.courses)
          DropdownMenuItem<String>(
            value: course,
            child: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(course, overflow: TextOverflow.ellipsis),
            ),
          ),
      ],
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: ink, letterSpacing: 0.1),
        ),
        const SizedBox(height: 7),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.darkSurfaceSubtle : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: line, width: 1),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: current.isEmpty ? null : current,
            dropdownColor: AppTheme.getSurface(context),
            isExpanded: true,
            items: items,
            validator: widget.validator,
            onChanged: _loading
                ? null
                : (value) {
                    if (value == null || value.startsWith('__')) return;
                    setState(() => widget.controller.text = value);
                  },
            style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: ink),
            decoration: InputDecoration(
              hintText: _loading ? 'Loading courses…' : 'Select course / department',
              hintStyle: TextStyle(color: mutedLight, fontSize: 14),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: isDark ? AppTheme.primaryLight : AppTheme.primary, width: 1.8),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: AppTheme.danger, width: 1.5),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
