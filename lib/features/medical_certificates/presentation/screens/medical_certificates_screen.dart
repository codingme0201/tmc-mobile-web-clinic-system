import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:carelink_mobile/app/theme.dart';
import '../controllers/medical_certificate_controller.dart';
import '../../domain/models/medical_certificate.dart';

class MedicalCertificatesScreen extends StatefulWidget {
  const MedicalCertificatesScreen({super.key});

  @override
  State<MedicalCertificatesScreen> createState() => _MedicalCertificatesScreenState();
}

class _MedicalCertificatesScreenState extends State<MedicalCertificatesScreen> {
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicalCertificateController>().loadCertificates();
    });
  }

  void _openRequestModal(BuildContext context) {
    final purposeController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Request Medical Certificate',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.ink,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Purpose *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.ink),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: purposeController,
                      decoration: InputDecoration(
                        hintText: 'e.g., Excused Absence, OJT Requirement, PE Clearance',
                        filled: true,
                        fillColor: AppTheme.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.line),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter the certificate purpose.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Medical Details / Notes',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.ink),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText: 'State your medical condition or symptoms...',
                        filled: true,
                        fillColor: AppTheme.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.line),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: AppTheme.line),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final controller = context.read<MedicalCertificateController>();
                          final success = await controller.requestCertificate(
                            purpose: purposeController.text.trim(),
                            diagnosis: notesController.text.trim(),
                          );

                          if (sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  success
                                      ? 'Medical certificate requested successfully.'
                                      : (controller.error ?? 'Failed to submit request.'),
                                ),
                                backgroundColor: success ? AppTheme.success : AppTheme.danger,
                              ),
                            );
                          }
                        },
                        child: const Text('Submit Request', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCertificateDetails(BuildContext context, MedicalCertificate cert) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
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
                    cert.reference,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.ink),
                  ),
                  _buildStatusChip(cert.status),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('Patient', cert.patient),
              _buildDetailRow('Purpose', cert.purpose),
              if (cert.diagnosis.isNotEmpty) _buildDetailRow('Diagnosis', cert.diagnosis),
              if (cert.recommendation.isNotEmpty) _buildDetailRow('Recommendation', cert.recommendation),
              _buildDetailRow('Issue Date', cert.issueDate),
              if (cert.validUntil != null) _buildDetailRow('Valid Until', cert.validUntil!),
              if (cert.issuedBy.isNotEmpty) _buildDetailRow('Attending Doctor', cert.issuedBy),
              if (cert.status == 'Rejected' && cert.rejectionReason.isNotEmpty)
                _buildDetailRow('Rejection Reason', cert.rejectionReason, isDanger: true),
              const SizedBox(height: 24),
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

  Widget _buildDetailRow(String label, String value, {bool isDanger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.muted)),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDanger ? AppTheme.danger : AppTheme.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;

    switch (status.toLowerCase()) {
      case 'issued':
      case 'approved':
        color = AppTheme.success;
        break;
      case 'rejected':
        color = AppTheme.danger;
        break;
      case 'pending':
      default:
        color = AppTheme.warning;
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
            status,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Certificates'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openRequestModal(context),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Request Certificate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      body: Consumer<MedicalCertificateController>(
        builder: (context, controller, _) {
          if (controller.status == MedicalCertificateStatus.loading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primary));
          }

          if (controller.status == MedicalCertificateStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: AppTheme.danger),
                  const SizedBox(height: 16),
                  Text(
                    controller.error ?? 'Unable to load certificates.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.muted, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => controller.loadCertificates(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          final allCerts = controller.certificates;
          final filtered = _selectedStatus == 'All'
              ? allCerts
              : allCerts.where((c) => c.status.toLowerCase() == _selectedStatus.toLowerCase()).toList();

          return Column(
            children: [
              _buildFilterBar(),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.article_outlined, size: 56, color: AppTheme.mutedLight.withAlpha(100)),
                            const SizedBox(height: 12),
                            const Text(
                              'No certificates found',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.ink),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Tap "Request Certificate" below to submit a request.',
                              style: TextStyle(fontSize: 13, color: AppTheme.muted),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(20),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final cert = filtered[index];
                          return InkWell(
                            onTap: () => _showCertificateDetails(context, cert),
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
                                            child: const Icon(Icons.assignment_outlined, size: 16, color: AppTheme.primary),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            cert.reference,
                                            style: const TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.ink,
                                            ),
                                          ),
                                        ],
                                      ),
                                      _buildStatusChip(cert.status),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    cert.purpose,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.ink,
                                    ),
                                  ),
                                  if (cert.diagnosis.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      cert.diagnosis,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 12.5, color: AppTheme.muted, height: 1.3),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_rounded, size: 12.5, color: AppTheme.mutedLight),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Issued: ${cert.issueDate}',
                                        style: const TextStyle(fontSize: 12, color: AppTheme.muted, fontWeight: FontWeight.w500),
                                      ),
                                      if (cert.issuedBy.isNotEmpty) ...[
                                        const SizedBox(width: 14),
                                        const Icon(Icons.person_outline_rounded, size: 12.5, color: AppTheme.mutedLight),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            cert.issuedBy,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(fontSize: 12, color: AppTheme.muted, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    final statuses = ['All', 'Pending', 'Approved', 'Issued', 'Rejected'];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: statuses.map((status) {
          final isSelected = _selectedStatus == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () {
                setState(() => _selectedStatus = status);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  gradient: isSelected ? AppTheme.primaryGradient : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected ? AppTheme.cardShadowSubtle : null,
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppTheme.line,
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.muted,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
