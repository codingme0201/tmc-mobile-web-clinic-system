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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(c.reference, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 8),
          Text('Doctor: ${c.staff}', style: const TextStyle(fontSize: 15, color: Colors.white)),
          Text('Date: ${c.date} at ${c.time}', style: const TextStyle(fontSize: 13, color: Colors.white70)),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.muted)),
          const SizedBox(height: 8),
          Text(value.isEmpty ? 'Not recorded' : value, style: const TextStyle(fontSize: 15, color: AppTheme.ink)),
        ],
      ),
    );
  }

  Widget _buildVitalsGrid(Map<String, dynamic> vitals) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Vitals', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 20,
            runSpacing: 20,
            children: vitals.entries.map((e) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.key, style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                  Text(e.value.toString(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
