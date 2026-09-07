import 'package:flutter/material.dart';
import '../../app/theme.dart';

class MedicalRecordsTab extends StatelessWidget {
  const MedicalRecordsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildSearchBar(),
        const SizedBox(height: 16),
        _buildFilterChips(),
        const SizedBox(height: 20),
        _buildSectionTitle('Recent Records'),
        const SizedBox(height: 12),
        _buildRecordCard(
          title: 'General Checkup',
          date: 'Sep 1, 2025',
          doctor: 'Dr. Maria Santos',
          type: 'Consultation',
        ),
        const SizedBox(height: 12),
        _buildRecordCard(
          title: 'Blood Test Results',
          date: 'Aug 15, 2025',
          doctor: 'Dr. Elena Reyes',
          type: 'Laboratory',
        ),
        const SizedBox(height: 12),
        _buildRecordCard(
          title: 'Dental Cleaning',
          date: 'Jul 20, 2025',
          doctor: 'Dr. Angelo Cruz',
          type: 'Dental',
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search records...',
          prefixIcon: Icon(Icons.search, color: AppTheme.mutedLight, size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Row(
      children: [
        _chip('All', true),
        const SizedBox(width: 8),
        _chip('Consultation', false),
        const SizedBox(width: 8),
        _chip('Laboratory', false),
        const SizedBox(width: 8),
        _chip('Dental', false),
      ],
    );
  }

  Widget _chip(String label, bool selected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selected ? AppTheme.primary : AppTheme.line,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: selected ? Colors.white : AppTheme.muted,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.ink,
      ),
    );
  }

  Widget _buildRecordCard({
    required String title,
    required String date,
    required String doctor,
    required String type,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description_outlined, color: AppTheme.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$doctor · $date',
                  style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppTheme.info.withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              type,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppTheme.info,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
