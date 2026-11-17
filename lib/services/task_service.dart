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

  Future<List<Task>> getTasks({String? scope, String? status, String? search}) async {
    try {
      final queryParams = <String>[];
      if (scope != null && scope.isNotEmpty) queryParams.add('scope=$scope');
      if (status != null && status.isNotEmpty) queryParams.add('status=$status');
      if (search != null && search.isNotEmpty) queryParams.add('search=${Uri.encodeComponent(search)}');

      final queryString = queryParams.isNotEmpty ? '?${queryParams.join('&')}' : '';
      final res = await _apiClient.get('/tasks$queryString', token: _token);

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

  Future<void> createTask(Task task) async {
    try {
      await _apiClient.post('/tasks', task.toJson(), token: _token);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTask(Task updatedTask) async {
    try {
      await _apiClient.put('/tasks/${updatedTask.id}', updatedTask.toJson(), token: _token);
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

  Future<void> assignTask(String taskId, List<String> assigneeIds, String? primaryAssigneeId) async {
    try {
      await _apiClient.post('/tasks/$taskId/assignees', {
        'assigneeIds': assigneeIds,
        if (primaryAssigneeId != null) 'primaryAssigneeId': primaryAssigneeId,
      }, token: _token);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> shareTask(String taskId, List<String> userIds, String permission) async {
    try {
      await _apiClient.post('/tasks/$taskId/shares', {
        'userIds': userIds,
        'permission': permission,
      }, token: _token);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getTaskShares(String taskId) async {
    try {
      final res = await _apiClient.get('/tasks/$taskId/shares', token: _token);
      return (res['data'] ?? res) as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  Future<void> updateSharePermission(String taskId, String shareId, String permission) async {
    try {
      await _apiClient.patch('/tasks/$taskId/shares/$shareId', {
        'permission': permission,
      }, token: _token);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> revokeSharePermission(String taskId, String shareId) async {
    try {
      await _apiClient.delete('/tasks/$taskId/shares/$shareId', token: _token);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getTaskActivities(String taskId) async {
    try {
      final res = await _apiClient.get('/tasks/$taskId/activities', token: _token);
      return (res['data'] ?? res) as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getTaskEmailLogs(String taskId) async {
    try {
      final res = await _apiClient.get('/tasks/$taskId/email-logs', token: _token);
      return (res['data'] ?? res) as List<dynamic>;
    } catch (e) {
      return [];
    }
  }

  Future<void> retryEmail(String logId) async {
    try {
      await _apiClient.post('/email-logs/$logId/retry', {}, token: _token);
    } catch (e) {
      rethrow;
    }
  }
}
