enum TaskStatus { pending, inProgress, completed }

enum TaskPriority { low, medium, high }

class Task {
  final String id;
  final String title;
  final String description;
  final TaskStatus status;
  final TaskPriority priority;
  final DateTime dueDate;
  final String? assignedToUserId;
  final String createdByUserId;
  final DateTime createdAt;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.status = TaskStatus.pending,
    this.priority = TaskPriority.medium,
    required this.dueDate,
    this.assignedToUserId,
    required this.createdByUserId,
    required this.createdAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      status: TaskStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TaskStatus.pending,
      ),
      priority: TaskPriority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => TaskPriority.medium,
      ),
      dueDate: DateTime.parse(json['dueDate'] as String),
      assignedToUserId: json['assignedToUserId'] as String?,
      createdByUserId: json['createdByUserId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status.name,
      'priority': priority.name,
      'dueDate': dueDate.toIso8601String(),
      'assignedToUserId': assignedToUserId,
      'createdByUserId': createdByUserId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
