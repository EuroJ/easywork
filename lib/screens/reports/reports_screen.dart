import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/task_provider_offline.dart';  // ✅ เปลี่ยนเป็น offline

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedPeriod = 'thisMonth';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildPeriodSelector(),
            _buildOverviewCards(),
            _buildProductivityChart(),
            _buildTaskStatusChart(),
            _buildDetailedStats(),
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
            AppStrings.reports,
            style: AppTextStyles.h4,
          ),
          const Spacer(),
          IconButton(
            onPressed: _exportReport,
            icon: const Icon(Icons.download, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildPeriodButton('ມື້ນີ້', 'today'),
          _buildPeriodButton('ອາທິດນີ້', 'thisWeek'),
          _buildPeriodButton('ເດືອນນີ້', 'thisMonth'),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String label, String value) {
    final isSelected = _selectedPeriod == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPeriod = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelMedium.copyWith(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    return Consumer<TaskProviderOffline>(  // ✅ เปลี่ยนเป็น offline
      builder: (context, taskProvider, child) {
        final stats = taskProvider.taskStatistics;
        final total = stats['total'] ?? 0;
        final completed = stats['completed'] ?? 0;
        final productivity = total > 0 ? (completed / total * 100).round() : 0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildOverviewCard(
                  'ຜົນງານ',
                  '$productivity%',
                  Icons.trending_up,
                  AppColors.success,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  'ວຽກສຳເລັດ',
                  '$completed',
                  Icons.check_circle,
                  AppColors.info,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildOverviewCard(
                  'ວຽກທັງໝົດ',
                  '$total',
                  Icons.assignment,
                  AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOverviewCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProductivityChart() {
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
            'ຜົນງານປະຈໍາອາທິດ',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: _buildSimpleChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleChart() {
    final data = [30, 45, 60, 80, 70, 90, 85]; // Sample data
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(data.length, (index) {
        final height = (data[index] / maxValue) * 150;
        final days = ['ຈ', 'ອ', 'ພ', 'ພຫ', 'ສ', 'ສ', 'ອາ'];
        
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              '${data[index]}%',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 24,
              height: height,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              days[index],
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTaskStatusChart() {
    return Consumer<TaskProviderOffline>(  // ✅ เปลี่ยนเป็น offline
      builder: (context, taskProvider, child) {
        final stats = taskProvider.taskStatistics;
        
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
                'ສະຖານະວຽກງານ',
                style: AppTextStyles.h6,
              ),
              const SizedBox(height: 20),
              _buildStatusItem('ສຳເລັດ', stats['completed'] ?? 0, AppColors.success),
              _buildStatusItem('ກຳລັງເຮັດ', stats['inProgress'] ?? 0, AppColors.info),
              _buildStatusItem('ລໍຖ້າ', stats['pending'] ?? 0, AppColors.warning),
              _buildStatusItem('ໝົດກຳໜົດ', stats['overdue'] ?? 0, AppColors.error),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusItem(String label, int count, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: AppTextStyles.labelMedium.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStats() {
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
            'ລາຍລະອຽດ',
            style: AppTextStyles.h6,
          ),
          const SizedBox(height: 16),
          _buildDetailItem('ວຽກສ້າງໃໝ່', '8', Icons.add_circle_outline),
          _buildDetailItem('ວຽກສຳເລັດໃນເວລາ', '12', Icons.schedule),
          _buildDetailItem('ວຽກຊັກຊ້າ', '2', Icons.warning_amber),
          _buildDetailItem('ເວລາເຮັດວຽກເຉລີ່ຍ', '4.5 ຊົ່ວໂມງ', Icons.access_time),
          _buildDetailItem('ອັດຕາສຳເລັດ', '85%', Icons.trending_up),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textLight, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: AppTextStyles.bodyMedium,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  void _exportReport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ສົ່ງອອກລາຍງານ'),
        content: const Text('ໃນ Offline Mode: ຟີເຈີນີ້ຈະເຮັດວຽກໃນ Production'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ຍົກເລີກ'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showExportSuccess('PDF');
            },
            child: const Text('PDF'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showExportSuccess('Excel');
            },
            child: const Text('Excel'),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showExportSuccess(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Demo: ສົ່ງອອກລາຍງານ $format ສຳເລັດ'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}