import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiClient _apiClient = ApiClient();
  User? _currentUser;
  String? _token;

  User? get currentUser => _currentUser;
  String? get token => _token;

  Future<bool> login(String email, String password) async {
    try {
      final res = await _apiClient.post('/auth/login', {
        'email': email.trim(),
        'password': password,
      });

      if (res['token'] != null) {
        _token = res['token'] as String;
        final userData = res['user'] as Map<String, dynamic>;
        _currentUser = User(
          id: userData['id'] as String? ?? '',
          name: userData['fullName'] as String? ?? (userData['name'] as String? ?? ''),
          email: userData['email'] as String? ?? email,
          createdAt: DateTime.now(),
        );
        return true;
      }
      throw Exception('Không nhận được token từ hệ thống');
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> register(String name, String email, String password) async {
    try {
      final res = await _apiClient.post('/auth/register', {
        'fullName': name.trim(),
        'email': email.trim(),
        'password': password,
      });

      if (res['token'] != null) {
        _token = res['token'] as String;
        final userData = res['user'] as Map<String, dynamic>;
        _currentUser = User(
          id: userData['id'] as String? ?? '',
          name: userData['fullName'] as String? ?? name,
          email: userData['email'] as String? ?? email,
          createdAt: DateTime.now(),
        );
        return true;
      }
      throw Exception('Đăng ký tài khoản không thành công');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
  }
}
