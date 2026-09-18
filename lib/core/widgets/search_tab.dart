import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../utils/api_client.dart';

class SearchTab extends StatefulWidget {
  const SearchTab({super.key});

  @override
  State<SearchTab> createState() => _SearchTabState();
}

class _SearchTabState extends State<SearchTab> {
  final TextEditingController _controller = TextEditingController();
  final ApiClient _apiClient = ApiClient();
  Timer? _debounceTimer;

  bool _isLoading = false;
  String _error = '';
  List<Map<String, dynamic>> _appointments = [];
  List<Map<String, dynamic>> _certificates = [];
  List<Map<String, dynamic>> _prescriptions = [];
  Map<String, dynamic>? _medicalRecord;
  bool _hasSearched = false;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _hasSearched = false;
        _isLoading = false;
        _appointments = [];
        _certificates = [];
        _prescriptions = [];
        _medicalRecord = null;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 350), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isLoading = true;
      _error = '';
      _hasSearched = true;
    });

    try {
      final response = await _apiClient.get('/me/search?q=${Uri.encodeComponent(query)}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final data = (decoded is Map && decoded.containsKey('data'))
            ? decoded['data'] as Map<String, dynamic>
            : (decoded is Map ? decoded as Map<String, dynamic> : {});

        setState(() {
          _appointments = (data['appointments'] as List? ?? []).whereType<Map<String, dynamic>>().toList();
          _certificates = (data['certificates'] as List? ?? []).whereType<Map<String, dynamic>>().toList();
          _prescriptions = (data['prescriptions'] as List? ?? []).whereType<Map<String, dynamic>>().toList();
          _medicalRecord = data['medicalRecord'] as Map<String, dynamic>?;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to fetch search results.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  int get _totalResults =>
      _appointments.length + _certificates.length + _prescriptions.length + (_medicalRecord != null ? 1 : 0);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            decoration: AppTheme.cardDecoration(
              context: context,
              borderRadius: 14,
              shadow: AppTheme.cardShadowSubtle,
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.search_rounded, color: AppTheme.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    onChanged: _onQueryChanged,
                    style: TextStyle(fontSize: 14, color: AppTheme.getInk(context)),
                    decoration: InputDecoration(
                      hintText: 'Search appointments, records, doctors...',
                      hintStyle: TextStyle(fontSize: 13.5, color: AppTheme.getMutedLight(context)),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                if (_controller.text.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.close_rounded, size: 18, color: AppTheme.getMuted(context)),
                    onPressed: () {
                      _controller.clear();
                      _onQueryChanged('');
                    },
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primary),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.danger),
            const SizedBox(height: 12),
            Text(_error, style: TextStyle(color: AppTheme.getMuted(context))),
          ],
        ),
      );
    }

    if (!_hasSearched) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 64, color: AppTheme.getMutedLight(context).withAlpha(80)),
            const SizedBox(height: 16),
            Text(
              'Search for anything',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.getInk(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Find appointments, medical records,\nprescriptions, and certificates',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppTheme.getMuted(context)),
            ),
          ],
        ),
      );
    }

    if (_totalResults == 0) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 56, color: AppTheme.getMutedLight(context).withAlpha(120)),
            const SizedBox(height: 12),
            Text(
              'No results found for "${_controller.text}"',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.getInk(context)),
            ),
            const SizedBox(height: 4),
            Text('Try searching with different keywords', style: TextStyle(fontSize: 13, color: AppTheme.getMuted(context))),
          ],
        ),
      );
    }

    return ListView(
      children: [
        if (_appointments.isNotEmpty) ...[
          _buildSectionHeader('Appointments', _appointments.length),
          ..._appointments.map((a) => _buildAppointmentCard(a)),
          const SizedBox(height: 16),
        ],
        if (_prescriptions.isNotEmpty) ...[
          _buildSectionHeader('Prescriptions', _prescriptions.length),
          ..._prescriptions.map((p) => _buildPrescriptionCard(p)),
          const SizedBox(height: 16),
        ],
        if (_certificates.isNotEmpty) ...[
          _buildSectionHeader('Medical Certificates', _certificates.length),
          ..._certificates.map((c) => _buildCertificateCard(c)),
          const SizedBox(height: 16),
        ],
        if (_medicalRecord != null) ...[
          _buildSectionHeader('Medical Record', 1),
          _buildMedicalRecordSummaryCard(_medicalRecord!),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 8),
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
                  color: AppTheme.getInk(context),
                  letterSpacing: 0.7,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count found',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> item) {
    final title = (item['type'] ?? item['reason'] ?? 'Appointment').toString();
    final date = (item['date'] ?? '').toString();
    final staff = (item['staff'] ?? item['doctor'] ?? 'Doctor').toString();
    final status = (item['status'] ?? '').toString();
    final ref = (item['reference'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.calendar_month_rounded, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.getInk(context))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(status, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text('$ref · $staff · $date', style: TextStyle(fontSize: 12, color: AppTheme.getMuted(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrescriptionCard(Map<String, dynamic> item) {
    final ref = (item['reference'] ?? '').toString();
    final doctor = (item['prescribedBy'] ?? item['prescribed_by'] ?? 'Doctor').toString();
    final date = (item['date'] ?? '').toString();
    final meds = (item['medications'] as List? ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.medication_liquid_rounded, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ref, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.getInk(context))),
                const SizedBox(height: 3),
                Text('$doctor · $date · ${meds.length} item(s)', style: TextStyle(fontSize: 12, color: AppTheme.getMuted(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(Map<String, dynamic> item) {
    final ref = (item['reference'] ?? '').toString();
    final purpose = (item['purpose'] ?? '').toString();
    final status = (item['status'] ?? '').toString();
    final date = (item['issueDate'] ?? item['issue_date'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.assignment_outlined, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(ref, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.getInk(context))),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(status, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppTheme.primary)),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text('$purpose · $date', style: TextStyle(fontSize: 12, color: AppTheme.getMuted(context))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalRecordSummaryCard(Map<String, dynamic> record) {
    final name = (record['name'] ?? '').toString();
    final conditions = (record['conditions'] as List? ?? []);
    final allergies = (record['allergies'] as List? ?? []);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration(context: context, borderRadius: 14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryLight.withAlpha(20),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.folder_shared_rounded, size: 18, color: AppTheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.getInk(context))),
                const SizedBox(height: 3),
                Text(
                  '${conditions.length} Condition(s) · ${allergies.length} Allergie(s)',
                  style: TextStyle(fontSize: 12, color: AppTheme.getMuted(context)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
