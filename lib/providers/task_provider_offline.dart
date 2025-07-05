import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';

class TaskProviderOffline extends ChangeNotifier {
  List<TaskModel> _allTasks = [];
  List<UserModel> _teamMembers = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _taskStatistics = {};

  List<TaskModel> get allTasks => _allTasks;
  List<UserModel> get teamMembers => _teamMembers;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // เพิ่ม getters ที่ขาดหายไป
  Map<String, dynamic> get taskStatistics => _taskStatistics;
  
  List<TaskModel> get pendingTasks => 
      _allTasks.where((task) => task.status == TaskStatus.pending).toList();
  
  List<TaskModel> get inProgressTasks => 
      _allTasks.where((task) => task.status == TaskStatus.inProgress).toList();
  
  List<TaskModel> get completedTasks => 
      _allTasks.where((task) => task.status == TaskStatus.completed).toList();
  
  List<TaskModel> get todayTasks {
    final today = DateTime.now();
    return _allTasks.where((task) {
      final taskDate = task.dueDate;
      return taskDate.year == today.year &&
             taskDate.month == today.month &&
             taskDate.day == today.day;
    }).toList();
  }
  
  List<TaskModel> get overdueTasks {
    final now = DateTime.now();
    return _allTasks.where((task) => 
        task.dueDate.isBefore(now) && 
        task.status != TaskStatus.completed &&
        task.status != TaskStatus.cancelled
    ).toList();
  }

  TaskProviderOffline() {
    _initializeDemoData();
  }

