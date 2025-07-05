import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/task_model.dart';
import '../models/user_model.dart';
import '../services/firestore_service.dart';

class TaskProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final Uuid _uuid = const Uuid();

  List<TaskModel> _allTasks = [];
  List<TaskModel> _userTasks = [];
  List<TaskModel> _createdTasks = [];
  List<UserModel> _teamMembers = [];
  Map<String, int> _taskStatistics = {};
  
  bool _isLoading = false;
  String? _errorMessage;
  TaskModel? _selectedTask;

  List<TaskModel> get allTasks => _allTasks;
  List<TaskModel> get userTasks => _userTasks;
  List<TaskModel> get createdTasks => _createdTasks;
  List<UserModel> get teamMembers => _teamMembers;
  Map<String, int> get taskStatistics => _taskStatistics;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TaskModel? get selectedTask => _selectedTask;

  List<TaskModel> get pendingTasks => _userTasks.where((task) => task.status == TaskStatus.pending).toList();
  List<TaskModel> get inProgressTasks => _userTasks.where((task) => task.status == TaskStatus.inProgress).toList();
  List<TaskModel> get completedTasks => _userTasks.where((task) => task.status == TaskStatus.completed).toList();
  List<TaskModel> get overdueTasks => _userTasks.where((task) => task.isOverdue).toList();
  List<TaskModel> get todayTasks => _userTasks.where((task) => task.isDueToday).toList();
  List<TaskModel> get tomorrowTasks => _userTasks.where((task) => task.isDueTomorrow).toList();

  void initializeTaskStreams(String userId) {
    _firestoreService.getTasksForUser(userId).listen((tasks) {
      _userTasks = tasks;
      notifyListeners();
    });

    _firestoreService.getTasksCreatedByUser(userId).listen((tasks) {
      _createdTasks = tasks;
      notifyListeners();
    });

    _firestoreService.getAllTasks().listen((tasks) {
      _allTasks = tasks;
      notifyListeners();
    });

    loadTaskStatistics(userId);
  }

  Future<void> loadTeamMembers() async {
    try {
      _setLoading(true);
      _teamMembers = await _firestoreService.getAllUsers();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTaskStatistics(String userId) async {
    try {
      _taskStatistics = await _firestoreService.getTaskStatistics(userId);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> createTask({
    required String title,
    required String description,
    required String createdBy,
    required String assignedTo,
    required DateTime dueDate,
    TaskPriority priority = TaskPriority.medium,
    String category = 'General',
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final task = TaskModel(
        id: _uuid.v4(),
        title: title,
        description: description,
        createdBy: createdBy,
        assignedTo: assignedTo,
        priority: priority,
        category: category,
        createdAt: DateTime.now(),
        dueDate: dueDate,
      );

      await _firestoreService.createTask(task);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTask(TaskModel task) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.updateTask(task);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteTask(String taskId) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.deleteTask(taskId);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTaskStatus(String taskId, TaskStatus status) async {
    try {
      _setLoading(true);
      _clearError();

      final task = _userTasks.firstWhere((t) => t.id == taskId);
      final updatedTask = task.copyWith(
        status: status,
        completedAt: status == TaskStatus.completed ? DateTime.now() : null,
        progress: status == TaskStatus.completed ? 100.0 : task.progress,
      );

      await _firestoreService.updateTask(updatedTask);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateTaskProgress(String taskId, double progress) async {
    try {
      _setLoading(true);
      _clearError();

      await _firestoreService.updateTaskProgress(taskId, progress);
      
      if (progress >= 100.0) {
        await updateTaskStatus(taskId, TaskStatus.completed);
      }
      
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addTaskComment(String taskId, String comment, String userId, String userName) async {
    try {
      _setLoading(true);
      _clearError();

      final taskComment = TaskComment(
        id: _uuid.v4(),
        userId: userId,
        userName: userName,
        comment: comment,
        createdAt: DateTime.now(),
      );

      await _firestoreService.addTaskComment(taskId, taskComment);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void setSelectedTask(TaskModel? task) {
    _selectedTask = task;
    notifyListeners();
  }

  Future<TaskModel?> getTaskById(String taskId) async {
    try {
      return await _firestoreService.getTaskById(taskId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  List<TaskModel> getTasksByStatus(TaskStatus status) {
    return _userTasks.where((task) => task.status == status).toList();
  }

  List<TaskModel> getTasksByPriority(TaskPriority priority) {
    return _userTasks.where((task) => task.priority == priority).toList();
  }

  List<TaskModel> searchTasks(String query) {
    if (query.isEmpty) return _userTasks;
    
    return _userTasks.where((task) =>
        task.title.toLowerCase().contains(query.toLowerCase()) ||
        task.description.toLowerCase().contains(query.toLowerCase()) ||
        task.category.toLowerCase().contains(query.toLowerCase())).toList();
  }

  List<TaskModel> filterTasks({
    TaskStatus? status,
    TaskPriority? priority,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    List<TaskModel> filtered = List.from(_userTasks);

    if (status != null) {
      filtered = filtered.where((task) => task.status == status).toList();
    }

    if (priority != null) {
      filtered = filtered.where((task) => task.priority == priority).toList();
    }

    if (category != null && category.isNotEmpty) {
      filtered = filtered.where((task) => task.category == category).toList();
    }

    if (startDate != null) {
      filtered = filtered.where((task) => task.dueDate.isAfter(startDate)).toList();
    }

    if (endDate != null) {
      filtered = filtered.where((task) => task.dueDate.isBefore(endDate)).toList();
    }

    return filtered;
  }

  void sortTasks(String sortBy) {
    switch (sortBy) {
      case 'dueDate':
        _userTasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
      case 'priority':
        _userTasks.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case 'status':
        _userTasks.sort((a, b) => a.status.index.compareTo(b.status.index));
        break;
      case 'title':
        _userTasks.sort((a, b) => a.title.compareTo(b.title));
        break;
      case 'createdAt':
        _userTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }
}