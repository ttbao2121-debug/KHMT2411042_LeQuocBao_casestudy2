class TaskActivity {
  final String id;
  final String taskId;
  final String userId;
  final String action;
  final DateTime timestamp;

  TaskActivity({
    required this.id,
    required this.taskId,
    required this.userId,
    required this.action,
    required this.timestamp,
  });

  factory TaskActivity.fromJson(Map<String, dynamic> json) {
    return TaskActivity(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      userId: json['userId'] as String,
      action: json['action'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'userId': userId,
      'action': action,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
