import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/task_service.dart';
import '../../services/user_service.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_view.dart';

class TaskSharingScreen extends StatefulWidget {
  const TaskSharingScreen({super.key});

  @override
  State<TaskSharingScreen> createState() => _TaskSharingScreenState();
}

class _TaskSharingScreenState extends State<TaskSharingScreen> {
  final UserService _userService = UserService();
  final TaskService _taskService = TaskService();
  final TextEditingController _searchController = TextEditingController();

  String? _taskId;
  List<dynamic> _shares = [];
  List<User> _userSearchResults = [];
  bool _isLoading = true;
  String _selectedPermission = 'viewer';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args != null) {
      _taskId = args;
      _loadShares();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadShares() async {
    if (_taskId == null) return;
    setState(() => _isLoading = true);
    final shares = await _taskService.getTaskShares(_taskId!);
    if (mounted) {
      setState(() {
        _shares = shares;
        _isLoading = false;
      });
    }
  }

  void _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _userSearchResults = []);
      return;
    }
    final results = await _userService.searchUsers(query.trim());
    setState(() {
      _userSearchResults = results;
    });
  }

  void _shareWithUser(User user) async {
    if (_taskId == null) return;
    try {
      await _taskService.shareTask(_taskId!, [user.id], _selectedPermission);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã chia sẻ với ${user.name}'), backgroundColor: AppColors.primary),
        );
        _searchController.clear();
        setState(() => _userSearchResults = []);
        _loadShares();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _updatePermission(String shareId, String newPermission) async {
    if (_taskId == null) return;
    try {
      await _taskService.updateSharePermission(_taskId!, shareId, newPermission);
      _loadShares();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _revokeShare(String shareId) async {
    if (_taskId == null) return;
    try {
      await _taskService.revokeSharePermission(_taskId!, shareId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã thu hồi quyền chia sẻ'), backgroundColor: AppColors.error),
        );
        _loadShares();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chia sẻ & Quản lý quyền'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thêm người được chia sẻ:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _searchUsers,
                    decoration: InputDecoration(
                      hintText: 'Nhập tên hoặc email...',
                      prefixIcon: const Icon(Icons.person_search, color: AppColors.primary),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedPermission,
                  items: const [
                    DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                    DropdownMenuItem(value: 'editor', child: Text('Editor')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedPermission = val);
                  },
                ),
              ],
            ),
            if (_userSearchResults.isNotEmpty) ...[
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _userSearchResults.length,
                  itemBuilder: (context, index) {
                    final u = _userSearchResults[index];
                    return ListTile(
                      title: Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(u.email),
                      trailing: IconButton(
                        icon: const Icon(Icons.add_circle, color: AppColors.primary),
                        onPressed: () => _shareWithUser(u),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text(
              'Danh sách người đã được chia sẻ:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            _isLoading
                ? const LoadingView()
                : _shares.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text('Chưa chia sẻ với ai')),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _shares.length,
                        itemBuilder: (context, index) {
                          final item = _shares[index];
                          final shareId = item['_id']?.toString() ?? '';
                          final userObj = item['userId'] ?? {};
                          final name = userObj['fullName'] ?? 'Người dùng';
                          final email = userObj['email'] ?? '';
                          final perm = item['permission'] ?? 'viewer';

                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: AppColors.primary,
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(email),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  DropdownButton<String>(
                                    value: perm,
                                    items: const [
                                      DropdownMenuItem(value: 'viewer', child: Text('Viewer')),
                                      DropdownMenuItem(value: 'editor', child: Text('Editor')),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) _updatePermission(shareId, val);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.remove_circle, color: AppColors.error),
                                    tooltip: 'Thu hồi quyền',
                                    onPressed: () => _revokeShare(shareId),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
