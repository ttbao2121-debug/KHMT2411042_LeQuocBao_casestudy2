import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../services/task_service.dart';
import '../../services/user_service.dart';
import '../../utils/constants.dart';

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
  bool _isSearching = false;

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
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final results = await _userService.searchUsers(query.trim());
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  void _confirmAssignment() async {
    if (_taskId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy thông tin công việc'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (_selectedAssigneeIds.isEmpty && _primaryAssigneeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn hoặc nhập Gmail ít nhất 1 người phụ trách'), backgroundColor: AppColors.error),
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
            content: Text('Đã giao việc & Gửi Email thông báo thành công!'),
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Phân công công việc', style: textTheme.headlineMedium?.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Phân công bằng cách nhập Địa chỉ Gmail hoặc Tên người dùng:',
              style: textTheme.labelLarge?.copyWith(fontSize: 15, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              keyboardType: TextInputType.emailAddress,
              style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Nhập địa chỉ Gmail (VD: user@gmail.com)...',
                hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                prefixIcon: const Icon(Icons.mark_email_read_outlined, color: AppColors.primary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Danh sách kết quả tìm thấy:',
                  style: textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
                ),
                if (_isSearching)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _searchResults.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.email_outlined, size: 48, color: AppColors.primary.withValues(alpha: 0.4)),
                          const SizedBox(height: 12),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Hãy nhập địa chỉ Gmail để tìm người nhận'
                                : 'Không tìm thấy người dùng nào phù hợp',
                            style: textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        final isSelected = _selectedAssigneeIds.contains(user.id);
                        final isPrimary = _primaryAssigneeId == user.id;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: isSelected ? 3 : 1,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          color: isSelected ? AppColors.gradientStart : Colors.white,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                              child: Text(
                                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                                style: textTheme.titleLarge?.copyWith(fontSize: 16, color: AppColors.primary),
                              ),
                            ),
                            title: Text(user.name, style: textTheme.titleLarge?.copyWith(fontSize: 15)),
                            subtitle: Text(user.email, style: textTheme.bodyMedium?.copyWith(fontSize: 12)),
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
            const SizedBox(height: 16),
            Container(
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _isLoading ? null : _confirmAssignment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                      )
                    : Text(
                        'Xác nhận phân công',
                        style: textTheme.labelLarge?.copyWith(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
