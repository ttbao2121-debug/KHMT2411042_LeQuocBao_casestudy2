import '../models/user.dart';
import 'api_client.dart';
import 'auth_service.dart';

class UserService {
  static final UserService _instance = UserService._internal();
  factory UserService() => _instance;
  UserService._internal();

  final ApiClient _apiClient = ApiClient();
  final AuthService _authService = AuthService();

  String? get _token => _authService.token;

  Future<List<User>> searchUsers(String query) async {
    try {
      final res = await _apiClient.get('/users/search?q=${Uri.encodeComponent(query)}', token: _token);
      final rawList = (res['data'] ?? res) as List<dynamic>;
      return rawList.map((item) => User.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<User?> getUserById(String id) async {
    try {
      final res = await _apiClient.get('/users/$id', token: _token);
      return User.fromJson(res);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateProfile(String fullName, String? avatarUrl) async {
    try {
      await _apiClient.put('/auth/me', {
        'fullName': fullName.trim(),
        'avatarUrl': avatarUrl ?? '',
      }, token: _token);

      // Cập nhật thông tin người dùng lưu trong AuthService
      _authService.setCurrentUserName(fullName.trim(), avatarUrl: avatarUrl);
      await _authService.fetchCurrentUser();
      return true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    try {
      await _apiClient.put('/auth/change-password', {
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }, token: _token);
      return true;
    } catch (e) {
      rethrow;
    }
  }
}
