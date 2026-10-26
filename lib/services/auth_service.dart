import '../models/user.dart';

class AuthService {
  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = User(
      id: 'u1',
      name: 'Nguyen Van A',
      email: email,
      createdAt: DateTime.now(),
    );
    return true;
  }

  Future<bool> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = User(
      id: 'u_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      email: email,
      createdAt: DateTime.now(),
    );
    return true;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }
}
