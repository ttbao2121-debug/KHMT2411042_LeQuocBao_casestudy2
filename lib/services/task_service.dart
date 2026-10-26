import '../models/task.dart';

class TaskService {
  final List<Task> _tasks = [
    Task(
      id: 't1',
      title: 'Thiết kế UI màn hình Đăng nhập',
      description: 'Áp dụng phối màu chuẩn #FB8C00 và gradient background.',
      status: TaskStatus.completed,
      priority: TaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 1)),
      createdByUserId: 'u1',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    Task(
      id: 't2',
      title: 'Xây dựng cấu trúc thư mục ứng dụng',
      description: 'Tạo cấu trúc các thư mục models, services, screens, widgets, utils.',
      status: TaskStatus.inProgress,
      priority: TaskPriority.high,
      dueDate: DateTime.now().add(const Duration(days: 2)),
      createdByUserId: 'u1',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Task(
      id: 't3',
      title: 'Tích hợp API công việc',
      description: 'Kết nối ứng dụng với Backend API để đồng bộ công việc.',
      status: TaskStatus.pending,
      priority: TaskPriority.medium,
      dueDate: DateTime.now().add(const Duration(days: 5)),
      createdByUserId: 'u1',
      createdAt: DateTime.now(),
    ),
  ];

  Future<List<Task>> getTasks() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_tasks);
  }

  Future<Task?> getTaskById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _tasks.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> createTask(Task task) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _tasks.add(task);
  }

  Future<void> updateTask(Task updatedTask) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
    }
  }

  Future<void> deleteTask(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _tasks.removeWhere((t) => t.id == id);
  }
}
