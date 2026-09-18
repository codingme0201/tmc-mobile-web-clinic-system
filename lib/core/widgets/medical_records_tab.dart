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
              _buildSearchBar(context),
              const SizedBox(height: 12),
              _buildFilterChips(context),
              const SizedBox(height: 20),
              if (_selectedCategory == 'All' || _selectedCategory == 'Conditions') ...[
                _buildSectionHeader(context, 'Current Conditions', record.conditions.length),
                ..._buildConditionsList(context, record.conditions),
                const SizedBox(height: 20),
              ],
              if (_selectedCategory == 'All' || _selectedCategory == 'Allergies') ...[
                _buildSectionHeader(context, 'Allergies', record.allergies.length),
                ..._buildAllergiesList(context, record.allergies),
                const SizedBox(height: 20),
              ],
              if (_selectedCategory == 'All' || _selectedCategory == 'Medications') ...[
                _buildSectionHeader(context, 'Current Medications', record.medications.length),
                ..._buildMedicationsList(context, record.medications),
                const SizedBox(height: 20),
              ],
              if (_selectedCategory == 'All' || _selectedCategory == 'History') ...[
                _buildSectionHeader(context, 'Clinical History', record.medicalHistory.length),
                ..._buildHistoryList(context, record.medicalHistory),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: AppTheme.primaryGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.gold, width: 2),
                  color: Colors.white.withAlpha(35),
                ),
                child: Center(
                  child: Text(
                    record.name.isNotEmpty ? record.name[0].toUpperCase() : 'P',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.name,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppTheme.gold.withAlpha(45),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.gold.withAlpha(90)),
                      ),
                      child: Text(
                        record.status.toUpperCase(),
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppTheme.goldLight),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${record.type} · ${record.courseDept}',
                  style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  'ID: ${record.patientId} · ${record.age} yrs · ${record.sex}',
                  style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(190)),
                ),
              ],
            ),
          ),
          if (record.lastUpdated.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'Last Updated: ${record.lastUpdated}',
              style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(160)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final ink = AppTheme.getInk(context);
    final muted = AppTheme.getMuted(context);
    final mutedLight = AppTheme.getMutedLight(context);

    return Container(
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 14),
      child: TextField(
        controller: _searchController,
        style: TextStyle(color: ink, fontSize: 13.5),
        onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
        decoration: InputDecoration(
          hintText: 'Search within medical records...',
          hintStyle: TextStyle(fontSize: 13.5, color: mutedLight),
          prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 20),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear_rounded, size: 18, color: muted),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildFilterChips(BuildContext context) {
    final categories = ['All', 'Conditions', 'Allergies', 'Medications', 'History'];
    final isDark = AppTheme.isDark(context);
    final muted = AppTheme.getMuted(context);
    final line = AppTheme.getLine(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _selectedCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected ? null : (isDark ? AppTheme.darkSurfaceSubtle : Colors.white),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected ? AppTheme.cardShadowSubtle : null,
                  border: Border.all(
                    color: isSelected ? Colors.transparent : line,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : muted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title, int count) {
    final ink = AppTheme.getInk(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 3.5,
                height: 14,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: ink,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(16),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primary.withAlpha(35)),
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

  List<Widget> _buildConditionsList(BuildContext context, List<Condition> conditions) {
    final muted = AppTheme.getMuted(context);
    final filtered = conditions.where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.name.toLowerCase().contains(_searchQuery) || c.notes.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return [Text('No conditions recorded.', style: TextStyle(color: muted, fontSize: 13))];
    }

    return filtered.map((c) => _buildCard(
      context: context,
      icon: Icons.healing_outlined,
      title: c.name,
      subtitle: 'Status: ${c.status} · Diagnosed: ${c.diagnosedDate}',
      trailing: c.notes.isNotEmpty ? c.notes : null,
    )).toList();
  }

  List<Widget> _buildAllergiesList(BuildContext context, List<Allergy> allergies) {
    final muted = AppTheme.getMuted(context);
    final filtered = allergies.where((a) {
      if (_searchQuery.isEmpty) return true;
      return a.allergen.toLowerCase().contains(_searchQuery) || a.reaction.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return [Text('No allergies recorded.', style: TextStyle(color: muted, fontSize: 13))];
    }

    return filtered.map((a) => _buildCard(
      context: context,
      icon: Icons.warning_amber_outlined,
      title: a.allergen,
      subtitle: 'Reaction: ${a.reaction} · Severity: ${a.severity}',
      trailing: a.dateRecorded.isNotEmpty ? a.dateRecorded : null,
      isWarning: true,
    )).toList();
  }

  List<Widget> _buildMedicationsList(BuildContext context, List<Medication> medications) {
    final muted = AppTheme.getMuted(context);
    final filtered = medications.where((m) {
      if (_searchQuery.isEmpty) return true;
      return m.name.toLowerCase().contains(_searchQuery) || m.dosage.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return [Text('No active medications recorded.', style: TextStyle(color: muted, fontSize: 13))];
    }

    return filtered.map((m) => _buildCard(
      context: context,
      icon: Icons.medication_outlined,
      title: m.name,
      subtitle: '${m.dosage} · ${m.frequency} · ${m.status}',
      trailing: m.instructions.isNotEmpty ? m.instructions : null,
    )).toList();
  }

  List<Widget> _buildHistoryList(BuildContext context, List<MedicalHistory> history) {
    final muted = AppTheme.getMuted(context);
    final filtered = history.where((h) {
      if (_searchQuery.isEmpty) return true;
      return h.condition.toLowerCase().contains(_searchQuery) || h.notes.toLowerCase().contains(_searchQuery);
    }).toList();

    if (filtered.isEmpty) {
      return [Text('No clinical history recorded.', style: TextStyle(color: muted, fontSize: 13))];
    }

    return filtered.map((h) => _buildCard(
      context: context,
      icon: Icons.history_outlined,
      title: h.condition,
      subtitle: h.notes.isNotEmpty ? h.notes : 'No clinical notes',
      trailing: h.date,
    )).toList();
  }

  Widget _buildCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    String? trailing,
    bool isWarning = false,
  }) {
    final ink = AppTheme.getInk(context);
    final muted = AppTheme.getMuted(context);
    final mutedLight = AppTheme.getMutedLight(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isWarning ? AppTheme.warning.withAlpha(20) : AppTheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: isWarning ? AppTheme.warning : AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: ink)),
                const SizedBox(height: 3),
                Text(subtitle, style: TextStyle(fontSize: 12.5, color: muted)),
                if (trailing != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    trailing,
                    style: TextStyle(fontSize: 11.5, fontStyle: FontStyle.italic, color: mutedLight),
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
