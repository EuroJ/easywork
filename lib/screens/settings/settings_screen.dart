import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildNotificationSettings(),
            _buildAppSettings(),
            _buildAboutSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
      child: Row(
        children: [
          Text(
            AppStrings.settings,
            style: AppTextStyles.h4,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
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
            'ການແຈ້ງເຕືອນ',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'ເປີດການແຈ້ງເຕືອນ',
            'ຮັບການແຈ້ງເຕືອນສຳລັບວຽກງານໃໝ່',
            _notificationsEnabled,
            (value) => setState(() => _notificationsEnabled = value),
          ),
          _buildSwitchTile(
            'ແຈ້ງເຕືອນທາງອີເມລ',
            'ຮັບການແຈ້ງເຕືອນທາງອີເມລ',
            _emailNotifications,
            (value) => setState(() => _emailNotifications = value),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
            'ການຕັ້ງຄ່າແອັບ',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            'ໂໝດມືດ',
            'ໃຊ້ໂໝດມືດສຳລັບສາຍຕາ',
            _darkMode,
            (value) => setState(() => _darkMode = value),
          ),
          _buildSettingsTile(
            Icons.language,
            'ພາສາ',
            'ລາວ',
            () => _showLanguageDialog(),
          ),
          _buildSettingsTile(
            Icons.storage,
            'ການຈັດເກັບຂໍ້ມູນ',
            'ລ້າງແຄສ',
            () => _showClearCacheDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
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
            'ກ່ຽວກັບ',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: 16),
          _buildSettingsTile(
            Icons.info,
            'ເວີຊັນແອັບ',
            '1.0.0 (Offline Mode)',
            () => _showVersionInfo(),
          ),
          _buildSettingsTile(
            Icons.privacy_tip,
            'ນະໂຍບາຍຄວາມເປັນສ່ວນຕົວ',
            '',
            () => _showPrivacyPolicy(),
          ),
          _buildSettingsTile(
            Icons.description,
            'ເງື່ອນໄຂການໃຊ້ງານ',
            '',
            () => _showTermsOfService(),
          ),
          _buildSettingsTile(
            Icons.help,
            'ຊ່ວຍເຫຼືອ',
            '',
            () => _showHelpDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, String subtitle, bool value, Function(bool) onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTextStyles.bodyMedium),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: AppTextStyles.bodySmall) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textLight),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showVersionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ຂໍ້ມູນເວີຊັນ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ເວີຊັນແອັບ: 1.0.0'),
            SizedBox(height: 8),
            Text('ໂໝດ: Offline Demo'),
            SizedBox(height: 8),
            Text('ວັນທີ່ອັບເດດ: 2024-12-26'),
            SizedBox(height: 12),
            Text(
              'ເວີຊັນ Offline ນີ້ໃຊ້ຂໍ້ມູນ Demo ສຳລັບການທົດສອບ',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
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

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ເລືອກພາສາ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('ລາວ'),
              leading: Radio(
                value: 'lo',
                groupValue: 'lo',
                onChanged: (value) {},
                activeColor: AppColors.primary,
              ),
            ),
            ListTile(
              title: const Text('English'),
              leading: Radio(
                value: 'en',
                groupValue: 'lo',
                onChanged: (value) {},
                activeColor: AppColors.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ຍົກເລີກ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showComingSoon('ການປ່ຽນພາສາ');
            },
            child: const Text('ຕົກລົງ'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ລ້າງແຄສ'),
        content: const Text('ທ່ານຕ້ອງການລ້າງຂໍ້ມູນແຄສບໍ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ຍົກເລີກ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Demo: ລ້າງແຄສສຳເລັດ'),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: const Text('ລ້າງ'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ນະໂຍບາຍຄວາມເປັນສ່ວນຕົວ'),
        content: const SingleChildScrollView(
          child: Text(
            'ນະໂຍບາຍຄວາມເປັນສ່ວນຕົວຂອງ Easy Work\n\n'
            'ພວກເຮົາໃຫ້ຄວາມສຳຄັນກັບຄວາມເປັນສ່ວນຕົວຂອງທ່ານ\n\n'
            '1. ການເກັບກໍາຂໍ້ມູນ\n'
            'ພວກເຮົາເກັບກໍາຂໍ້ມູນທີ່ຈໍາເປັນສໍາລັບການໃຫ້ບໍລິການ\n\n'
            '2. ການນໍາໃຊ້ຂໍ້ມູນ\n'
            'ຂໍ້ມູນຈະຖືກໃຊ້ເພື່ອປັບປຸງບໍລິການ\n\n'
            '3. ການຮັກສາຄວາມປອດໄພ\n'
            'ພວກເຮົາມີມາດຕະການຄວາມປອດໄພທີ່ເຂັ້ມງວດ',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ປິດ'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ເງື່ອນໄຂການໃຊ້ງານ'),
        content: const SingleChildScrollView(
          child: Text(
            'ເງື່ອນໄຂການໃຊ້ງານ Easy Work\n\n'
            '1. ການຍອມຮັບເງື່ອນໄຂ\n'
            'ການໃຊ້ງານແອັບນີ້ຖືວ່າທ່ານຍອມຮັບເງື່ອນໄຂທັງໝົດ\n\n'
            '2. ການໃຊ້ງານທີ່ເໝາະສົມ\n'
            'ທ່ານຕ້ອງໃຊ້ງານແອັບຢ່າງຖືກຕ້ອງ\n\n'
            '3. ຄວາມຮັບຜິດຊອບ\n'
            'ທ່ານຮັບຜິດຊອບຕໍ່ການໃຊ້ງານຂອງທ່ານ\n\n'
            '4. ການປ່ຽນແປງເງື່ອນໄຂ\n'
            'ພວກເຮົາມີສິດປ່ຽນແປງເງື່ອນໄຂໄດ້',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ປິດ'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ຊ່ວຍເຫຼືອ'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ຕິດຕໍ່ພວກເຮົາ:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.email, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text('support@easywork.com'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text('+856 20 1234 5678'),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.language, size: 16, color: AppColors.primary),
                SizedBox(width: 8),
                Text('www.easywork.com'),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'ຫາກທ່ານມີຄຳຖາມ ຫຼື ປັນຫາໃດໆ ກະລຸນາຕິດຕໍ່ພວກເຮົາ',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ປິດ'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature ຈະມາໃນເວີຊັນຕໍ່ໄປ'),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}