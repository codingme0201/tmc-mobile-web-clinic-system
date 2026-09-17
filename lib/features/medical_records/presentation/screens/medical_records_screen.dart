import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carelink_mobile/app/theme.dart';
import '../controllers/medical_record_controller.dart';
import '../../domain/models/medical_record.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicalRecordController>().loadMedicalRecord();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Medical Records')),
      body: Consumer<MedicalRecordController>(
        builder: (context, controller, _) {
          switch (controller.status) {
            case MedicalRecordStatus.initial:
            case MedicalRecordStatus.loading:
              return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
            case MedicalRecordStatus.error:
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
            case MedicalRecordStatus.loaded:
              if (controller.medicalRecord == null) {
                return const Center(
                  child: Text('No medical record found.', style: TextStyle(color: AppTheme.muted)),
                );
              }
              return _buildMedicalRecordView(controller.medicalRecord!);
          }
        },
      ),
    );
  }

  Widget _buildMedicalRecordView(MedicalRecord record) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildProfileHeader(record),
        const SizedBox(height: 24),
        _buildSectionTitle('Clinical History'),
        _buildHistoryList(record.medicalHistory),
        const SizedBox(height: 24),
        _buildSectionTitle('Current Conditions'),
        _buildConditionsList(record.conditions),
        const SizedBox(height: 24),
        _buildSectionTitle('Allergies'),
        _buildAllergiesList(record.allergies),
        const SizedBox(height: 24),
        _buildSectionTitle('Current Medications'),
        _buildMedicationsList(record.medications),
      ],
    );
  }

  Widget _buildProfileHeader(MedicalRecord record) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(record.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          Row(
            children: [
              Text('${record.age} yrs · ${record.sex}', style: const TextStyle(fontSize: 14, color: Colors.white70)),
              const SizedBox(width: 12),
              Text(record.type, style: const TextStyle(fontSize: 14, color: Colors.white70)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Dept: ${record.courseDept}', style: const TextStyle(fontSize: 13, color: Colors.white70)),
          const Divider(color: Colors.white24, height: 24),
          Text('Last Updated: ${record.lastUpdated}', style: const TextStyle(fontSize: 12, color: Colors.white60)),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.ink),
      ),
    );
  }

  Widget _buildHistoryList(List<MedicalHistory> history) {
    if (history.isEmpty) return _buildEmptyState();
    return Column(
      children: history.map((h) => _buildItemCard(
        title: h.condition,
        subtitle: h.notes.isEmpty ? 'No additional notes' : h.notes,
        trailing: h.date,
      )).toList(),
    );
  }

  Widget _buildConditionsList(List<Condition> conditions) {
    if (conditions.isEmpty) return _buildEmptyState();
    return Column(
      children: conditions.map((c) => _buildItemCard(
        title: c.name,
        subtitle: 'Status: ${c.status} · Diagnosed: ${c.diagnosedDate}',
        trailing: c.notes.isEmpty ? null : c.notes,
      )).toList(),
    );
  }

  Widget _buildAllergiesList(List<Allergy> allergies) {
    if (allergies.isEmpty) return _buildEmptyState();
    return Column(
      children: allergies.map((a) => _buildItemCard(
        title: a.allergen,
        subtitle: 'Reaction: ${a.reaction} · Severity: ${a.severity}',
        trailing: a.dateRecorded,
      )).toList(),
    );
  }

  Widget _buildMedicationsList(List<Medication> medications) {
    if (medications.isEmpty) return _buildEmptyState();
    return Column(
      children: medications.map((m) => _buildItemCard(
        title: m.name,
        subtitle: '${m.dosage} · ${m.frequency} · ${m.route}',
        trailing: m.status,
      )).toList(),
    );
  }

  Widget _buildItemCard({required String title, required String subtitle, String? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 13, color: AppTheme.muted)),
              ],
            ),
          ),
          if (trailing != null)
            Text(
              trailing,
              style: const TextStyle(fontSize: 12, color: AppTheme.muted),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Text('No records available.', style: TextStyle(color: AppTheme.muted, fontSize: 13)),
    );
  }
}
