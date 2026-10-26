enum SharePermission { readOnly, edit }

class TaskShare {
  final String id;
  final String taskId;
  final String sharedWithUserId;
  final SharePermission permission;
  final DateTime createdAt;

  TaskShare({
    required this.id,
    required this.taskId,
    required this.sharedWithUserId,
    this.permission = SharePermission.readOnly,
    required this.createdAt,
  });

  factory TaskShare.fromJson(Map<String, dynamic> json) {
    return TaskShare(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      sharedWithUserId: json['sharedWithUserId'] as String,
      permission: SharePermission.values.firstWhere(
        (e) => e.name == json['permission'],
        orElse: () => SharePermission.readOnly,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskId': taskId,
      'sharedWithUserId': sharedWithUserId,
      'permission': permission.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
