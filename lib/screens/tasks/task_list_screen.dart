import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/task_provider_offline.dart';  // ✅ เปลี่ยนเป็น offline
import '../../models/task_model.dart';
import '../../widgets/task/task_card.dart';
import '../../widgets/common/custom_button.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  TaskStatus? _filterStatus;
  TaskPriority? _filterPriority;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          _buildTabBar(),
          Expanded(child: _buildTaskList()),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
            AppStrings.myTasks,
            style: AppTextStyles.h4.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _showFilterDialog,
            icon: Stack(
              children: [
                const Icon(
                  Icons.filter_list,
                  color: AppColors.textPrimary,
                ),
                if (_hasActiveFilters())
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.go('/create-task'),  // ✅ แก้ route
            icon: const Icon(
              Icons.add,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: AppStrings.searchTasks,
          prefixIcon: const Icon(Icons.search, color: AppColors.textLight),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                  icon: const Icon(Icons.clear, color: AppColors.textLight),
                )
              : null,
          filled: true,
          fillColor: AppColors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.textSecondary,
        indicator: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: AppTextStyles.labelMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelMedium,
        tabs: const [
          Tab(text: 'ທັງໝົດ'),
          Tab(text: 'ລໍຖ້າ'),
          Tab(text: 'ກຳລັງເຮັດ'),
          Tab(text: 'ສຳເລັດ'),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return Consumer<TaskProviderOffline>(  // ✅ เปลี่ยนเป็น offline
      builder: (context, taskProvider, child) {
        return TabBarView(
          controller: _tabController,
          children: [
            _buildFilteredTaskList(taskProvider.userTasks),
            _buildFilteredTaskList(taskProvider.pendingTasks),
            _buildFilteredTaskList(taskProvider.inProgressTasks),
            _buildFilteredTaskList(taskProvider.completedTasks),
          ],
        );
      },
    );
  }

  Widget _buildFilteredTaskList(List<TaskModel> tasks) {
    List<TaskModel> filteredTasks = tasks;

    if (_searchQuery.isNotEmpty) {
      filteredTasks = filteredTasks
          .where((task) =>
              task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              task.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    if (_filterStatus != null) {
      filteredTasks = filteredTasks
          .where((task) => task.status == _filterStatus)
          .toList();
    }

    if (_filterPriority != null) {
      filteredTasks = filteredTasks
          .where((task) => task.priority == _filterPriority)
          .toList();
    }

    if (filteredTasks.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Refresh tasks in offline mode
        final taskProvider = context.read<TaskProviderOffline>();
        await taskProvider.loadTeamMembers();
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: filteredTasks.length,
        itemBuilder: (context, index) {
          final task = filteredTasks[index];
          return TaskCard(
            task: task,
            onTap: () => context.go('/task/${task.id}'),
          );
        },
      ),
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.task_outlined,
                size: 40,
                color: AppColors.textLight,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'ບໍ່ມີວຽກງານ',
              style: AppTextStyles.h5.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'ສ້າງວຽກງານໃໝ່ເພື່ອເລີ່ມຕົ້ນ',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textLight,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'ສ້າງວຽກງານໃໝ່',
              onPressed: () => context.go('/create-task'),  // ✅ แก้ route
              icon: Icons.add,
              type: ButtonType.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              AppStrings.filterTasks,
              style: AppTextStyles.h5,
            ),
            const SizedBox(height: 20),
            _buildFilterSection(
              'ສະຖານະ',
              [
                _buildFilterChip('ທັງໝົດ', null, _filterStatus == null),
                _buildFilterChip('ລໍຖ້າ', TaskStatus.pending, _filterStatus == TaskStatus.pending),
                _buildFilterChip('ກຳລັງເຮັດ', TaskStatus.inProgress, _filterStatus == TaskStatus.inProgress),
                _buildFilterChip('ສຳເລັດ', TaskStatus.completed, _filterStatus == TaskStatus.completed),
              ],
            ),
            const SizedBox(height: 20),
            _buildFilterSection(
              'ຄວາມສຳຄັນ',
              [
                _buildFilterChip('ທັງໝົດ', null, _filterPriority == null),
                _buildFilterChip('ສູງ', TaskPriority.high, _filterPriority == TaskPriority.high),
                _buildFilterChip('ປານກາງ', TaskPriority.medium, _filterPriority == TaskPriority.medium),
                _buildFilterChip('ຕ່ຳ', TaskPriority.low, _filterPriority == TaskPriority.low),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'ລ້າງ',
                    onPressed: () {
                      setState(() {
                        _filterStatus = null;
                        _filterPriority = null;
                      });
                      Navigator.pop(context);
                    },
                    type: ButtonType.outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    text: 'ນຳໃຊ້',
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<Widget> chips,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: chips,
        ),
      ],
    );
  }

  Widget _buildFilterChip<T>(String label, T? value, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (T == TaskStatus) {
          setState(() => _filterStatus = selected ? value as TaskStatus? : null);
        } else if (T == TaskPriority) {
          setState(() => _filterPriority = selected ? value as TaskPriority? : null);
        }
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.labelMedium.copyWith(
        color: isSelected ? AppColors.primary : AppColors.textSecondary,
      ),
    );
  }

  bool _hasActiveFilters() {
    return _filterStatus != null || _filterPriority != null;
  }
}