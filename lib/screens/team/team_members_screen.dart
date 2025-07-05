import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/task_provider_offline.dart';
import '../../models/user_model.dart';
import '../../models/task_model.dart';

class TeamMembersScreen extends StatefulWidget {
  const TeamMembersScreen({super.key});

  @override
  State<TeamMembersScreen> createState() => _TeamMembersScreenState();
}

class _TeamMembersScreenState extends State<TeamMembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TaskProviderOffline>().loadTeamMembers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<TaskProviderOffline>(
        builder: (context, taskProvider, child) {
          if (taskProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final teamMembers = taskProvider.teamMembers;

          return Column(
            children: [
              _buildHeader(teamMembers.length),
              Expanded(
                child: teamMembers.isEmpty
                    ? _buildEmptyState()
                    : _buildMembersList(teamMembers),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(int memberCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.people,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                AppStrings.teamMembers,
                style: AppTextStyles.h4,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$memberCount ສະມາຊິກໃນທີມ',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(List<UserModel> members) {
    return RefreshIndicator(
      onRefresh: () async {
        await context.read<TaskProviderOffline>().loadTeamMembers();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return _buildMemberCard(member);
        },
      ),
    );
  }

  Widget _buildMemberCard(UserModel member) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: _getAvatarColor(member.role),
              child: Text(
                member.firstName.isNotEmpty ? member.firstName[0].toUpperCase() : 'U',
                style: AppTextStyles.h4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.fullName,
                        style: AppTextStyles.h6.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildStatusIndicator(member.isActive),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.email_outlined,
                      size: 16,
                      color: AppColors.textLight,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        member.email,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildRoleBadge(member.role),
                    const Spacer(),
                    _buildTaskStats(member),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? AppColors.success.withOpacity(0.1) : AppColors.textLight.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: isActive ? AppColors.success : AppColors.textLight,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'ອອນລາຍ' : 'ອອຟລາຍ',
            style: AppTextStyles.labelSmall.copyWith(
              color: isActive ? AppColors.success : AppColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final isAdmin = role == 'admin';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: isAdmin 
            ? AppColors.primaryGradient
            : LinearGradient(
                colors: [AppColors.success, AppColors.success.withOpacity(0.8)]
              ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin ? Icons.admin_panel_settings : Icons.person,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isAdmin ? 'ຜູ້ບໍລິຫານ' : 'ພະນັກງານ',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStats(UserModel member) {
    return Consumer<TaskProviderOffline>(
      builder: (context, taskProvider, child) {
        final userTasks = taskProvider.allTasks
            .where((task) => task.assignedTo == member.uid)
            .toList();
        final completedTasks = userTasks
            .where((task) => task.status == TaskStatus.completed)
            .length;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.assignment_turned_in,
                size: 14,
                color: AppColors.info,
              ),
              const SizedBox(width: 4),
              Text(
                '$completedTasks/${userTasks.length}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.info,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_outline,
                size: 60,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ບໍ່ມີສະມາຊິກໃນທີມ',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ສະມາຊິກທີມຈະສະແດງຢູ່ນີ້ເມື່ອມີການເພີ່ມ',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getAvatarColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.primary;
      default:
        return AppColors.secondary;
    }
  }
}