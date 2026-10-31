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
    final rawStatus = (json['status'] as String?)?.toLowerCase() ?? 'todo';
    TaskStatus status;
    if (rawStatus == 'completed') {
      status = TaskStatus.completed;
    } else if (rawStatus == 'in_progress' || rawStatus == 'inprogress') {
      status = TaskStatus.inProgress;
    } else {
      status = TaskStatus.pending;
    }

    final rawPriority = (json['priority'] as String?)?.toLowerCase() ?? 'medium';
    TaskPriority priority;
    if (rawPriority == 'high') {
      priority = TaskPriority.high;
    } else if (rawPriority == 'low') {
      priority = TaskPriority.low;
    } else {
      priority = TaskPriority.medium;
    }

    String createdById = '';
    if (json['createdBy'] != null) {
      if (json['createdBy'] is Map) {
        createdById = (json['createdBy']['_id'] ?? json['createdBy']['id']) as String? ?? '';
      } else {
        createdById = json['createdBy'].toString();
      }
    }

    return Task(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      status: status,
      priority: priority,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate'].toString()) : DateTime.now(),
      createdByUserId: createdById,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt'].toString()) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    String statusStr = 'todo';
    if (status == TaskStatus.completed) statusStr = 'completed';
    if (status == TaskStatus.inProgress) statusStr = 'in_progress';

    return {
      'title': title,
      'description': description,
      'status': statusStr,
      'priority': priority.name,
      'dueDate': dueDate.toIso8601String(),
    };
  }
}
