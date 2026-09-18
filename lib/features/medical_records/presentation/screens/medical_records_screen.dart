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
              return _buildMedicalRecordView(context, controller.medicalRecord!);
          }
        },
      ),
    );
  }

  Widget _buildMedicalRecordView(BuildContext context, MedicalRecord record) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildProfileHeader(context, record),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Clinical History'),
        _buildHistoryList(context, record.medicalHistory),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Current Conditions'),
        _buildConditionsList(context, record.conditions),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Allergies'),
        _buildAllergiesList(context, record.allergies),
        const SizedBox(height: 24),
        _buildSectionTitle(context, 'Current Medications'),
        _buildMedicationsList(context, record.medications),
      ],
    );
  }

  Widget _buildProfileHeader(BuildContext context, MedicalRecord record) {
    final isDark = AppTheme.isDark(context);
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: isDark ? AppTheme.heroGradientDark : AppTheme.heroGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.primaryLight.withAlpha(50) : Colors.white.withAlpha(40),
          width: 1,
        ),
        boxShadow: isDark ? AppTheme.cardShadowDark : AppTheme.primaryGlow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.gold, width: 2),
                  color: isDark ? AppTheme.darkSurface : Colors.white.withAlpha(40),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.gold.withAlpha(40),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    record.name.isNotEmpty ? record.name[0].toUpperCase() : 'P',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
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
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
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
                        record.type.toUpperCase(),
                        style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: AppTheme.goldLight),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${record.age} yrs · ${record.sex}',
                  style: const TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.w600),
                ),
                Text(
                  record.courseDept,
                  style: TextStyle(fontSize: 12, color: Colors.white.withAlpha(200)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Last Updated: ${record.lastUpdated}',
            style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(160)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
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
              color: AppTheme.getInk(context),
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<MedicalHistory> history) {
    if (history.isEmpty) return _buildEmptyState(context);
    return Column(
      children: history.map((h) => _buildItemCard(
        context,
        title: h.condition,
        subtitle: h.notes.isEmpty ? 'No additional notes' : h.notes,
        trailing: h.date,
      )).toList(),
    );
  }

  Widget _buildConditionsList(BuildContext context, List<Condition> conditions) {
    if (conditions.isEmpty) return _buildEmptyState(context);
    return Column(
      children: conditions.map((c) => _buildItemCard(
        context,
        title: c.name,
        subtitle: 'Status: ${c.status} · Diagnosed: ${c.diagnosedDate}',
        trailing: c.notes.isEmpty ? null : c.notes,
      )).toList(),
    );
  }

  Widget _buildAllergiesList(BuildContext context, List<Allergy> allergies) {
    if (allergies.isEmpty) return _buildEmptyState(context);
    return Column(
      children: allergies.map((a) => _buildItemCard(
        context,
        title: a.allergen,
        subtitle: 'Reaction: ${a.reaction} · Severity: ${a.severity}',
        trailing: a.dateRecorded,
      )).toList(),
    );
  }

  Widget _buildMedicationsList(BuildContext context, List<Medication> medications) {
    if (medications.isEmpty) return _buildEmptyState(context);
    return Column(
      children: medications.map((m) => _buildItemCard(
        context,
        title: m.name,
        subtitle: '${m.dosage} · ${m.frequency} · ${m.route}',
        trailing: m.status,
      )).toList(),
    );
  }

  Widget _buildItemCard(BuildContext context, {required String title, required String subtitle, String? trailing}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: AppTheme.getInk(context)),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.5, color: AppTheme.getMuted(context), height: 1.3),
                ),
              ],
            ),
          ),
          if (trailing != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                trailing,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text('No records available.', style: TextStyle(color: AppTheme.getMuted(context), fontSize: 13)),
    );
  }
}
