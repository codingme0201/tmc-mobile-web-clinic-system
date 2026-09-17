import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carelink_mobile/app/theme.dart';
import '../controllers/consultation_controller.dart';
import '../../domain/models/consultation.dart';

class ConsultationDetailScreen extends StatefulWidget {
  final String consultationId;
  const ConsultationDetailScreen({super.key, required this.consultationId});

  @override
  State<ConsultationDetailScreen> createState() => _ConsultationDetailScreenState();
}

class _ConsultationDetailScreenState extends State<ConsultationDetailScreen> {
  Consultation? _consultation;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final consultation = await context.read<ConsultationController>().getConsultationDetails(widget.consultationId);
      setState(() {
        _consultation = consultation;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Consultation Details')),
        body: Center(child: Text(_error!)),
      );
    }

    if (_consultation == null) {
      return const Scaffold(
        body: Center(child: Text('Consultation not found.')),
      );
    }

    final c = _consultation!;

    return Scaffold(
      appBar: AppBar(title: const Text('Consultation Details')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildHeader(c),
          const SizedBox(height: 24),
          _buildSection('Chief Complaint', c.chiefComplaint),
          _buildSection('Diagnosis', c.diagnosis),
          _buildSection('Treatment', c.treatment),
          _buildSection('Disposition', c.disposition),
          _buildSection('Clinical Findings', c.clinicalFindings),
          const SizedBox(height: 24),
          _buildVitalsGrid(c.vitals),
        ],
      ),
    );
  }

  Widget _buildHeader(Consultation c) {
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
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.gold, width: 2),
                  color: Colors.white.withAlpha(35),
                ),
                child: const Icon(Icons.medical_services_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.reference,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Dr. ${c.staff}',
                      style: const TextStyle(fontSize: 14, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_note_rounded, size: 14, color: Colors.white70),
                const SizedBox(width: 6),
                Text(
                  '${c.date} at ${c.time}',
                  style: const TextStyle(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(borderRadius: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 12,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value.isEmpty ? 'Not recorded' : value,
            style: const TextStyle(fontSize: 14, color: AppTheme.ink, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsGrid(Map<String, dynamic> vitals) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: AppTheme.cardDecoration(borderRadius: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              const Text(
                'PATIENT VITALS',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: vitals.entries.map((e) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceSubtle,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.line),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(e.key, style: const TextStyle(fontSize: 11, color: AppTheme.muted, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 2),
                    Text(e.value.toString(), style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppTheme.ink)),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
