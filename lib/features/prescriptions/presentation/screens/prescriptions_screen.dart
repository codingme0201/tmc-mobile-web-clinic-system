import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carelink_mobile/app/theme.dart';
import '../controllers/prescription_controller.dart';
import '../../domain/models/prescription.dart';

class PrescriptionsScreen extends StatefulWidget {
  const PrescriptionsScreen({super.key});

  @override
  State<PrescriptionsScreen> createState() => _PrescriptionsScreenState();
}

class _PrescriptionsScreenState extends State<PrescriptionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrescriptionController>().loadPrescriptions();
    });
  }

  void _showPrescriptionDetails(BuildContext context, Prescription prescription) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.85,
          ),
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    prescription.reference,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.ink,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      prescription.date,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Prescribed by: ${prescription.prescribedBy.isNotEmpty ? prescription.prescribedBy : "Attending Doctor"}',
                style: const TextStyle(fontSize: 13, color: AppTheme.muted),
              ),
              const Divider(height: 24),
              const Text(
                'Medications',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: prescription.medications.length,
                  separatorBuilder: (_, _) => const Divider(height: 16),
                  itemBuilder: (context, index) {
                    final med = prescription.medications[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          med.medicineName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (med.dosage.isNotEmpty) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppTheme.background,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: AppTheme.line),
                                ),
                                child: Text(
                                  med.dosage,
                                  style: const TextStyle(fontSize: 12, color: AppTheme.ink),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (med.frequency.isNotEmpty) ...[
                              Text(
                                med.frequency,
                                style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                              ),
                            ],
                            if (med.duration.isNotEmpty) ...[
                              Text(
                                ' · ${med.duration}',
                                style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                              ),
                            ],
                          ],
                        ),
                        if (med.instructions.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            med.instructions,
                            style: const TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.muted,
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Prescriptions'),
      ),
      body: Consumer<PrescriptionController>(
        builder: (context, controller, _) {
          if (controller.status == PrescriptionListStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          if (controller.status == PrescriptionListStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: AppTheme.danger),
                  const SizedBox(height: 16),
                  Text(
                    controller.error ?? 'Unable to load prescriptions.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.muted, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => controller.loadPrescriptions(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          if (controller.prescriptions.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.description_outlined, size: 56, color: AppTheme.mutedLight.withAlpha(100)),
                  const SizedBox(height: 12),
                  const Text(
                    'No prescriptions found',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.ink),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Prescriptions from your consultations will appear here.',
                    style: TextStyle(fontSize: 13, color: AppTheme.muted),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(20),
            itemCount: controller.prescriptions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final rx = controller.prescriptions[index];
              return InkWell(
                onTap: () => _showPrescriptionDetails(context, rx),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: AppTheme.cardDecoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryLight.withAlpha(20),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.medication_liquid_rounded, size: 16, color: AppTheme.primary),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                rx.reference,
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.ink,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withAlpha(16),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.primary.withAlpha(35)),
                            ),
                            child: Text(
                              '${rx.medications.length} item${rx.medications.length == 1 ? '' : 's'}',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...rx.medications.take(2).map((m) => Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.line),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.medication_outlined, size: 15, color: AppTheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${m.medicineName} ${m.dosage}'.trim(),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.ink,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                      if (rx.medications.length > 2)
                        Padding(
                          padding: const EdgeInsets.only(top: 2, bottom: 4),
                          child: Text(
                            '+ ${rx.medications.length - 2} more medications',
                            style: const TextStyle(fontSize: 11.5, color: AppTheme.muted, fontStyle: FontStyle.italic),
                          ),
                        ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 12.5, color: AppTheme.mutedLight),
                          const SizedBox(width: 5),
                          Text(
                            rx.date,
                            style: const TextStyle(fontSize: 12, color: AppTheme.muted, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(width: 14),
                          const Icon(Icons.person_outline_rounded, size: 12.5, color: AppTheme.mutedLight),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              rx.prescribedBy.isNotEmpty ? rx.prescribedBy : 'Attending Doctor',
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 12, color: AppTheme.muted, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
