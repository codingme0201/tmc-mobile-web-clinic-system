import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carelink_mobile/app/theme.dart';
import '../controllers/consultation_controller.dart';
import '../../domain/models/consultation.dart';

class ConsultationsScreen extends StatefulWidget {
  const ConsultationsScreen({super.key});

  @override
  State<ConsultationsScreen> createState() => _ConsultationsScreenState();
}

class _ConsultationsScreenState extends State<ConsultationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ConsultationController>().loadConsultations();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Consultations')),
      body: Consumer<ConsultationController>(
        builder: (context, controller, _) {
          switch (controller.status) {
            case ConsultationListStatus.initial:
            case ConsultationListStatus.loading:
              return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
            case ConsultationListStatus.error:
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 56, color: AppTheme.danger),
                    const SizedBox(height: 16),
                    Text(
                      controller.error ?? 'Unable to load consultations.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: AppTheme.muted, fontSize: 15),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: () => controller.loadConsultations(),
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              );
            case ConsultationListStatus.loaded:
              if (controller.consultations.isEmpty) {
                return const Center(
                  child: Text('No consultations found.', style: TextStyle(color: AppTheme.muted)),
                );
              }
              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: controller.consultations.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final consultation = controller.consultations[index];
                  return _buildConsultationCard(context, consultation);
                },
              );
          }
        },
      ),
    );
  }

  Widget _buildConsultationCard(BuildContext context, Consultation consultation) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        '/consultation-detail',
        arguments: consultation.id,
      ),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.cardDecoration(),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.info.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.info.withAlpha(45)),
              ),
              child: const Icon(Icons.medical_services_rounded, color: AppTheme.info, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    consultation.reference,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: AppTheme.ink,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      const Icon(Icons.schedule_rounded, size: 12.5, color: AppTheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${consultation.date} · ${consultation.time}',
                        style: const TextStyle(fontSize: 12.5, color: AppTheme.muted, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            _buildStatusBadge(consultation.status),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(ConsultationStatus status) {
    Color color;
    String label;
    switch (status) {
      case ConsultationStatus.completed:
        color = AppTheme.success;
        label = 'Completed';
        break;
      case ConsultationStatus.scheduled:
        color = AppTheme.primary;
        label = 'Scheduled';
        break;
      case ConsultationStatus.inProgress:
        color = AppTheme.warning;
        label = 'In Progress';
        break;
      case ConsultationStatus.cancelled:
        color = AppTheme.danger;
        label = 'Cancelled';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }
}
