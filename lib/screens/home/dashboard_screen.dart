import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/task_provider_offline.dart';  // ✅ เปลี่ยนเป็น offline
import '../../providers/auth_provider_offline.dart';  // ✅ เปลี่ยนเป็น offline
import '../../models/task_model.dart';
import '../../widgets/task/task_card.dart';
import '../../widgets/common/gradient_background.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          final authProvider = context.read<AuthProviderOffline>();  // ✅ เปลี่ยนเป็น offline
          final taskProvider = context.read<TaskProviderOffline>();  // ✅ เปลี่ยนเป็น offline
          if (authProvider.currentUser != null) {
            await taskProvider.loadTaskStatistics(authProvider.currentUser!.uid);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 20),
              _buildStatisticsCards(),
              const SizedBox(height: 24),
              _buildQuickActions(context),
              const SizedBox(height: 24),
              _buildTodayTasks(),
              const SizedBox(height: 24),
              _buildOverdueTasks(),
              const SizedBox(height: 24),
              _buildRecentActivity(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ມື້ນີ້ - ${_formatDate(DateTime.now())}',  // ✅ ใช้ custom date formatter
            style: AppTextStyles.labelMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Consumer<AuthProviderOffline>(  // ✅ เปลี่ยนเป็น offline
            builder: (context, authProvider, child) {
              return Text(
                'ສະບາຍດີ, ${authProvider.currentUser?.firstName ?? 'ຜູ້ໃຊ້'}!',
                style: AppTextStyles.h4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            'ໃຫ້ທ່ານມີວັນທີ່ມີປະສິດທິພາບ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsCards() {
    return Consumer<TaskProviderOffline>(  // ✅ เปลี่ยนเป็น offline
      builder: (context, taskProvider, child) {
        final stats = taskProvider.taskStatistics;
        return GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildStatCard(
              title: AppStrings.totalTasks,
              value: stats['total']?.toString() ?? '0',
              icon: Icons.assignment,
              color: AppColors.info,
              onTap: () => context.go('/tasks'),
            ),
            _buildStatCard(
              title: AppStrings.tasksCompleted,
              value: stats['completed']?.toString() ?? '0',
              icon: Icons.check_circle,
              color: AppColors.success,
            ),
            _buildStatCard(
              title: AppStrings.tasksPending,
              value: stats['pending']?.toString() ?? '0',
              icon: Icons.pending,
              color: AppColors.warning,
            ),
            _buildStatCard(
              title: 'ໝົດກຳໜົດ',
              value: stats['overdue']?.toString() ?? '0',
              icon: Icons.warning,
              color: AppColors.error,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        icon,
                        color: color,
                        size: 20,
                      ),
                    ),
                    const Spacer(),
                    if (onTap != null)
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppColors.textLight,
                      ),
                  ],
                ),
                const Spacer(),
                Text(
                  value,
                  style: AppTextStyles.h3.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ການກະທຳດ່ວນ',
          style: AppTextStyles.h5.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                title: 'ສ້າງວຽກງານ',
                icon: Icons.add_task,
                color: AppColors.primary,
                onTap: () => context.go('/create-task'),  // ✅ แก้ route
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                title: 'ທີມງານ',
                icon: Icons.people,
                color: AppColors.secondary,
                onTap: () => context.go('/team'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildQuickActionButton(
                title: 'ລາຍງານ',
                icon: Icons.analytics,
                color: AppColors.accent,
                onTap: () => context.go('/reports'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            child: Column(
              children: [
                Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayTasks() {
    return Consumer<TaskProviderOffline>(  // ✅ เปลี่ยนเป็น offline
      builder: (context, taskProvider, child) {
        final todayTasks = taskProvider.todayTasks;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'ວຽກງານມື້ນີ້',
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (todayTasks.isNotEmpty)
                  TextButton(
                    onPressed: () => context.go('/tasks'),
                    child: Text(
                      'ເບິ່ງທັງໝົດ',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (todayTasks.isEmpty)
              _buildEmptyState(
                'ບໍ່ມີວຽກງານມື້ນີ້',
                'ທ່ານໄດ້ທໍາເຮັດວຽກງານມື້ນີ້ສໍາເລັດແລ້ວ!',
                Icons.celebration,
                AppColors.success,
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: todayTasks.length > 3 ? 3 : todayTasks.length,
                itemBuilder: (context, index) {
                  return TaskCard(
                    task: todayTasks[index],
                    onTap: () => context.go('/task/${todayTasks[index].id}'),
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Widget _buildOverdueTasks() {
    return Consumer<TaskProviderOffline>(  // ✅ เปลี่ยนเป็น offline
      builder: (context, taskProvider, child) {
        final overdueTasks = taskProvider.overdueTasks;
        
        if (overdueTasks.isEmpty) return const SizedBox.shrink();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning,
                  color: AppColors.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'ວຽກງານໝົດກຳໜົດ',
                  style: AppTextStyles.h5.copyWith(
                    color: AppColors.error,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.go('/tasks'),
                  child: Text(
                    'ແກ້ໄຂດ່ວນ',
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: overdueTasks.length > 2 ? 2 : overdueTasks.length,
              itemBuilder: (context, index) {
                return TaskCard(
                  task: overdueTasks[index],
                  onTap: () => context.go('/task/${overdueTasks[index].id}'),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildRecentActivity() {
    return Consumer<TaskProviderOffline>(  // ✅ เปลี่ยนเป็น offline
      builder: (context, taskProvider, child) {
        final recentTasks = taskProvider.userTasks.take(5).toList();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ກິດຈະກຳຫຼ້າສຸດ',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            if (recentTasks.isEmpty)
              _buildEmptyState(
                'ບໍ່ມີກິດຈະກຳ',
                'ເມື່ອທ່ານເລີ່ມເຮັດວຽກ ກິດຈະກຳຈະສະແດງຢູ່ນີ້',
                Icons.history,
                AppColors.textLight,
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentTasks.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    color: AppColors.divider,
                  ),
                  itemBuilder: (context, index) {
                    final task = recentTasks[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getStatusColor(task.status).withOpacity(0.1),
                        child: Icon(
                          _getStatusIcon(task.status),
                          color: _getStatusColor(task.status),
                          size: 20,
                        ),
                      ),
                      title: Text(
                        task.title,
                        style: AppTextStyles.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        task.statusText,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: _getStatusColor(task.status),
                        ),
                      ),
                      trailing: Text(
                        _formatShortDate(task.dueDate),  // ✅ ใช้ custom date formatter
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.textLight,
                        ),
                      ),
                      onTap: () => context.go('/task/${task.id}'),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 48,
            color: color.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTextStyles.h6.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ✅ Custom date formatters เพื่อหลีกเลี่ยง LocaleDataException
  String _formatDate(DateTime date) {
    try {
      return DateFormat('dd MMMM yyyy').format(date);
    } catch (e) {
      // Fallback ถ้า locale ไม่รองรับ
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatShortDate(DateTime date) {
    try {
      return DateFormat('dd/MM').format(date);
    } catch (e) {
      // Fallback ถ้า locale ไม่รองรับ
      return '${date.day}/${date.month}';
    }
  }

  Color _getStatusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return AppColors.warning;
      case TaskStatus.inProgress:
        return AppColors.info;
      case TaskStatus.completed:
        return AppColors.success;
      case TaskStatus.cancelled:
        return AppColors.error;
    }
  }

  IconData _getStatusIcon(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return Icons.pending;
      case TaskStatus.inProgress:
        return Icons.play_circle;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.cancelled:
        return Icons.cancel;
    }
  }
}