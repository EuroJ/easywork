import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/task_provider_offline.dart';
import '../../providers/auth_provider_offline.dart';
import '../../models/task_model.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _commentController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProviderOffline>(
      builder: (context, taskProvider, child) {
        // ใช้ sync method แทน async
        final task = taskProvider.allTasks.firstWhere(
          (t) => t.id == widget.taskId,
          orElse: () => TaskModel(
            id: '',
            title: '',
            description: '',
            assignedTo: '',
            createdBy: '',
            dueDate: DateTime.now(),
            priority: TaskPriority.low,
            status: TaskStatus.pending,
            progress: 0,
            createdAt: DateTime.now(),
            comments: [],
          ),
        );
        
        if (task.id.isEmpty) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('ລາຍລະອຽດງານ'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.error,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ບໍ່ພົບງານທີ່ຕ້ອງການ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              task.title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            actions: [
              IconButton(
                onPressed: () => _showEditDialog(),
                icon: const Icon(Icons.edit),
                tooltip: 'ແກ້ໄຂ',
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primary.withValues(alpha: 0.1),
                  AppColors.background,
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTaskInfoCard(task),
                  const SizedBox(height: 16),
                  _buildStatusCard(task),
                  const SizedBox(height: 16),
                  _buildProgressCard(task),
                  const SizedBox(height: 16),
                  _buildCommentsCard(task),
                  const SizedBox(height: 80), // เว้นที่สำหรับ FAB
                ],
              ),
            ),
          ),
          floatingActionButton: _buildActionButtons(task),
        );
      },
    );
  }

  Widget _buildTaskInfoCard(TaskModel task) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.task_alt,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'ຂໍ້ມູນງານ',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                _buildPriorityChip(task.priority),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              task.title,
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              task.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.category, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  task.category ?? 'General',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 20),
                const Icon(Icons.calendar_today, size: 16, color: AppColors.textSecondary),
                const SizedBox(width: 8),
                Text(
                  _formatDate(task.dueDate),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(TaskModel task) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info,
                    color: AppColors.secondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'ສະຖານະ',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: TaskStatus.values.map((status) {
                final isSelected = task.status == status;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: InkWell(
                      onTap: () => _updateTaskStatus(task, status),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? _getStatusColor(status).withValues(alpha: 0.1)
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? _getStatusColor(status)
                                : AppColors.border,
                            width: isSelected ? 2 : 1,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              _getStatusIcon(status),
                              color: isSelected
                                  ? _getStatusColor(status)
                                  : AppColors.textSecondary,
                              size: 24,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getStatusText(status),
                              style: AppTextStyles.labelSmall.copyWith(
                                color: isSelected
                                    ? _getStatusColor(status)
                                    : AppColors.textSecondary,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(TaskModel task) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.trending_up,
                    color: AppColors.success,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'ຄວາມຄືບໜ້າ',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${task.progress.round()}%',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: task.progress / 100,
              backgroundColor: AppColors.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                task.progress >= 100 ? AppColors.success : AppColors.primary,
              ),
              minHeight: 8,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: task.progress > 0 
                        ? () => _updateProgress(task, task.progress - 10)
                        : null,
                    icon: const Icon(Icons.remove, size: 16),
                    label: const Text('-10%'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: task.progress < 100 
                        ? () => _updateProgress(task, task.progress + 10)
                        : null,
                    icon: const Icon(Icons.add, size: 16),
                    label: const Text('+10%'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsCard(TaskModel task) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.comment,
                    color: AppColors.accent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'ຄຳເຫັນ (${task.comments.length})',
                  style: AppTextStyles.h6.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (task.comments.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 48,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'ຍັງບໍ່ມີຄຳເຫັນ',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...task.comments.map((comment) => _buildCommentItem(comment)),
            const SizedBox(height: 16),
            _buildAddCommentSection(task),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentItem(TaskComment comment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                child: Text(
                  // ใช้ userName แทน authorName
                  comment.userName.isNotEmpty ? comment.userName[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // ใช้ userName แทน authorName
                      comment.userName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formatDateTime(comment.createdAt),
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            // ใช้ comment แทน content
            comment.comment,
            style: AppTextStyles.bodyMedium.copyWith(
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCommentSection(TaskModel task) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ເພີ່ມຄຳເຫັນ',
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _commentController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'ໃສ່ຄຳເຫັນຂອງທ່ານ...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _addComment(task),
            icon: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send, size: 16),
            label: Text(_isLoading ? 'ກຳລັງສົ່ງ...' : 'ສົ່ງຄຳເຫັນ'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(TaskModel task) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          onPressed: () => _markAsCompleted(task),
          heroTag: "complete",
          backgroundColor: task.status == TaskStatus.completed 
              ? AppColors.success 
              : AppColors.primary,
          label: Text(
            task.status == TaskStatus.completed ? 'ສຳເລັດແລ້ວ' : 'ໝາຍວ່າສຳເລັດ',
            style: const TextStyle(color: Colors.white),
          ),
          icon: Icon(
            task.status == TaskStatus.completed ? Icons.check_circle : Icons.check,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityChip(TaskPriority priority) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getPriorityColor(priority).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _getPriorityColor(priority)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPriorityIcon(priority),
            size: 14,
            color: _getPriorityColor(priority),
          ),
          const SizedBox(width: 4),
          Text(
            _getPriorityText(priority),
            style: AppTextStyles.labelSmall.copyWith(
              color: _getPriorityColor(priority),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  void _updateTaskStatus(TaskModel task, TaskStatus newStatus) async {
    if (task.status == newStatus) return;
    
    final taskProvider = context.read<TaskProviderOffline>();
    await taskProvider.updateTaskStatus(task.id, newStatus);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ອັບເດດສະຖານະເປັນ ${_getStatusText(newStatus)} ແລ້ວ'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _updateProgress(TaskModel task, double newProgress) async {
    final taskProvider = context.read<TaskProviderOffline>();
    await taskProvider.updateTaskProgress(task.id, newProgress.clamp(0, 100));
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ອັບເດດຄວາມຄືບໜ້າເປັນ ${newProgress.round()}% ແລ້ວ'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _addComment(TaskModel task) async {
    if (_commentController.text.trim().isEmpty) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = context.read<AuthProviderOffline>();
      final taskProvider = context.read<TaskProviderOffline>();
      
      await taskProvider.addTaskComment(
        task.id,
        _commentController.text.trim(),
        authProvider.currentUser!.uid,
        authProvider.currentUser!.fullName,
      );
      
      _commentController.clear();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ເພີ່ມຄຳເຫັນສຳເລັດແລ້ວ'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ເກີດຂໍ້ຜິດພາດ: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _markAsCompleted(TaskModel task) async {
    if (task.status == TaskStatus.completed) return;
    
    final taskProvider = context.read<TaskProviderOffline>();
    await taskProvider.updateTaskStatus(task.id, TaskStatus.completed);
    await taskProvider.updateTaskProgress(task.id, 100);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ໝາຍວ່າງານສຳເລັດແລ້ວ'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ແກ້ໄຂງານ'),
        content: const Text('ຟີເຈີນີ້ຈະມາໃນເວີຊັນຕໍ່ໄປ'),
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

  // Helper methods for formatting
  String _formatDate(DateTime date) {
    try {
      final months = [
        'ມ.ກ.', 'ກ.ພ.', 'ມີ.ນ.', 'ມ.ສ.', 'ພ.ບ.', 'ມິ.ຖ.',
        'ກ.ລ.', 'ສ.ຫ.', 'ກ.ຍ.', 'ຕ.ລ.', 'ພ.ຈ.', 'ທ.ວ.'
      ];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatDateTime(DateTime date) {
    try {
      return '${_formatDate(date)} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
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
        return Icons.schedule;
      case TaskStatus.inProgress:
        return Icons.play_circle;
      case TaskStatus.completed:
        return Icons.check_circle;
      case TaskStatus.cancelled:
        return Icons.cancel;
    }
  }

  String _getStatusText(TaskStatus status) {
    switch (status) {
      case TaskStatus.pending:
        return 'ລໍຖ້າ';
      case TaskStatus.inProgress:
        return 'ກຳລັງເຮັດ';
      case TaskStatus.completed:
        return 'ສຳເລັດ';
      case TaskStatus.cancelled:
        return 'ຍົກເລີກ';
    }
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