  // เพิ่มเมธอดที่ขาดหายไป
  Future<void> initializeTaskStreams(String userId) async {
    try {
      _setLoading(true);
      debugPrint('🔄 Initializing task streams for user: $userId');
      
      // จำลองการโหลดข้อมูล
      await Future.delayed(const Duration(milliseconds: 500));
      
      // คำนวณสถิติ
      await _calculateStatistics();
      
      debugPrint('✅ Task streams initialized');
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTaskStatistics(String userId) async {
    try {
      _setLoading(true);
      debugPrint('🔄 Loading task statistics for user: $userId');
      
      await Future.delayed(const Duration(milliseconds: 300));
      await _calculateStatistics();
      
      debugPrint('✅ Task statistics loaded');
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // เมธอดช่วยในการคำนวณสถิติ
  Future<void> _calculateStatistics() async {
    final stats = getTaskStatistics();
    
    _taskStatistics = {
      'totalTasks': stats['total'] ?? 0,
      'pendingTasks': stats['pending'] ?? 0,
      'inProgressTasks': stats['inProgress'] ?? 0,
      'completedTasks': stats['completed'] ?? 0,
      'cancelledTasks': stats['cancelled'] ?? 0,
      'highPriorityTasks': stats['high'] ?? 0,
      'mediumPriorityTasks': stats['medium'] ?? 0,
      'lowPriorityTasks': stats['low'] ?? 0,
      'overdueTasks': overdueTasks.length,
      'todayTasks': todayTasks.length,
      'completionRate': _calculateCompletionRate(),
      'averageProgress': _calculateAverageProgress(),
    };
  }

  double _calculateCompletionRate() {
    if (_allTasks.isEmpty) return 0.0;
    final completed = _allTasks.where((task) => task.status == TaskStatus.completed).length;
    return (completed / _allTasks.length) * 100;
  }

  double _calculateAverageProgress() {
    if (_allTasks.isEmpty) return 0.0;
    final totalProgress = _allTasks.fold<double>(0, (sum, task) => sum + task.progress);
    return totalProgress / _allTasks.length;
  }

  void _initializeDemoData() {
    debugPrint('🔄 Initializing demo data...');
    
    // สร้าง team members
    _teamMembers = [
      UserModel(
        uid: 'admin-offline',
        email: 'admin@easywork.com',
        firstName: 'ທ້າວ',
        lastName: 'ແອດມິນ',
        role: 'admin',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      ),
      UserModel(
        uid: 'john-offline',
        email: 'john@easywork.com',
        firstName: 'John',
        lastName: 'Doe',
        role: 'employee',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      ),
      UserModel(
        uid: 'mary-offline',
        email: 'mary@easywork.com',
        firstName: 'Mary',
        lastName: 'Smith',
        role: 'employee',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      ),
      UserModel(
        uid: 'demo-offline',
        email: 'demo@easywork.com',
        firstName: 'Demo',
        lastName: 'User',
        role: 'employee',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      ),
    ];

    // สร้าง demo tasks
    _allTasks = [
      TaskModel(
        id: 'task-1',
        title: 'ອອກແບບ UI สำหรับ Login Screen',
        description: 'ສ້າງ mockup ແລະ prototype ສຳລັບໜ້າ login ຂອງແອບ',
        assignedTo: 'john-offline',
        createdBy: 'admin-offline',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        priority: TaskPriority.high,
        status: TaskStatus.inProgress,
        progress: 65,
        category: 'Design',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        comments: [
          TaskComment(
            id: 'comment-1',
            userId: 'admin-offline',
            userName: 'ທ້າວ ແອດມິນ',
            comment: 'ໄດ້ດູແລ້ວ ໃຫ້ປັບປຸງສີໃຫ້ສົດໃສກວ່ານີ້',
            createdAt: DateTime.now().subtract(const Duration(hours: 5)),
          ),
          TaskComment(
            id: 'comment-2',
            userId: 'john-offline',
            userName: 'John Doe',
            comment: 'ຮັບຊາບແລ້ວ ຈະແກ້ໄຂໃນມື້ອື່ນ',
            createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        ],
      ),
      TaskModel(
        id: 'task-2',
        title: 'ພັດທະນາ API Authentication',
        description: 'ສ້າງ API ສຳລັບການ login, logout ແລະ register',
        assignedTo: 'mary-offline',
        createdBy: 'admin-offline',
        dueDate: DateTime.now().add(const Duration(days: 5)),
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        progress: 0,
        category: 'Development',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        comments: [],
      ),
      TaskModel(
        id: 'task-3',
        title: 'ທົດສອບລະບົບຢ່າງລະອຽດ',
        description: 'ທົດສອບ features ທັງໝົດ ແລະ ຂຽນ test cases',
        assignedTo: 'demo-offline',
        createdBy: 'admin-offline',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        priority: TaskPriority.medium,
        status: TaskStatus.pending,
        progress: 0,
        category: 'Testing',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        comments: [],
      ),
      TaskModel(
        id: 'task-4',
        title: 'ສ້າງ Documentation',
        description: 'ຂຽນ user manual ແລະ technical documentation',
        assignedTo: 'john-offline',
        createdBy: 'admin-offline',
        dueDate: DateTime.now().add(const Duration(days: 10)),
        priority: TaskPriority.low,
        status: TaskStatus.completed,
        progress: 100,
        category: 'Documentation',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        comments: [
          TaskComment(
            id: 'comment-3',
            userId: 'john-offline',
            userName: 'John Doe',
            comment: 'Documentation ສຳເລັດແລ້ວ',
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
        ],
      ),
      TaskModel(
        id: 'task-5',
        title: 'ປັບປຸງ Performance',
        description: 'ເພີ່ມຄວາມເລັວ ແລະ ປັບປຸງ loading time',
        assignedTo: 'mary-offline',
        createdBy: 'admin-offline',
        dueDate: DateTime.now().add(const Duration(days: 14)),
        priority: TaskPriority.medium,
        status: TaskStatus.inProgress,
        progress: 30,
        category: 'Optimization',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        comments: [],
      ),
      // เพิ่ม task ที่เลยกำหนดเพื่อทดสอบ overdue
      TaskModel(
        id: 'task-6',
        title: 'งานที่เลยกำหนด',
        description: 'งานทดสอบที่เลยกำหนดแล้ว',
        assignedTo: 'demo-offline',
        createdBy: 'admin-offline',
        dueDate: DateTime.now().subtract(const Duration(days: 2)),
        priority: TaskPriority.high,
        status: TaskStatus.pending,
        progress: 20,
        category: 'Testing',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        comments: [],
      ),
      // เพิ่ม task สำหรับวันนี้
      TaskModel(
        id: 'task-7',
        title: 'งานวันนี้',
        description: 'งานที่ต้องทำให้เสร็จวันนี้',
        assignedTo: 'john-offline',
        createdBy: 'admin-offline',
        dueDate: DateTime.now(),
        priority: TaskPriority.medium,
        status: TaskStatus.inProgress,
        progress: 50,
        category: 'Development',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        comments: [],
      ),
    ];

    debugPrint('✅ Demo data initialized: ${_allTasks.length} tasks, ${_teamMembers.length} team members');
    
    // คำนวณสถิติเบื้องต้น
    _calculateStatistics();
    notifyListeners();
  }

  // ดึงงานทั้งหมด
  List<TaskModel> get userTasks => _allTasks;

  // ดึงงานของ user คนนั้นๆ
  List<TaskModel> getTasksForUser(String userId) {
    return _allTasks.where((task) => 
        task.assignedTo == userId || task.createdBy == userId
    ).toList();
  }

  // ดึงงานตาม status
  List<TaskModel> getTasksByStatus(TaskStatus status) {
    return _allTasks.where((task) => task.status == status).toList();
  }

  // ดึงงานตาม priority
  List<TaskModel> getTasksByPriority(TaskPriority priority) {
    return _allTasks.where((task) => task.priority == priority).toList();
  }

  // ดึงงานเดี่ยว
  TaskModel? getTaskById(String id) {
    try {
      return _allTasks.firstWhere((task) => task.id == id);
    } catch (e) {
      return null;
    }
  }

  // สร้างงานใหม่
  Future<bool> createTask({
    required String title,
    required String description,
    required String createdBy,
    required String assignedTo,
    required DateTime dueDate,
    required TaskPriority priority,
    String? category,
  }) async {
    try {
      _setLoading(true);
      
      // จำลองการ save
      await Future.delayed(const Duration(milliseconds: 500));

      final newTask = TaskModel(
        id: 'task-${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        description: description,
        assignedTo: assignedTo,
        createdBy: createdBy,
        dueDate: dueDate,
        priority: priority,
        status: TaskStatus.pending,
        progress: 0,
        category: category ?? 'General',
        createdAt: DateTime.now(),
        comments: [],
      );

      _allTasks.insert(0, newTask); // เพิ่มไว้ด้านบน
      await _calculateStatistics(); // อัปเดตสถิติ
      debugPrint('✅ Task created: ${newTask.title}');
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // อัปเดตสถานะงาน
  Future<bool> updateTaskStatus(String taskId, TaskStatus newStatus) async {
    try {
      _setLoading(true);
      await Future.delayed(const Duration(milliseconds: 300));

      final taskIndex = _allTasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _allTasks[taskIndex] = _allTasks[taskIndex].copyWith(status: newStatus);
        
        // ถ้าเปลี่ยนเป็น completed ให้ progress เป็น 100
        if (newStatus == TaskStatus.completed) {
          _allTasks[taskIndex] = _allTasks[taskIndex].copyWith(progress: 100);
        }
        
        await _calculateStatistics(); // อัปเดตสถิติ
        debugPrint('✅ Task status updated: $taskId -> $newStatus');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // อัปเดตความคืบหน้า
  Future<bool> updateTaskProgress(String taskId, double progress) async {
    try {
      _setLoading(true);
      await Future.delayed(const Duration(milliseconds: 300));

      final taskIndex = _allTasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        _allTasks[taskIndex] = _allTasks[taskIndex].copyWith(progress: progress);
        
        // ถ้า progress เป็น 100 ให้เปลี่ยนสถานะเป็น completed
        if (progress >= 100) {
          _allTasks[taskIndex] = _allTasks[taskIndex].copyWith(
            progress: 100,
            status: TaskStatus.completed,
          );
        }
        
        await _calculateStatistics(); // อัปเดตสถิติ
        debugPrint('✅ Task progress updated: $taskId -> $progress%');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // เพิ่มคอมเมนต์
  Future<bool> addTaskComment(
    String taskId,
    String comment,
    String userId,
    String userName,
  ) async {
    try {
      _setLoading(true);
      await Future.delayed(const Duration(milliseconds: 300));

      final taskIndex = _allTasks.indexWhere((task) => task.id == taskId);
      if (taskIndex != -1) {
        final newComment = TaskComment(
          id: 'comment-${DateTime.now().millisecondsSinceEpoch}',
          userId: userId,
          userName: userName,
          comment: comment,
          createdAt: DateTime.now(),
        );

        final updatedComments = List<TaskComment>.from(_allTasks[taskIndex].comments);
        updatedComments.add(newComment);
        
        _allTasks[taskIndex] = _allTasks[taskIndex].copyWith(comments: updatedComments);
        
        debugPrint('✅ Comment added to task: $taskId');
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ลบงาน
  Future<bool> deleteTask(String taskId) async {
    try {
      _setLoading(true);
      await Future.delayed(const Duration(milliseconds: 300));

      _allTasks.removeWhere((task) => task.id == taskId);
      await _calculateStatistics(); // อัปเดตสถิติ
      debugPrint('✅ Task deleted: $taskId');
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // โหลดข้อมูลทีม
  Future<void> loadTeamMembers() async {
    try {
      _setLoading(true);
      await Future.delayed(const Duration(milliseconds: 300));
      
      // ข้อมูลทีมโหลดจาก constructor แล้ว
      debugPrint('✅ Team members loaded: ${_teamMembers.length} members');
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // รีเฟรชข้อมูล
  Future<void> refreshTasks() async {
    try {
      _setLoading(true);
      await Future.delayed(const Duration(seconds: 1));
      
      await _calculateStatistics(); // อัปเดตสถิติ
      debugPrint('✅ Tasks refreshed');
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // ค้นหางาน
  List<TaskModel> searchTasks(String query) {
    if (query.isEmpty) return _allTasks;
    
    return _allTasks.where((task) =>
        task.title.toLowerCase().contains(query.toLowerCase()) ||
        task.description.toLowerCase().contains(query.toLowerCase()) ||
        (task.category != null && task.category!.toLowerCase().contains(query.toLowerCase()))
    ).toList();
  }

  // สถิติต่างๆ
  Map<String, int> getTaskStatistics() {
    return {
      'total': _allTasks.length,
      'pending': _allTasks.where((task) => task.status == TaskStatus.pending).length,
      'inProgress': _allTasks.where((task) => task.status == TaskStatus.inProgress).length,
      'completed': _allTasks.where((task) => task.status == TaskStatus.completed).length,
      'cancelled': _allTasks.where((task) => task.status == TaskStatus.cancelled).length,
      'high': _allTasks.where((task) => task.priority == TaskPriority.high).length,
      'medium': _allTasks.where((task) => task.priority == TaskPriority.medium).length,
      'low': _allTasks.where((task) => task.priority == TaskPriority.low).length,
    };
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    debugPrint('❌ TaskProvider Error: $error');
    notifyListeners();
  }

  // Reset data (สำหรับ logout)
  void reset() {
    debugPrint('🔄 Resetting TaskProvider...');
    _initializeDemoData(); // โหลด demo data ใหม่
  }
}