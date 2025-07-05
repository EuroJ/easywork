import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const String usersCollection = 'users';
  static const String tasksCollection = 'tasks';

  Future<void> createUser(UserModel user) async {
    await _db.collection(usersCollection).doc(user.uid).set(user.toJson());
  }

  Future<UserModel?> getUserById(String uid) async {
    final doc = await _db.collection(usersCollection).doc(uid).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> updateUser(UserModel user) async {
    await _db.collection(usersCollection).doc(user.uid).update(user.toJson());
  }

  Future<void> updateUserLastLogin(String uid) async {
    await _db.collection(usersCollection).doc(uid).update({
      'lastLoginAt': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection(usersCollection).doc(uid).delete();
  }

  Future<List<UserModel>> getAllUsers() async {
    final querySnapshot = await _db
        .collection(usersCollection)
        .where('isActive', isEqualTo: true)
        .get();

    return querySnapshot.docs
        .map((doc) => UserModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> createTask(TaskModel task) async {
    await _db.collection(tasksCollection).doc(task.id).set(task.toJson());
  }

  Future<TaskModel?> getTaskById(String taskId) async {
    final doc = await _db.collection(tasksCollection).doc(taskId).get();
    if (doc.exists) {
      return TaskModel.fromJson(doc.data()!);
    }
    return null;
  }

  Future<void> updateTask(TaskModel task) async {
    await _db.collection(tasksCollection).doc(task.id).update(task.toJson());
  }

  Future<void> deleteTask(String taskId) async {
    await _db.collection(tasksCollection).doc(taskId).delete();
  }

  Stream<List<TaskModel>> getTasksForUser(String userId) {
    return _db
        .collection(tasksCollection)
        .where('assignedTo', isEqualTo: userId)
        .orderBy('dueDate', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromJson(doc.data()))
            .toList());
  }

  Stream<List<TaskModel>> getTasksCreatedByUser(String userId) {
    return _db
        .collection(tasksCollection)
        .where('createdBy', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromJson(doc.data()))
            .toList());
  }

  Stream<List<TaskModel>> getAllTasks() {
    return _db
        .collection(tasksCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TaskModel.fromJson(doc.data()))
            .toList());
  }

  Future<List<TaskModel>> getTasksByStatus(TaskStatus status) async {
    final querySnapshot = await _db
        .collection(tasksCollection)
        .where('status', isEqualTo: status.index)
        .orderBy('dueDate', descending: false)
        .get();

    return querySnapshot.docs
        .map((doc) => TaskModel.fromJson(doc.data()))
        .toList();
  }

  Future<List<TaskModel>> getTasksByPriority(TaskPriority priority) async {
    final querySnapshot = await _db
        .collection(tasksCollection)
        .where('priority', isEqualTo: priority.index)
        .orderBy('dueDate', descending: false)
        .get();

    return querySnapshot.docs
        .map((doc) => TaskModel.fromJson(doc.data()))
        .toList();
  }

  Future<List<TaskModel>> getOverdueTasks() async {
    final now = DateTime.now();
    final querySnapshot = await _db
        .collection(tasksCollection)
        .where('dueDate', isLessThan: now.millisecondsSinceEpoch)
        .where('status', whereIn: [TaskStatus.pending.index, TaskStatus.inProgress.index])
        .get();

    return querySnapshot.docs
        .map((doc) => TaskModel.fromJson(doc.data()))
        .toList();
  }

  Future<List<TaskModel>> getTodayTasks() async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final querySnapshot = await _db
        .collection(tasksCollection)
        .where('dueDate', isGreaterThanOrEqualTo: startOfDay.millisecondsSinceEpoch)
        .where('dueDate', isLessThan: endOfDay.millisecondsSinceEpoch)
        .get();

    return querySnapshot.docs
        .map((doc) => TaskModel.fromJson(doc.data()))
        .toList();
  }

  Future<void> addTaskComment(String taskId, TaskComment comment) async {
    final taskRef = _db.collection(tasksCollection).doc(taskId);
    await _db.runTransaction((transaction) async {
      final taskDoc = await transaction.get(taskRef);
      if (taskDoc.exists) {
        final task = TaskModel.fromJson(taskDoc.data()!);
        final updatedComments = [...task.comments, comment];
        transaction.update(taskRef, {
          'comments': updatedComments.map((c) => c.toJson()).toList(),
        });
      }
    });
  }

  Future<void> updateTaskProgress(String taskId, double progress) async {
    await _db.collection(tasksCollection).doc(taskId).update({
      'progress': progress,
    });
  }

  Future<void> markTaskAsCompleted(String taskId) async {
    await _db.collection(tasksCollection).doc(taskId).update({
      'status': TaskStatus.completed.index,
      'completedAt': DateTime.now().millisecondsSinceEpoch,
      'progress': 100.0,
    });
  }

  Future<Map<String, int>> getTaskStatistics(String userId) async {
    final tasks = await _db
        .collection(tasksCollection)
        .where('assignedTo', isEqualTo: userId)
        .get();

    int totalTasks = tasks.docs.length;
    int completedTasks = 0;
    int pendingTasks = 0;
    int inProgressTasks = 0;
    int overdueTasks = 0;

    final now = DateTime.now();

    for (var doc in tasks.docs) {
      final task = TaskModel.fromJson(doc.data());
      
      switch (task.status) {
        case TaskStatus.completed:
          completedTasks++;
          break;
        case TaskStatus.pending:
          pendingTasks++;
          break;
        case TaskStatus.inProgress:
          inProgressTasks++;
          break;
        case TaskStatus.cancelled:
          break;
      }

      if (task.isOverdue && task.status != TaskStatus.completed) {
        overdueTasks++;
      }
    }

    return {
      'total': totalTasks,
      'completed': completedTasks,
      'pending': pendingTasks,
      'inProgress': inProgressTasks,
      'overdue': overdueTasks,
    };
  }
}