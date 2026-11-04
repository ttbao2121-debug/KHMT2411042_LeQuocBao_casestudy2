import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/task_service.dart';
import '../../services/user_service.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_view.dart';

class AssignTaskScreen extends StatefulWidget {
  const AssignTaskScreen({super.key});

  @override
  State<AssignTaskScreen> createState() => _AssignTaskScreenState();
}

class _AssignTaskScreenState extends State<AssignTaskScreen> {
  final UserService _userService = UserService();
  final TaskService _taskService = TaskService();
  final TextEditingController _searchController = TextEditingController();

  String? _taskId;
  List<User> _searchResults = [];
  final Set<String> _selectedAssigneeIds = {};
  String? _primaryAssigneeId;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null) {
      _taskId = args;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    final results = await _userService.searchUsers(query.trim());
    setState(() {
      _searchResults = results;
    });
  }

  void _confirmAssignment() async {
    if (_taskId == null) return;
    if (_selectedAssigneeIds.isEmpty && _primaryAssigneeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn ít nhất 1 người phụ trách')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _taskService.assignTask(
        _taskId!,
        _selectedAssigneeIds.toList(),
        _primaryAssigneeId,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã giao việc thành công!'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception: ', '')),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Giao công việc'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm người dùng theo tên hoặc email...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Danh sách người dùng tìm thấy:',
              style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _searchResults.isEmpty
                  ? const Center(child: Text('Nhập từ khóa tìm kiếm người dùng'))
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        final isSelected = _selectedAssigneeIds.contains(user.id);
                        final isPrimary = _primaryAssigneeId == user.id;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                              child: Text(
                                user.name.isNotEmpty ? user.name[0] : 'U',
                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                              ),
                            ),
                            title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(user.email),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Checkbox(
                                  value: isSelected,
                                  activeColor: AppColors.primary,
                                  onChanged: (val) {
                                    setState(() {
                                      if (val == true) {
                                        _selectedAssigneeIds.add(user.id);
                                      } else {
                                        _selectedAssigneeIds.remove(user.id);
                                        if (_primaryAssigneeId == user.id) {
                                          _primaryAssigneeId = null;
                                        }
                                      }
                                    });
                                  },
                                ),
                                IconButton(
                                  icon: Icon(
                                    isPrimary ? Icons.star : Icons.star_border,
                                    color: isPrimary ? Colors.amber : Colors.grey,
                                  ),
                                  tooltip: 'Chọn làm người phụ trách chính',
                                  onPressed: () {
                                    setState(() {
                                      _primaryAssigneeId = isPrimary ? null : user.id;
                                      if (!isPrimary) _selectedAssigneeIds.add(user.id);
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _confirmAssignment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                    )
                  : const Text('Xác nhận giao việc', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
