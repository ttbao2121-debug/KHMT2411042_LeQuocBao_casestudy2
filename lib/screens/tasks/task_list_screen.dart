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
  String _selectedScope = 'all'; // 'all', 'created', 'assigned', 'shared'
  String? _selectedStatus; // null, 'todo', 'in_progress', 'completed'
  String? _selectedPriority; // null, 'low', 'medium', 'high'
  String _sortBy = 'createdAt';
  String _sortOrder = 'desc';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) return;
      final scopes = ['all', 'created', 'assigned', 'shared'];
      setState(() {
        _selectedScope = scopes[_tabController.index];
      });
      _loadTasks();
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
      scope: _selectedScope == 'all' ? null : _selectedScope,
      status: _selectedStatus,
      priority: _selectedPriority,
      query: _searchController.text.trim(),
      sortBy: _sortBy,
      order: _sortOrder,
    );
    if (mounted) {
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskManager', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.pushNamed(context, '/notifications'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
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
            // Thanh Tìm kiếm & Lọc
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => _loadTasks(),
                      decoration: InputDecoration(
                        hintText: 'Tìm kiếm công việc...',
                        prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchController.clear();
                                  _loadTasks();
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.sort, color: AppColors.primary),
                    tooltip: 'Sắp xếp',
                    onSelected: (val) {
                      setState(() {
                        if (val == 'createdAt_desc') {
                          _sortBy = 'createdAt';
                          _sortOrder = 'desc';
                        } else if (val == 'createdAt_asc') {
                          _sortBy = 'createdAt';
                          _sortOrder = 'asc';
                        } else if (val == 'dueDate_asc') {
                          _sortBy = 'dueDate';
                          _sortOrder = 'asc';
                        }
                      });
                      _loadTasks();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'createdAt_desc', child: Text('Mới nhất trước')),
                      const PopupMenuItem(value: 'createdAt_asc', child: Text('Cũ nhất trước')),
                      const PopupMenuItem(value: 'dueDate_asc', child: Text('Hạn hoàn thành gần nhất')),
                    ],
                  ),
                ],
              ),
            ),

            // Lọc theo Trạng thái & Độ ưu tiên
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  FilterChip(
                    label: const Text('Chờ xử lý'),
                    selected: _selectedStatus == 'todo',
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    onSelected: (selected) {
                      setState(() => _selectedStatus = selected ? 'todo' : null);
                      _loadTasks();
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Đang làm'),
                    selected: _selectedStatus == 'in_progress',
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    onSelected: (selected) {
                      setState(() => _selectedStatus = selected ? 'in_progress' : null);
                      _loadTasks();
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: const Text('Hoàn thành'),
                    selected: _selectedStatus == 'completed',
                    selectedColor: AppColors.primary.withValues(alpha: 0.2),
                    onSelected: (selected) {
                      setState(() => _selectedStatus = selected ? 'completed' : null);
                      _loadTasks();
                    },
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
                                    const Text(
                                      'Chưa có công việc nào',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Nhấn nút "+" bên dưới để tạo công việc mới!',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 8),
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
