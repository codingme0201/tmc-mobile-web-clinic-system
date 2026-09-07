import '../../domain/models/user.dart';

class MockUser {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final DateTime createdAt;

  const MockUser({
    required this.id,
    required this.name,
    required this.email,
    required this.passwordHash,
    required this.createdAt,
  });
}

class MockAuthDataSource {
  static final MockAuthDataSource instance = MockAuthDataSource._();
  MockAuthDataSource._();

  final List<MockUser> _users = [
    MockUser(
      id: '1',
      name: 'Demo User',
      email: 'demo@tmccarelink.com',
      passwordHash: 'Demo1234',
      createdAt: DateTime(2025, 1, 1),
    ),
    MockUser(
      id: '2',
      name: 'Juan Dela Cruz',
      email: 'juan@tmccarelink.com',
      passwordHash: 'Password123',
      createdAt: DateTime(2025, 3, 15),
    ),
  ];

  List<MockUser> get users => List.unmodifiable(_users);

  MockUser? findByEmail(String email) {
    try {
      return _users.firstWhere((u) => u.email.toLowerCase() == email.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  bool emailExists(String email) => findByEmail(email) != null;

  AppUser addUser({required String name, required String email, required String password}) {
    final user = MockUser(
      id: (_users.length + 1).toString(),
      name: name,
      email: email,
      passwordHash: password,
      createdAt: DateTime.now(),
    );
    _users.add(user);
    return AppUser(id: user.id, name: user.name, email: user.email, createdAt: user.createdAt);
  }

  bool verifyPassword(String email, String password) {
    final user = findByEmail(email);
    if (user == null) return false;
    return user.passwordHash == password;
  }

  bool updatePassword(String email, String currentPassword, String newPassword) {
    final index = _users.indexWhere((u) => u.email.toLowerCase() == email.toLowerCase());
    if (index == -1) return false;
    if (_users[index].passwordHash != currentPassword) return false;
    _users[index] = MockUser(
      id: _users[index].id,
      name: _users[index].name,
      email: _users[index].email,
      passwordHash: newPassword,
      createdAt: _users[index].createdAt,
    );
    return true;
  }
}
