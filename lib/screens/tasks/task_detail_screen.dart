import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../utils/constants.dart';
import '../../utils/date_formatter.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/priority_badge.dart';
import '../../widgets/status_badge.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final TaskService _taskService = TaskService();
  Task? _task;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final taskId = ModalRoute.of(context)?.settings.arguments as String?;
    if (taskId != null) {
      _loadTaskDetail(taskId);
    }
  }

  Future<void> _loadTaskDetail(String id) async {
    final task = await _taskService.getTaskById(id);
    setState(() {
      _task = task;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết công việc'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_task != null)
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              onPressed: () {
                Navigator.pushNamed(context, '/task-edit', arguments: _task!.id);
              },
            ),
        ],
      ),
      body: _isLoading
          ? const LoadingView()
          : _task == null
              ? const Center(child: Text('Không tìm thấy công việc'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          StatusBadge(status: _task!.status),
                          PriorityBadge(priority: _task!.priority),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _task!.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Mô tả công việc:',
                        style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _task!.description,
                        style: const TextStyle(fontSize: 15, color: AppColors.textPrimary, height: 1.4),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          const Icon(Icons.event, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Text('Hạn chót: ${DateFormatter.formatDate(_task!.dueDate)}'),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/assign-task', arguments: _task!.id);
                              },
                              icon: const Icon(Icons.person_add_outlined, color: AppColors.primary),
                              label: const Text('Phân công', style: TextStyle(color: AppColors.primary)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/task-sharing', arguments: _task!.id);
                              },
                              icon: const Icon(Icons.share_outlined, color: AppColors.primary),
                              label: const Text('Chia sẻ', style: TextStyle(color: AppColors.primary)),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppColors.primary),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}
