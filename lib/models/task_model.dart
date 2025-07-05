enum TaskStatus {
  pending,
  inProgress,
  completed,
  cancelled,
}

enum TaskPriority {
  low,
  medium,
  high,
}

class TaskModel {
  final String id;
  final String title;
  final String description;
  final String createdBy;
  final String assignedTo;
  final TaskStatus status;
  final TaskPriority priority;
  final String category;
  final DateTime createdAt;
  final DateTime dueDate;
  final DateTime? completedAt;
  final List<Map<String, dynamic>> attachments;
  final List<TaskComment> comments;
  final double progress;

  TaskModel({
    required this.id,
    required this.title,
    required this.description,
    required this.createdBy,
    required this.assignedTo,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    this.category = 'General',
    required this.createdAt,
    required this.dueDate,
    this.completedAt,
    this.attachments = const [],
    this.comments = const [],
    this.progress = 0.0,
  });

  bool get isOverdue {
    if (status == TaskStatus.completed) return false;
    return DateTime.now().isAfter(dueDate);
  }

  bool get isDueToday {
    final now = DateTime.now();
    return dueDate.year == now.year &&
        dueDate.month == now.month &&
        dueDate.day == now.day;
  }

  bool get isDueTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate.year == tomorrow.year &&
        dueDate.month == tomorrow.month &&
        dueDate.day == tomorrow.day;
  }

  String get statusText {
    switch (status) {
      case TaskStatus.pending:
        return 'ລໍຖ້າ';
      case TaskStatus.inProgress:
        return 'ກຳລັງດຳເນີນ';
      case TaskStatus.completed:
        return 'ສຳເລັດ';
      case TaskStatus.cancelled:
        return 'ຍົກເລີກ';
    }
  }

  String get priorityText {
    switch (priority) {
      case TaskPriority.low:
        return 'ຕ່ຳ';
      case TaskPriority.medium:
        return 'ປານກາງ';
      case TaskPriority.high:
        return 'ສູງ';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'status': status.index,
      'priority': priority.index,
      'category': category,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'attachments': attachments,
      'comments': comments.map((c) => c.toJson()).toList(),
      'progress': progress,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      createdBy: json['createdBy'] ?? '',
      assignedTo: json['assignedTo'] ?? '',
      status: TaskStatus.values[json['status'] ?? 0],
      priority: TaskPriority.values[json['priority'] ?? 1],
      category: json['category'] ?? 'General',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
      dueDate: DateTime.fromMillisecondsSinceEpoch(json['dueDate'] ?? 0),
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'])
          : null,
      attachments: (json['attachments'] as List?)
              ?.map((a) => Map<String, dynamic>.from(a))
              .toList() ??
          [],
      comments: (json['comments'] as List?)
              ?.map((c) => TaskComment.fromJson(c))
              .toList() ??
          [],
      progress: (json['progress'] ?? 0.0).toDouble(),
    );
  }

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    String? createdBy,
    String? assignedTo,
    TaskStatus? status,
    TaskPriority? priority,
    String? category,
    DateTime? createdAt,
    DateTime? dueDate,
    DateTime? completedAt,
    List<Map<String, dynamic>>? attachments,
    List<TaskComment>? comments,
    double? progress,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      assignedTo: assignedTo ?? this.assignedTo,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      completedAt: completedAt ?? this.completedAt,
      attachments: attachments ?? this.attachments,
      comments: comments ?? this.comments,
      progress: progress ?? this.progress,
    );
  }
}

class TaskComment {
  final String id;
  final String userId;
  final String userName;
  final String comment;
  final DateTime createdAt;

  TaskComment({
    required this.id,
    required this.userId,
    required this.userName,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'comment': comment,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      comment: json['comment'] ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] ?? 0),
    );
  }
}