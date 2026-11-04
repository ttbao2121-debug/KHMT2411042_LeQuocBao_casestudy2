import 'api_client.dart';
import 'auth_service.dart';

class StatisticsService {
  static final StatisticsService _instance = StatisticsService._internal();
  factory StatisticsService() => _instance;
  StatisticsService._internal();

  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  String? get _token => _authService.token;

  Future<Map<String, dynamic>> getTaskStatistics() async {
    try {
      final res = await _apiClient.get('/statistics/tasks', token: _token);
      return res;
    } catch (e) {
      return {'total': 0, 'todo': 0, 'inProgress': 0, 'completed': 0};
    }
  }

  Future<Map<String, dynamic>> getDeadlineStatistics() async {
    try {
      final res = await _apiClient.get('/statistics/deadlines', token: _token);
      return res;
    } catch (e) {
      return {'overdue': 0, 'upcoming': 0};
    }
  }
}
