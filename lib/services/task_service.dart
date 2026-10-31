import '../models/task.dart';
import 'api_client.dart';
import 'auth_service.dart';

class TaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  String? get _token => _authService.token;

  Future<List<Task>> getTasks() async {
    try {
      final res = await _apiClient.get('/tasks', token: _token);
      final rawList = (res['data'] ?? res) as List<dynamic>;
      return rawList.map((item) => Task.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<Task?> getTaskById(String id) async {
    try {
      final res = await _apiClient.get('/tasks/$id', token: _token);
      return Task.fromJson(res);
    } catch (e) {
      return null;
    }
  }

  Future<Task?> createTask(Task task) async {
    try {
      final res = await _apiClient.post('/tasks', task.toJson(), token: _token);
      return Task.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  Future<Task?> updateTask(Task updatedTask) async {
    try {
      final res = await _apiClient.put('/tasks/${updatedTask.id}', updatedTask.toJson(), token: _token);
      return Task.fromJson(res);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _apiClient.delete('/tasks/$id', token: _token);
    } catch (e) {
      rethrow;
    }
  }
}
