import '../models/task_share.dart';

class TaskShareService {
  final List<TaskShare> _shares = [];

  Future<void> shareTask(TaskShare share) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _shares.add(share);
  }

  Future<List<TaskShare>> getSharesForTask(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _shares.where((s) => s.taskId == taskId).toList();
  }
}
