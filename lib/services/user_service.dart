import '../models/user.dart';

class UserService {
  final List<User> _users = [
    User(
      id: 'u1',
      name: 'Nguyen Van A',
      email: 'nguyenvana@gmail.com',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    User(
      id: 'u2',
      name: 'Tran Thi B',
      email: 'tranthib@gmail.com',
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
    User(
      id: 'u3',
      name: 'Le Van C',
      email: 'levanc@gmail.com',
      createdAt: DateTime.now().subtract(const Duration(days: 10)),
    ),
  ];

  Future<List<User>> getUsers() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_users);
  }

  Future<User?> getUserById(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _users.firstWhere((u) => u.id == id);
    } catch (_) {
      return null;
    }
  }
}
