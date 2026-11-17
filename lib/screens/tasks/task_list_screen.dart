import 'package:flutter/material.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../../utils/constants.dart';
import '../../widgets/loading_view.dart';
import '../../widgets/task_card.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> with SingleTickerProviderStateMixin {
  final TaskService _taskService = TaskService();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  List<Task> _tasks = [];
  bool _isLoading = true;
  String _selectedScope = 'all'; // 'all', 'my', 'assigned', 'shared'
  String? _selectedStatus; // null, 'todo', 'in_progress', 'completed'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        switch (_tabController.index) {
          case 0:
            _selectedScope = 'all';
            break;
          case 1:
            _selectedScope = 'my';
            break;
          case 2:
            _selectedScope = 'assigned';
            break;
          case 3:
            _selectedScope = 'shared';
            break;
        }
        _loadTasks();
      }
    });
    _loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    final tasks = await _taskService.getTasks(
      scope: _selectedScope,
      status: _selectedStatus,
      search: _searchController.text.trim(),
    );
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    _loadTasks();
  }

  void _onStatusFilterSelected(String? status) {
    setState(() {
      _selectedStatus = _selectedStatus == status ? null : status;
    });
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Danh sách công việc', style: textTheme.headlineMedium?.copyWith(color: Colors.white)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            tooltip: 'Thông báo',
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Cá nhân & Thống kê',
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Của tôi'),
            Tab(text: 'Được giao'),
            Tab(text: 'Chia sẻ'),
          ],
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: Column(
          children: [
            // Thanh Tìm kiếm & Lọc trạng thái
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: textTheme.bodyLarge?.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm công việc...',
                      hintStyle: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: AppColors.textSecondary),
                              onPressed: () {
                                _searchController.clear();
                                _loadTasks();
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Chip Lọc Trạng thái
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        FilterChip(
                          label: Text('Chờ xử lý', style: textTheme.labelLarge?.copyWith(fontSize: 12)),
                          selected: _selectedStatus == 'todo',
                          selectedColor: AppColors.primary.withValues(alpha: 0.25),
                          onSelected: (_) => _onStatusFilterSelected('todo'),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text('Đang làm', style: textTheme.labelLarge?.copyWith(fontSize: 12)),
                          selected: _selectedStatus == 'in_progress',
                          selectedColor: AppColors.primary.withValues(alpha: 0.25),
                          onSelected: (_) => _onStatusFilterSelected('in_progress'),
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: Text('Hoàn thành', style: textTheme.labelLarge?.copyWith(fontSize: 12)),
                          selected: _selectedStatus == 'completed',
                          selectedColor: AppColors.primary.withValues(alpha: 0.25),
                          onSelected: (_) => _onStatusFilterSelected('completed'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Danh sách công việc
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadTasks,
                color: AppColors.primary,
                child: _isLoading
                    ? const LoadingView(message: 'Đang tải danh sách công việc...')
                    : _tasks.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 80),
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(20),
                                      decoration: BoxDecoration(
                                        color: AppColors.primary.withValues(alpha: 0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.assignment_outlined,
                                        size: 64,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Chưa có công việc nào',
                                      style: textTheme.titleLarge?.copyWith(
                                        fontSize: 18,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Nhấn nút "+" bên dưới để tạo công việc mới!',
                                      style: textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: _tasks.length,
                            itemBuilder: (context, index) {
                              final task = _tasks[index];
                              return TaskCard(
                                task: task,
                                onTap: () async {
                                  await Navigator.pushNamed(context, '/task-detail', arguments: task.id);
                                  _loadTasks();
                                },
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.pushNamed(context, '/task-create');
          if (result == true) {
            _loadTasks();
          }
        },
      ),
    );
  }
}
