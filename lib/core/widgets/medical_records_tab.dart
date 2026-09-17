import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../features/medical_records/presentation/controllers/medical_record_controller.dart';
import '../../features/medical_records/domain/models/medical_record.dart';

class MedicalRecordsTab extends StatefulWidget {
  const MedicalRecordsTab({super.key});

  @override
  State<MedicalRecordsTab> createState() => _MedicalRecordsTabState();
}

class _MedicalRecordsTabState extends State<MedicalRecordsTab> {
  String _selectedCategory = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicalRecordController>().loadMedicalRecord();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MedicalRecordController>(
      builder: (context, controller, _) {
        if (controller.status == MedicalRecordStatus.loading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
        }

        if (controller.status == MedicalRecordStatus.error) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 56, color: AppTheme.danger),
                const SizedBox(height: 16),
                Text(
                  controller.error ?? 'Unable to load medical records.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 15),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () => controller.loadMedicalRecord(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        final record = controller.medicalRecord;
        if (record == null) {
          return const Center(
            child: Text('No medical record found.', style: TextStyle(color: AppTheme.muted)),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadMedicalRecord(),
          color: AppTheme.primary,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildPatientCard(record),
              const SizedBox(height: 16),
              _buildSearchBar(),
              const SizedBox(height: 12),
              _buildFilterChips(),
              const SizedBox(height: 20),
              if (_selectedCategory == 'All' || _selectedCategory == 'Conditions') ...[
                _buildSectionHeader('Current Conditions', record.conditions.length),
                ..._buildConditionsList(record.conditions),
                const SizedBox(height: 20),
              ],
              if (_selectedCategory == 'All' || _selectedCategory == 'Allergies') ...[
                _buildSectionHeader('Allergies', record.allergies.length),
                ..._buildAllergiesList(record.allergies),
                const SizedBox(height: 20),
              ],
              if (_selectedCategory == 'All' || _selectedCategory == 'Medications') ...[
                _buildSectionHeader('Current Medications', record.medications.length),
                ..._buildMedicationsList(record.medications),
                const SizedBox(height: 20),
              ],
              if (_selectedCategory == 'All' || _selectedCategory == 'History') ...[
                _buildSectionHeader('Clinical History', record.medicalHistory.length),
                ..._buildHistoryList(record.medicalHistory),
                const SizedBox(height: 20),
              ],
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPatientCard(MedicalRecord record) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                record.name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  record.status,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${record.type} · ${record.courseDept}',
            style: const TextStyle(fontSize: 13, color: Colors.white70),
          ),
          const SizedBox(height: 2),
          Text(
            'ID: ${record.patientId} · ${record.age} yrs · ${record.sex}',
            style: const TextStyle(fontSize: 12, color: Colors.white60),
          ),
          if (record.lastUpdated.isNotEmpty) ...[
            const Divider(color: Colors.white24, height: 18),
            Text(
              'Last Updated: ${record.lastUpdated}',
              style: const TextStyle(fontSize: 11, color: Colors.white60),
            ),
          ],
        ],
      ),
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
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search within medical records...',
          prefixIcon: const Icon(Icons.search, color: AppTheme.mutedLight, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18, color: AppTheme.muted),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final categories = ['All', 'Conditions', 'Allergies', 'Medications', 'History'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (val) => setState(() => _selectedCategory = cat),
              selectedColor: AppTheme.primary,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppTheme.muted,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 12,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isSelected ? AppTheme.primary : AppTheme.line),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.ink),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildConditionsList(List<Condition> conditions) {
    final filtered = conditions.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(_searchQuery) || c.notes.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return [const Text('No conditions recorded.', style: TextStyle(color: AppTheme.muted, fontSize: 13))];
    }

    return filtered.map((c) => _buildCard(
      icon: Icons.healing_outlined,
      title: c.name,
      subtitle: 'Status: ${c.status} · Diagnosed: ${c.diagnosedDate}',
      trailing: c.notes.isNotEmpty ? c.notes : null,
    )).toList();
  }

  List<Widget> _buildAllergiesList(List<Allergy> allergies) {
    final filtered = allergies.where((a) {
      if (_searchQuery.isEmpty) return true;
      return a.allergen.toLowerCase().contains(_searchQuery) || a.reaction.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return [const Text('No allergies recorded.', style: TextStyle(color: AppTheme.muted, fontSize: 13))];
    }

    return filtered.map((a) => _buildCard(
      icon: Icons.warning_amber_outlined,
      title: a.allergen,
      subtitle: 'Reaction: ${a.reaction} · Severity: ${a.severity}',
      trailing: a.dateRecorded.isNotEmpty ? a.dateRecorded : null,
      isWarning: true,
    )).toList();
  }

  List<Widget> _buildMedicationsList(List<Medication> medications) {
    final filtered = medications.where((m) {
      if (_searchQuery.isEmpty) return true;
      return m.name.toLowerCase().contains(_searchQuery) || m.dosage.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return [const Text('No active medications recorded.', style: TextStyle(color: AppTheme.muted, fontSize: 13))];
    }

    return filtered.map((m) => _buildCard(
      icon: Icons.medication_outlined,
      title: m.name,
      subtitle: '${m.dosage} · ${m.frequency} · ${m.status}',
      trailing: m.instructions.isNotEmpty ? m.instructions : null,
    )).toList();
  }

  List<Widget> _buildHistoryList(List<MedicalHistory> history) {
    final filtered = history.where((h) {
      if (_searchQuery.isEmpty) return true;
      return h.condition.toLowerCase().contains(_searchQuery) || h.notes.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return [const Text('No clinical history recorded.', style: TextStyle(color: AppTheme.muted, fontSize: 13))];
    }

    return filtered.map((h) => _buildCard(
      icon: Icons.history_outlined,
      title: h.condition,
      subtitle: h.notes.isNotEmpty ? h.notes : 'No clinical notes',
      trailing: h.date,
    )).toList();
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailing,
    bool isWarning = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isWarning ? AppTheme.warning.withAlpha(20) : AppTheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: isWarning ? AppTheme.warning : AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.ink)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                if (trailing != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    trailing,
                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.mutedLight),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
