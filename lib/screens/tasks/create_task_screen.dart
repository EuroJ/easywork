import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/task_provider_offline.dart';
import '../../providers/auth_provider_offline.dart';
import '../../models/task_model.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime _selectedDueDate = DateTime.now().add(const Duration(days: 7));
  String? _selectedAssigneeId;
  bool _isLoading = false;

  // รายชื่อทีมแบบง่าย
  final List<Map<String, String>> _teamMembers = [
    {'id': 'admin', 'name': 'ແອດມິນ', 'role': 'admin'},
    {'id': 'john', 'name': 'John', 'role': 'employee'},
    {'id': 'mary', 'name': 'Mary', 'role': 'employee'},
    {'id': 'demo', 'name': 'Demo User', 'role': 'employee'},
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _createTask() async {
    // ตรวจสอบแค่ชื่องาน
    if (_titleController.text.trim().isEmpty) {
      _showMessage('ກະລຸນາໃສ່ຊື່ງານ', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProviderOffline>();
      final taskProvider = context.read<TaskProviderOffline>();

      final success = await taskProvider.createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty 
            ? 'ບໍ່ມີລາຍລະອຽດ' 
            : _descriptionController.text.trim(),
        createdBy: authProvider.currentUser?.uid ?? 'unknown',
        assignedTo: _selectedAssigneeId ?? 'admin',
        dueDate: _selectedDueDate,
        priority: _selectedPriority,
        category: 'General',
      );

      if (success && mounted) {
        _showMessage('ສ້າງງານສຳເລັດ!');
        context.go('/tasks');
      } else if (mounted) {
        _showMessage('ເກີດຂໍ້ຜິດພາດ', isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showMessage('ເກີດຂໍ້ຜິດພາດ: $e', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ສ້າງງານໃໝ່'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ชื่องาน (บังคับ)
            _buildSectionCard(
              title: 'ຊື່ງານ *',
              icon: Icons.title,
              child: TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'ໃສ່ຊື່ງານ...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 1,
              ),
            ),
            
            const SizedBox(height: 16),

            // รายละเอียด (ไม่บังคับ)
            _buildSectionCard(
              title: 'ລາຍລະອຽດ',
              icon: Icons.description,
              child: TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'ລາຍລະອຽດງານ (ທາງເລືອກ)...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ),

            const SizedBox(height: 16),

            // เลือกผู้รับผิดชอบ
            _buildSectionCard(
              title: 'ຜູ້ຮັບຜິດຊອບ',
              icon: Icons.person,
              child: DropdownButtonFormField<String>(
                value: _selectedAssigneeId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'ເລືອກຜູ້ຮັບຜິດຊອບ...',
                ),
                items: _teamMembers.map((member) {
                  return DropdownMenuItem<String>(
                    value: member['id'],
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: member['role'] == 'admin' 
                              ? AppColors.primary 
                              : AppColors.secondary,
                          child: Text(
                            member['name']![0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(member['name']!),
                        const SizedBox(width: 4),
                        if (member['role'] == 'admin')
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Admin',
                              style: TextStyle(color: Colors.white, fontSize: 10),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedAssigneeId = value;
                  });
                },
              ),
            ),

            const SizedBox(height: 16),

            // วันกำหนดส่ง
            _buildSectionCard(
              title: 'ວັນກຳໜົດສົ່ງ',
              icon: Icons.calendar_today,
              child: InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text(_formatDate(_selectedDueDate)),
                      const Spacer(),
                      Text(
                        _getDaysFromNow(_selectedDueDate),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ความสำคัญ
            _buildSectionCard(
              title: 'ຄວາມສຳຄັນ',
              icon: Icons.priority_high,
              child: Row(
                children: TaskPriority.values.map((priority) {
                  final isSelected = _selectedPriority == priority;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedPriority = priority;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _getPriorityColor(priority).withValues(alpha: 0.1)
                                : Colors.grey.withValues(alpha: 0.1),
                            border: Border.all(
                              color: isSelected
                                  ? _getPriorityColor(priority)
                                  : Colors.grey,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                _getPriorityIcon(priority),
                                color: isSelected
                                    ? _getPriorityColor(priority)
                                    : Colors.grey,
                                size: 20,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _getPriorityText(priority),
                                style: TextStyle(
                                  color: isSelected
                                      ? _getPriorityColor(priority)
                                      : Colors.grey,
                                  fontSize: 12,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 32),

            // ปุ่มสร้าง
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _createTask,
              icon: _isLoading 
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.add_task),
              label: Text(_isLoading ? 'ກຳລັງສ້າງ...' : 'ສ້າງງານ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null && picked != _selectedDueDate) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _getDaysFromNow(DateTime date) {
    final difference = date.difference(DateTime.now()).inDays;
    if (difference == 0) return 'ມື້ນີ້';
    if (difference == 1) return 'ມື້ອື່ນ';
    if (difference > 1) return 'ອີກ $difference ມື້';
    return 'ຜ່ານມາແລ້ວ';
  }

  Color _getPriorityColor(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return AppColors.error;
      case TaskPriority.medium:
        return AppColors.warning;
      case TaskPriority.low:
        return AppColors.success;
    }
  }

  IconData _getPriorityIcon(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return Icons.priority_high;
      case TaskPriority.medium:
        return Icons.remove;
      case TaskPriority.low:
        return Icons.keyboard_arrow_down;
    }
  }

  String _getPriorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'ສູງ';
      case TaskPriority.medium:
        return 'ປານກາງ';
      case TaskPriority.low:
        return 'ຕ່ຳ';
    }
  }
}