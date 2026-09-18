import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/theme.dart';
import '../../app/theme_controller.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import 'medical_records_tab.dart';
import 'search_tab.dart';
import 'notifications_tab.dart';
import 'help_support_tab.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentTabIndex = 0;

  final List<String> _tabTitles = [
    'Home',
    'Medical Records',
    'Search',
    'Notifications',
    'Help & Support',
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  void _onDrawerItemTapped(String route) {
    Navigator.pop(context);
    Navigator.pushNamed(context, route);
  }

  void _onLogout() {
    Navigator.pop(context);
    context.read<AuthController>().logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppTheme.heroGradient,
          ),
        ),
        title: Column(
          children: [
            Text(
              _tabTitles[_currentTabIndex],
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 1),
            const Text(
              'TMC CareLink Clinic',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: Color(0xFFBBE5DE),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        centerTitle: true,
        elevation: 0,
        leading: Builder(
          builder: (context) => Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              color: Colors.white.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => Scaffold.of(context).openDrawer(),
                child: const Icon(Icons.menu, color: Colors.white, size: 22),
              ),
            ),
          ),
        ),
        actions: [
          Consumer<ThemeController>(
            builder: (context, themeCtrl, _) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Material(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => themeCtrl.toggleTheme(),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      themeCtrl.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: themeCtrl.isDarkMode ? AppTheme.gold : Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_currentTabIndex == 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Material(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.person_outline, color: Colors.white, size: 22),
                  ),
                ),
              ),
            ),
        ],
      ),
      drawer: _buildDrawer(context),
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          const DashboardScreen(),
          const MedicalRecordsTab(),
          const SearchTab(),
          const NotificationsTab(),
          const HelpSupportTab(),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    final auth = context.watch<AuthController>();
    final userName = auth.session?.user.name ?? 'Patient';
    final userEmail = auth.session?.user.email ?? '';

    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 54, 22, 24),
              decoration: const BoxDecoration(
                gradient: AppTheme.heroGradient,
                borderRadius: BorderRadius.only(topRight: Radius.circular(28)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.gold, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.gold.withAlpha(50),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.white.withAlpha(45),
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 24,
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
                              userName,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              userEmail,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withAlpha(200),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withAlpha(40),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.success.withAlpha(80)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified, color: Color(0xFF6DE3A7), size: 13),
                        SizedBox(width: 5),
                        Text(
                          'Active Patient Account',
                          style: TextStyle(
                            color: Color(0xFFE8F7F0),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'CLINICAL SERVICES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.muted,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  _DrawerItem(
                    icon: Icons.local_hospital_outlined,
                    title: 'Clinic Information',
                    onTap: () => _onDrawerItemTapped('/clinic-information'),
                  ),
                  _DrawerItem(
                    icon: Icons.calendar_today_outlined,
                    title: 'Appointments',
                    onTap: () => _onDrawerItemTapped('/appointments'),
                  ),
                  _DrawerItem(
                    icon: Icons.chat_bubble_outline,
                    title: 'Consultations',
                    onTap: () => _onDrawerItemTapped('/consultations'),
                  ),
                  _DrawerItem(
                    icon: Icons.folder_open_outlined,
                    title: 'Medical Records',
                    onTap: () => _onDrawerItemTapped('/medical-records'),
                  ),
                  _DrawerItem(
                    icon: Icons.description_outlined,
                    title: 'Prescriptions',
                    onTap: () => _onDrawerItemTapped('/prescriptions'),
                  ),
                  _DrawerItem(
                    icon: Icons.article_outlined,
                    title: 'Medical Certificates',
                    onTap: () => _onDrawerItemTapped('/medical-certificates'),
                  ),
                  _DrawerItem(
                    icon: Icons.notifications_outlined,
                    title: 'Notifications',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentTabIndex = 3);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Divider(height: 1, color: AppTheme.line),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'ACCOUNT & SUPPORT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.muted,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  _DrawerItem(
                    icon: Icons.person_outline,
                    title: 'My Profile',
                    onTap: () => _onDrawerItemTapped('/profile'),
                  ),
                  _DrawerItem(
                    icon: Icons.help_outline,
                    title: 'Help & Support',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() => _currentTabIndex = 4);
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Divider(height: 1),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Text(
                      'PREFERENCES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.muted,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ),
                  Consumer<ThemeController>(
                    builder: (context, themeCtrl, _) {
                      final isDark = AppTheme.isDark(context);
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isDark ? AppTheme.darkSurfaceSubtle : AppTheme.surfaceSubtle,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.getLine(context)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              themeCtrl.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                              size: 20,
                              color: themeCtrl.isDarkMode ? AppTheme.gold : AppTheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Dark Theme',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.getInk(context),
                                ),
                              ),
                            ),
                            Switch.adaptive(
                              value: themeCtrl.isDarkMode,
                              activeTrackColor: AppTheme.primary,
                              activeThumbColor: AppTheme.primaryLight,
                              onChanged: (_) => themeCtrl.toggleTheme(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Divider(height: 1),
                  ),
                  _DrawerItem(
                    icon: Icons.logout,
                    title: 'Sign Out',
                    color: AppTheme.danger,
                    onTap: _onLogout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    final isDark = AppTheme.isDark(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: isDark ? AppTheme.cardShadowDark : AppTheme.cardShadow,
        border: Border(top: BorderSide(color: AppTheme.getLine(context), width: 0.8)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          child: BottomNavigationBar(
            currentIndex: _currentTabIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            selectedItemColor: isDark ? AppTheme.primaryLight : AppTheme.primary,
            unselectedItemColor: isDark ? AppTheme.darkMuted : AppTheme.mutedLight,
            selectedFontSize: 11.5,
            unselectedFontSize: 11.5,
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
            elevation: 0,
            items: [
              _buildNavItem(Icons.home_outlined, Icons.home_rounded, 'Home', 0),
              _buildNavItem(Icons.folder_outlined, Icons.folder_rounded, 'Records', 1),
              _buildNavItem(Icons.search_rounded, Icons.search_rounded, 'Search', 2),
              _buildNavItem(Icons.notifications_none_rounded, Icons.notifications_rounded, 'Alerts', 3),
              _buildNavItem(Icons.help_outline_rounded, Icons.help_rounded, 'Help', 4),
            ],
          ),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(
    IconData icon,
    IconData activeIcon,
    String label,
    int index,
  ) {
    final isSelected = _currentTabIndex == index;
    final isDark = AppTheme.isDark(context);
    return BottomNavigationBarItem(
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppTheme.primaryLight.withAlpha(40) : AppTheme.primary.withAlpha(22))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Icon(isSelected ? activeIcon : icon, size: 22),
      ),
      label: label,
    );
  }
}


class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    final itemColor = color ?? AppTheme.getInk(context);
    final isDanger = color == AppTheme.danger;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: isDanger
            ? (isDark ? AppTheme.danger.withAlpha(35) : AppTheme.dangerLight.withAlpha(120))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? AppTheme.primary).withAlpha(isDanger ? 25 : 18),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: itemColor, size: 19),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: itemColor,
          ),
        ),
        trailing: isDanger
            ? null
            : Icon(
                Icons.arrow_forward_ios_rounded,
                size: 13,
                color: AppTheme.getMutedLight(context),
              ),
        onTap: onTap,
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}
