import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../app/theme.dart';
import '../../../../core/models/appointment.dart';
import '../../../../core/widgets/empty_state.dart';
import '../controllers/appointment_controller.dart';
import 'appointment_detail_screen.dart';
import 'request_appointment_screen.dart';
import 'appointment_history_screen.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  String _selectedStatus = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentController>().loadAppointments();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withAlpha(180),
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'History'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AppointmentHistoryScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<AppointmentController>(
        builder: (context, controller, _) {
          if (controller.status == AppointmentListStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          if (controller.status == AppointmentListStatus.error) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 56, color: AppTheme.danger),
                  const SizedBox(height: 16),
                  Text(
                    controller.error ?? 'Unable to load appointments.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppTheme.muted, fontSize: 15),
                  ),
                  const SizedBox(height: 16),
                  TextButton.icon(
                    onPressed: () => controller.loadAppointments(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              _buildSearchAndFilter(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildUpcomingTab(controller),
                    _buildHistoryTab(controller),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final controller = context.read<AppointmentController>();
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const RequestAppointmentScreen(),
            ),
          );
          if (result == true && mounted) {
            controller.refreshAppointments();
          }
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Request'),
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        children: [
          Container(
            decoration: AppTheme.cardDecoration(
              context: context,
              borderRadius: 14,
              shadow: AppTheme.cardShadowSubtle,
            ),
            child: TextField(
              controller: _searchController,
              style: TextStyle(fontSize: 14, color: AppTheme.getInk(context)),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search appointments, doctors...',
                hintStyle: TextStyle(fontSize: 13.5, color: AppTheme.getMutedLight(context)),
                prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear_rounded, size: 18, color: AppTheme.getMuted(context)),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusFilter(),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    final statuses = [
      {'value': 'all', 'label': 'All'},
      {'value': 'pending', 'label': 'Pending'},
      {'value': 'confirmed', 'label': 'Confirmed'},
      {'value': 'completed', 'label': 'Completed'},
      {'value': 'cancelled', 'label': 'Cancelled'},
      {'value': 'noShow', 'label': 'No-Show'},
    ];

    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: statuses.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = _selectedStatus == status['value'];
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedStatus = status['value']!;
              });
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
                status['label']!,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppTheme.getMuted(context),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUpcomingTab(AppointmentController controller) {
    var upcoming = controller.upcomingAppointments;

    if (_searchQuery.isNotEmpty) {
      upcoming = upcoming.where((a) {
        return a.title.toLowerCase().contains(_searchQuery) ||
            a.reason.toLowerCase().contains(_searchQuery) ||
            a.doctorName.toLowerCase().contains(_searchQuery) ||
            a.type.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    if (_selectedStatus != 'all') {
      upcoming = upcoming.where((a) => a.status.name == _selectedStatus).toList();
    }

    if (upcoming.isEmpty) {
      return EmptyState(
        message: _searchQuery.isNotEmpty || _selectedStatus != 'all'
            ? 'No matching appointments found.'
            : 'No upcoming appointments.',
        icon: Icons.calendar_today_outlined,
        actionLabel: _searchQuery.isEmpty && _selectedStatus == 'all'
            ? 'Request Appointment'
            : null,
        onAction: _searchQuery.isEmpty && _selectedStatus == 'all'
            ? () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RequestAppointmentScreen(),
                  ),
                );
                if (result == true && mounted) {
                  controller.refreshAppointments();
                }
              }
            : null,
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.refreshAppointments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: upcoming.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(context, upcoming[index]);
        },
      ),
    );
  }

  Widget _buildHistoryTab(AppointmentController controller) {
    var history = controller.appointmentHistory;

    if (_searchQuery.isNotEmpty) {
      history = history.where((a) {
        return a.title.toLowerCase().contains(_searchQuery) ||
            a.reason.toLowerCase().contains(_searchQuery) ||
            a.doctorName.toLowerCase().contains(_searchQuery) ||
            a.type.toLowerCase().contains(_searchQuery);
      }).toList();
    }

    if (_selectedStatus != 'all') {
      history = history.where((a) => a.status.name == _selectedStatus).toList();
    }

    if (history.isEmpty) {
      return EmptyState(
        message: _searchQuery.isNotEmpty || _selectedStatus != 'all'
            ? 'No matching appointments found.'
            : 'No appointment history yet.',
        icon: Icons.history,
      );
    }

    return RefreshIndicator(
      onRefresh: () => controller.refreshAppointments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          return _buildAppointmentCard(context, history[index]);
        },
      ),
    );
  }

  Widget _buildAppointmentCard(BuildContext context, Appointment appointment) {
    final isDark = AppTheme.isDark(context);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AppointmentDetailScreen(appointmentId: appointment.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: AppTheme.cardDecoration(context: context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark ? AppTheme.primary.withAlpha(45) : AppTheme.primaryLight.withAlpha(22),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primary.withAlpha(isDark ? 80 : 50)),
                  ),
                  child: const Icon(Icons.calendar_month_rounded, color: AppTheme.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointment.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.getInk(context),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.person_pin_circle_outlined, size: 13, color: AppTheme.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              appointment.doctorName,
                              style: TextStyle(fontSize: 12.5, color: AppTheme.getMuted(context), fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(appointment.status),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.getSurfaceSubtle(context),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTheme.getLine(context)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_rounded, size: 13, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    DateFormat('MMM d, yyyy').format(appointment.date),
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.getInk(context)),
                  ),
                  const SizedBox(width: 14),
                  const Icon(Icons.access_time_rounded, size: 13, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    appointment.time,
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: AppTheme.getInk(context)),
                  ),
                ],
              ),
            ),
            if (appointment.type.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.medical_services_outlined, size: 13, color: AppTheme.getMutedLight(context)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      appointment.type,
                      style: TextStyle(fontSize: 12, color: AppTheme.getMuted(context)),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AppointmentStatus status) {
    Color color;

    switch (status) {
      case AppointmentStatus.pending:
        color = AppTheme.warning;
        break;
      case AppointmentStatus.confirmed:
        color = AppTheme.info;
        break;
      case AppointmentStatus.completed:
        color = AppTheme.success;
        break;
      case AppointmentStatus.cancelled:
        color = AppTheme.danger;
        break;
      case AppointmentStatus.noShow:
        color = AppTheme.muted;
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
            status.label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
