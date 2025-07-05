import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/auth_provider_offline.dart';  // ✅ เปลี่ยนเป็น offline
import '../../providers/task_provider_offline.dart';  // ✅ เปลี่ยนเป็น offline
import '../../widgets/common/custom_button.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildProfileHeader(context),
            _buildProfileStats(context),
            _buildProfileMenu(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return Consumer<AuthProviderOffline>(  // ✅ เปลี่ยนเป็น offline
      builder: (context, authProvider, child) {
        final user = authProvider.currentUser;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  user?.firstName.isNotEmpty == true
                      ? user!.firstName[0].toUpperCase()
                      : 'U',
                  style: AppTextStyles.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user?.fullName ?? 'ຜູ້ໃຊ້',
                style: AppTextStyles.h4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  user?.role == 'admin' ? 'ຜູ້ບໍລິຫານ' : 'ພະນັກງານ',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileStats(BuildContext context) {
    return Consumer<TaskProviderOffline>(  // ✅ เปลี่ยนเป็น offline
      builder: (context, taskProvider, child) {
        final stats = taskProvider.taskStatistics;
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ສະຖິຕິວຽກງານ',
                style: AppTextStyles.h6,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildStatItem('ທັງໝົດ', stats['total']?.toString() ?? '0', AppColors.info),
                  _buildStatItem('ສຳເລັດ', stats['completed']?.toString() ?? '0', AppColors.success),
                  _buildStatItem('ລໍຖ້າ', stats['pending']?.toString() ?? '0', AppColors.warning),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildMenuItem(
            Icons.person,
            'ແກ້ໄຂໂປຣໄຟລ์',
            () => _showEditProfileDialog(context),
          ),
          _buildMenuItem(
            Icons.lock,
            'ປ່ຽນລະຫັດຜ່ານ',
            () => _showChangePasswordDialog(context),
          ),
          _buildMenuItem(
            Icons.notifications,
            'ການແຈ້ງເຕືອນ',
            () => context.go('/notifications'),
          ),
          _buildMenuItem(
            Icons.settings,
            'ການຕັ້ງຄ່າ',
            () => context.go('/settings'),
          ),
          _buildMenuItem(
            Icons.help,
            'ຊ່ວຍເຫຼືອ',
            () => _showHelpDialog(context),  // ✅ เพิ่ม functionality
          ),
          _buildMenuItem(
            Icons.info,
            'ກ່ຽວກັບແອັບ',
            () => _showAboutDialog(context),
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: AppStrings.logout,
            onPressed: () => _showLogoutDialog(context),
            type: ButtonType.outline,
            icon: Icons.logout,
            isFullWidth: true,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: AppTextStyles.bodyMedium),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textLight),
        onTap: onTap,
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ແກ້ໄຂໂປຣໄຟລ์'),
        content: const Text('ໃນ Offline Mode: ຟີເຈີນີ້ຈະເຮັດວຽກໃນ Production'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ຕົກລົງ'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ປ່ຽນລະຫັດຜ່ານ'),
        content: const Text('ໃນ Offline Mode: ຟີເຈີນີ້ຈະເຮັດວຽກໃນ Production'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ຕົກລົງ'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ຊ່ວຍເຫຼືອ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📧 Email: support@easywork.com'),
            SizedBox(height: 8),
            Text('📱 ໂທ: +856 20 1234 5678'),
            SizedBox(height: 8),
            Text('🌐 Website: www.easywork.com'),
            SizedBox(height: 12),
            Text(
              'ຫາກທ່ານມີຄຳຖາມ ຫຼື ປັນຫາໃດໆ ກະລຸນາຕິດຕໍ່ພວກເຮົາ',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ຕົກລົງ'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.appName),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ເວີຊັນ: 1.0.0 (Offline Mode)'),
            SizedBox(height: 8),
            Text('ພັດທະນາໂດຍ: Easy Work Team'),
            SizedBox(height: 8),
            Text('ແອັບຈັດການວຽກງານສຳລັບອົງກອນ'),
            SizedBox(height: 12),
            Text(
              'ປັດຈຸບັນເຮັດວຽກໃນໂໝດ Offline ດ້ວຍຂໍ້ມູນ Demo',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ຕົກລົງ'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.logout),
        content: Text(AppStrings.logoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await context.read<AuthProviderOffline>().signOut();  // ✅ เปลี่ยนเป็น offline
              if (context.mounted) {
                context.go('/login');
              }
            },
            child: Text(
              AppStrings.logout,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}