import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/statistics_service.dart';
import '../../services/user_service.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final StatisticsService _statService = StatisticsService();

  Map<String, dynamic> _taskStats = {};
  Map<String, dynamic> _deadlineStats = {};
  bool _isLoadingStats = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingStats = true);
    await _authService.fetchCurrentUser();
    final taskStats = await _statService.getTaskStatistics();
    final deadlineStats = await _statService.getDeadlineStatistics();
    if (mounted) {
      setState(() {
        _taskStats = taskStats;
        _deadlineStats = deadlineStats;
        _isLoadingStats = false;
      });
    }
  }

  void _showUpdateProfileDialog() {
    final nameController = TextEditingController(text: _authService.currentUser?.name ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cập nhật hồ sơ'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Họ và tên'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _userService.updateProfile(nameController.text, null);
                await _authService.fetchCurrentUser();
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cập nhật hồ sơ thành công!'), backgroundColor: AppColors.primary),
                  );
                  setState(() {});
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu cũ'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Nhập lại mật khẩu mới'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              final oldPass = oldPassController.text;
              final newPass = newPassController.text;
              final confirmPass = confirmPassController.text;

              if (oldPass.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vui lòng nhập đầy đủ các trường'), backgroundColor: AppColors.error),
                );
                return;
              }

              if (newPass.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mật khẩu mới phải có ít nhất 6 ký tự'), backgroundColor: AppColors.error),
                );
                return;
              }

              if (newPass != confirmPass) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mật khẩu xác nhận không trùng khớp'), backgroundColor: AppColors.error),
                );
                return;
              }

              try {
                await _userService.changePassword(oldPass, newPass);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đổi mật khẩu thành công!'), backgroundColor: AppColors.primary),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(e.toString().replaceAll('Exception: ', '')), backgroundColor: AppColors.error),
                  );
                }
              }
            },
            child: const Text('Đổi mật khẩu'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cá nhân & Thống kê',
          style: textTheme.headlineMedium?.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Thông tin cá nhân
              const CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 48, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                user?.name ?? 'Người dùng',
                style: textTheme.titleLarge?.copyWith(
                  fontSize: 20,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '',
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),

              // Khối Thống Kê
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Thống kê công việc',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _isLoadingStats
                  ? const LoadingView()
                  : GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 2.2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildStatCard(context, 'Tổng số', _taskStats['total']?.toString() ?? '0', AppColors.primary),
                        _buildStatCard(context, 'Chờ xử lý', _taskStats['todo']?.toString() ?? '0', AppColors.statusPending),
                        _buildStatCard(context, 'Đang làm', _taskStats['inProgress']?.toString() ?? '0', AppColors.statusInProgress),
                        _buildStatCard(context, 'Hoàn thành', _taskStats['completed']?.toString() ?? '0', AppColors.statusCompleted),
                        _buildStatCard(context, 'Sắp đến hạn', _deadlineStats['upcoming']?.toString() ?? '0', Colors.orange),
                        _buildStatCard(context, 'Quá hạn', _deadlineStats['overdue']?.toString() ?? '0', AppColors.error),
                      ],
                    ),
              const SizedBox(height: 28),

              // Các cài đặt tài khoản
              ListTile(
                leading: const Icon(Icons.edit, color: AppColors.primary),
                title: Text('Cập nhật hồ sơ', style: textTheme.bodyLarge),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showUpdateProfileDialog,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.lock, color: AppColors.primary),
                title: Text('Đổi mật khẩu', style: textTheme.bodyLarge),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: _showChangePasswordDialog,
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: Text('Đăng xuất', style: textTheme.bodyLarge?.copyWith(color: AppColors.error)),
                onTap: () async {
                  await _authService.logout();
                  if (context.mounted) {
                    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, Color color) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label, style: textTheme.bodyMedium?.copyWith(fontSize: 12, color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text(
              value,
              style: textTheme.displayMedium?.copyWith(
                fontSize: 24,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
