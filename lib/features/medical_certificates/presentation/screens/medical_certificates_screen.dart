import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:carelink_mobile/app/theme.dart';
import 'package:carelink_mobile/app/router.dart';
import '../controllers/medical_certificate_controller.dart';
import '../../domain/models/medical_certificate.dart';
import '../../../consultations/domain/models/consultation.dart';
import '../../../consultations/presentation/controllers/consultation_controller.dart';

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
      context.read<ConsultationController>().loadConsultations();
    });
  }

  void _openRequestModal(BuildContext context) {
    final consultCtrl = context.read<ConsultationController>();
    final completedConsultations = consultCtrl.consultations
        .where((c) => c.status == ConsultationStatus.completed)
        .toList();

    if (completedConsultations.isEmpty) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppTheme.getSurface(ctx),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              const Icon(Icons.info_outline, color: AppTheme.warning),
              const SizedBox(width: 8),
              Text(
                'Consultation Required',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.getInk(ctx)),
              ),
            ],
          ),
          content: Text(
            'You must complete a clinic consultation first before you can request a medical certificate.\n\nPlease visit the clinic or schedule an appointment for clinical assessment.',
            style: TextStyle(fontSize: 14, color: AppTheme.getInk(ctx), height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pushNamed(context, AppRouter.appointments);
              },
              child: const Text('Book Appointment'),
            ),
          ],
        ),
      );
      return;
    }

    final purposeController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String selectedConsultationId = completedConsultations.first.id;

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
              decoration: BoxDecoration(
                color: AppTheme.getSurface(context),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border(top: BorderSide(color: AppTheme.getLine(context))),
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
                        Text(
                          'Request Medical Certificate',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.getInk(context),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, color: AppTheme.getMuted(context)),
                          onPressed: () => Navigator.pop(sheetContext),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Accomplished Consultation *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.getInk(context)),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      initialValue: selectedConsultationId,
                      dropdownColor: AppTheme.getSurface(context),
                      style: TextStyle(fontSize: 14, color: AppTheme.getInk(context)),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppTheme.getSurfaceSubtle(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppTheme.getLine(context)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppTheme.getLine(context)),
                        ),
                      ),
                      items: completedConsultations.map((c) {
                        final dateStr =
                            '${c.date.year}-${c.date.month.toString().padLeft(2, '0')}-${c.date.day.toString().padLeft(2, '0')}';
                        final diag = c.diagnosis.isNotEmpty ? c.diagnosis : c.chiefComplaint;
                        final displayLabel = '$dateStr — ${diag.length > 25 ? '${diag.substring(0, 23)}...' : diag}';
                        return DropdownMenuItem<String>(
                          value: c.id,
                          child: Text(
                            displayLabel,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedConsultationId = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Purpose *',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.getInk(context)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: purposeController,
                      style: TextStyle(fontSize: 14, color: AppTheme.getInk(context)),
                      decoration: InputDecoration(
                        hintText: 'e.g., Excused Absence, OJT Requirement, PE Clearance',
                        hintStyle: TextStyle(fontSize: 13, color: AppTheme.getMutedLight(context)),
                        filled: true,
                        fillColor: AppTheme.getSurfaceSubtle(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppTheme.getLine(context)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppTheme.getLine(context)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
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
                    Text(
                      'Medical Details / Notes',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.getInk(context)),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: notesController,
                      maxLines: 3,
                      style: TextStyle(fontSize: 14, color: AppTheme.getInk(context)),
                      decoration: InputDecoration(
                        hintText: 'State your medical condition or symptoms...',
                        hintStyle: TextStyle(fontSize: 13, color: AppTheme.getMutedLight(context)),
                        filled: true,
                        fillColor: AppTheme.getSurfaceSubtle(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppTheme.getLine(context)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AppTheme.getLine(context)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
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
                            consultationId: selectedConsultationId,
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
          decoration: BoxDecoration(
            color: AppTheme.getSurface(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(top: BorderSide(color: AppTheme.getLine(context))),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.getInk(context)),
                  ),
                  _buildStatusChip(cert.status),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow(context, 'Patient', cert.patient),
              _buildDetailRow(context, 'Purpose', cert.purpose),
              if (cert.diagnosis.isNotEmpty) _buildDetailRow(context, 'Diagnosis', cert.diagnosis),
              if (cert.recommendation.isNotEmpty) _buildDetailRow(context, 'Recommendation', cert.recommendation),
              _buildDetailRow(context, 'Issue Date', cert.issueDate),
              if (cert.validUntil != null) _buildDetailRow(context, 'Valid Until', cert.validUntil!),
              if (cert.issuedBy.isNotEmpty) _buildDetailRow(context, 'Attending Doctor', cert.issuedBy),
              if (cert.status == 'Rejected' && cert.rejectionReason.isNotEmpty)
                _buildDetailRow(context, 'Rejection Reason', cert.rejectionReason, isDanger: true),
              const SizedBox(height: 20),
              if (cert.status.toLowerCase() == 'issued' || cert.status.toLowerCase() == 'approved') ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.description_rounded, size: 18),
                    label: const Text('View Official Certificate', style: TextStyle(fontWeight: FontWeight.w700)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _showOfficialDocumentDialog(context, cert);
                    },
                  ),
                ),
                const SizedBox(height: 10),
              ],
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
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

  void _showOfficialDocumentDialog(BuildContext context, MedicalCertificate cert) {
    final ink = AppTheme.getInk(context);
    final muted = AppTheme.getMuted(context);
    final line = AppTheme.getLine(context);

    final certSummaryText = '''
REPUBLIC OF THE PHILIPPINES
TAGUIG CITY UNIVERSITY
UNIVERSITY HEALTH SERVICES CENTER
TMC CareLink Medical Clinic

MEDICAL CERTIFICATE
Reference: ${cert.reference}
Date Issued: ${cert.issueDate}

TO WHOM IT MAY CONCERN:
This is to certify that ${cert.patient} has been examined and attended to at the TMC University Health Services Clinic.

DIAGNOSIS:
${cert.diagnosis.isNotEmpty ? cert.diagnosis : 'Clinical Consultation & Assessment'}

RECOMMENDATIONS / REMARKS:
${cert.recommendation.isNotEmpty ? cert.recommendation : 'Excused from physical strenuous activity and given supportive rest.'}
${cert.validUntil != null ? 'Valid Until: ${cert.validUntil}\n' : ''}
PURPOSE:
${cert.purpose}

ATTENDING PHYSICIAN:
${cert.issuedBy.isNotEmpty ? cert.issuedBy : 'Attending University Physician, M.D.'}
License No. PRC-0084729
TMC Student Health Clinic
''';

    showDialog(
      context: context,
      builder: (dialogCtx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppTheme.getSurface(context),
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500, maxHeight: 680),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: const BoxDecoration(
                  gradient: AppTheme.heroGradient,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.verified_user_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Official Medical Certificate',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 20),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(dialogCtx),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.isDark(context) ? const Color(0xFF161E1C) : const Color(0xFFFCFDFD),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: line),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(AppTheme.isDark(context) ? 40 : 15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppTheme.primary.withAlpha(20),
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.primary, width: 1.5),
                          ),
                          child: const Icon(Icons.local_hospital_rounded, color: AppTheme.primary, size: 22),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'TAGUIG CITY UNIVERSITY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: AppTheme.primary,
                          ),
                        ),
                        Text(
                          'UNIVERSITY HEALTH SERVICES CENTER',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                            color: muted,
                          ),
                        ),
                        Text(
                          'Gen. Santos Ave, Central Bicutan, Taguig City',
                          style: TextStyle(fontSize: 9.5, color: muted.withAlpha(180)),
                        ),
                        const SizedBox(height: 12),
                        Divider(thickness: 1.5, color: AppTheme.primary.withAlpha(80)),
                        const SizedBox(height: 10),
                        Text(
                          'MEDICAL CERTIFICATE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.5,
                            color: ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Ref: ${cert.reference}',
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary),
                            ),
                            Text(
                              'Date: ${cert.issueDate}',
                              style: TextStyle(fontSize: 11, color: muted, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'TO WHOM IT MAY CONCERN:',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: ink,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        RichText(
                          textAlign: TextAlign.justify,
                          text: TextSpan(
                            style: TextStyle(fontSize: 13, color: ink, height: 1.5),
                            children: [
                              const TextSpan(text: 'This is to certify that '),
                              TextSpan(
                                text: cert.patient,
                                style: const TextStyle(fontWeight: FontWeight.w800, decoration: TextDecoration.underline),
                              ),
                              const TextSpan(
                                text: ' has been formally examined and evaluated at the TCU University Health Services Clinic.',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.getSurfaceSubtle(context),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: line),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DIAGNOSIS:',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                cert.diagnosis.isNotEmpty ? cert.diagnosis : 'Clinical Evaluation & Assessment',
                                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: ink),
                              ),
                              const SizedBox(height: 10),
                              const Text(
                                'RECOMMENDATIONS / REMARKS:',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                  color: AppTheme.primary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                cert.recommendation.isNotEmpty
                                    ? cert.recommendation
                                    : 'Patient advised rest and excused from strenuous activities.',
                                style: TextStyle(fontSize: 12.5, color: ink),
                              ),
                              if (cert.validUntil != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Text(
                                      'Valid Until: ',
                                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: muted),
                                    ),
                                    Text(
                                      cert.validUntil!,
                                      style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppTheme.primary),
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Text(
                                    'Purpose: ',
                                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: muted),
                                  ),
                                  Text(
                                    cert.purpose,
                                    style: TextStyle(fontSize: 11.5, color: ink),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                width: 140,
                                height: 1,
                                color: ink,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                cert.issuedBy.isNotEmpty ? cert.issuedBy : 'Attending Physician, M.D.',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: ink),
                              ),
                              Text(
                                'License No. PRC-0084729',
                                style: TextStyle(fontSize: 10, color: muted),
                              ),
                              Text(
                                'University Physician',
                                style: TextStyle(fontSize: 10, color: muted),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: AppTheme.success.withAlpha(20),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppTheme.success.withAlpha(70)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.verified_rounded, size: 14, color: AppTheme.success),
                              SizedBox(width: 6),
                              Text(
                                'OFFICIALLY VERIFIED & DIGITALLY ISSUED',
                                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: AppTheme.success, letterSpacing: 0.5),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.getSurfaceSubtle(context),
                  border: Border(top: BorderSide(color: line)),
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.copy_rounded, size: 16),
                        label: const Text('Copy Text'),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: certSummaryText));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Medical certificate details copied to clipboard.'),
                              backgroundColor: AppTheme.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text('Done'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value, {bool isDanger = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: TextStyle(fontSize: 13, color: AppTheme.getMuted(context))),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDanger ? AppTheme.danger : AppTheme.getInk(context),
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
                              decoration: AppTheme.cardDecoration(context: context),
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
                                            style: TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.getInk(context),
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
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppTheme.getInk(context),
                                    ),
                                  ),
                                  if (cert.diagnosis.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      cert.diagnosis,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 12.5, color: AppTheme.getMuted(context), height: 1.3),
                                    ),
                                  ],
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded, size: 12.5, color: AppTheme.getMutedLight(context)),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Issued: ${cert.issueDate}',
                                        style: TextStyle(fontSize: 12, color: AppTheme.getMuted(context), fontWeight: FontWeight.w500),
                                      ),
                                      if (cert.issuedBy.isNotEmpty) ...[
                                        const SizedBox(width: 14),
                                        Icon(Icons.person_outline_rounded, size: 12.5, color: AppTheme.getMutedLight(context)),
                                        const SizedBox(width: 5),
                                        Expanded(
                                          child: Text(
                                            cert.issuedBy,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(fontSize: 12, color: AppTheme.getMuted(context), fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (cert.status.toLowerCase() == 'issued' || cert.status.toLowerCase() == 'approved') ...[
                                    const SizedBox(height: 12),
                                    InkWell(
                                      onTap: () => _showOfficialDocumentDialog(context, cert),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withAlpha(15),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: AppTheme.primary.withAlpha(40)),
                                        ),
                                        child: const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.description_rounded, size: 14, color: AppTheme.primary),
                                            SizedBox(width: 6),
                                            Text(
                                              'View Official Certificate',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                                color: AppTheme.primary,
                                              ),
                                            ),
                                            SizedBox(width: 4),
                                            Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppTheme.primary),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
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
                  color: isSelected ? null : AppTheme.getSurfaceSubtle(context),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected ? AppTheme.cardShadowSubtle : null,
                  border: Border.all(
                    color: isSelected ? Colors.transparent : AppTheme.getLine(context),
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    color: isSelected ? Colors.white : AppTheme.getMuted(context),
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
