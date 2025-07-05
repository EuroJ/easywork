import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider_offline.dart';  // ✅ เปลี่ยนเป็น offline
import '../../providers/task_provider_offline.dart';  // ✅ เปลี่ยนเป็น offline

class HomeScreen extends StatefulWidget {
  final Widget child;

  const HomeScreen({super.key, required this.child});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.dashboard_outlined,
      selectedIcon: Icons.dashboard,
      label: AppStrings.dashboard,
      route: '/dashboard',
    ),
    NavigationItem(
      icon: Icons.task_outlined,
      selectedIcon: Icons.task,
      label: AppStrings.tasks,
      route: '/tasks',
    ),
    NavigationItem(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: AppStrings.team,
      route: '/team',
    ),
    NavigationItem(
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart,
      label: AppStrings.reports,
      route: '/reports',
    ),
    NavigationItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: AppStrings.profile,
      route: '/profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeProviders();
    });
  }

  void _initializeProviders() {
    final authProvider = context.read<AuthProviderOffline>();  // ✅ เปลี่ยนเป็น offline
    final taskProvider = context.read<TaskProviderOffline>();  // ✅ เปลี่ยนเป็น offline
    
    if (authProvider.currentUser != null) {
      taskProvider.initializeTaskStreams(authProvider.currentUser!.uid);
      taskProvider.loadTeamMembers();
    }
  }

  void _onNavigationTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    context.go(_navigationItems[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: widget.child,
      bottomNavigationBar: _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Consumer<AuthProviderOffline>(  // ✅ เปลี่ยนเป็น offline
        builder: (context, authProvider, child) {
          final user = authProvider.currentUser;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                user?.fullName ?? 'ຜູ້ໃຊ້',
                style: AppTextStyles.h6.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          );
        },
      ),
      actions: [
        IconButton(
          onPressed: () => context.go('/notifications'),
          icon: Stack(
            children: [
              const Icon(
                Icons.notifications_outlined,
                color: AppColors.textPrimary,
              ),
              Positioned(
                right: 0,
                top: 0,
                child: Consumer<TaskProviderOffline>(  // ✅ เปลี่ยนเป็น offline
                  builder: (context, taskProvider, child) {
                    final overdueCount = taskProvider.overdueTasks.length;
                    if (overdueCount > 0) {
                      return Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          overdueCount > 9 ? '9+' : overdueCount.toString(),
                          style: AppTextStyles.labelSmall.copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => context.go('/settings'),
          icon: const Icon(
            Icons.settings_outlined,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomAppBar(
        height: 70,
        color: Colors.transparent,
        elevation: 0,
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        child: Row(
          children: [
            for (int i = 0; i < _navigationItems.length; i++) ...[
              if (i == 2) const Spacer(),
              _buildNavigationItem(i),
              if (i == 1) const Spacer(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationItem(int index) {
    final item = _navigationItems[index];
    final isSelected = _selectedIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () => _onNavigationTap(index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isSelected ? item.selectedIcon : item.icon,
                color: isSelected ? AppColors.primary : AppColors.textLight,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                item.label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textLight,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => context.go('/create-task'),  // ✅ แก้ route
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'ສະບາຍດີຕອນເຊົ້າ';
    } else if (hour < 17) {
      return 'ສະບາຍດີຕອນບ່າຍ';
    } else {
      return 'ສະບາຍດີຕອນແລງ';
    }
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final String route;

  NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.route,
  });
}