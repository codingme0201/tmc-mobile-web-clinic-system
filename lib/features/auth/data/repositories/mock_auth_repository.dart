import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/session.dart';
import '../../domain/models/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/mock_auth_data_source.dart';

class MockAuthRepository implements AuthRepository {
  final MockAuthDataSource _dataSource = MockAuthDataSource.instance;
  static const String _sessionKey = 'carelink_session';

  @override
  Future<AuthResult> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (!_dataSource.verifyPassword(email, password)) {
      throw Exception('Invalid email or password.');
    }

    final user = _dataSource.findByEmail(email)!;
    final appUser = AppUser(
      id: user.id,
      name: user.name,
      email: user.email,
      createdAt: user.createdAt,
    );
    final session = Session(
      token: 'mock_token_${user.id}_${DateTime.now().millisecondsSinceEpoch}',
      user: appUser,
      loginTime: DateTime.now(),
    );

    await saveSession(session);
    return AuthResult(session: session, message: 'Login successful.');
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? firstName,
    String? middleName,
    String? lastName,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (_dataSource.emailExists(email)) {
      throw Exception('An account with this email already exists.');
    }

    final appUser = _dataSource.addUser(name: name, email: email, password: password);
    final session = Session(
      token: 'mock_token_${appUser.id}_${DateTime.now().millisecondsSinceEpoch}',
      user: appUser,
      loginTime: DateTime.now(),
    );

    await saveSession(session);
    return AuthResult(session: session, message: 'Registration successful.');
  }

  @override
  Future<void> forgotPassword(String email) async {
    await Future.delayed(const Duration(milliseconds: 600));

    if (!_dataSource.emailExists(email)) {
      throw Exception('No account found with this email address.');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final session = await getCurrentSession();
    if (session == null) throw Exception('Not authenticated.');

    final updated = _dataSource.updatePassword(
      session.user.email,
      currentPassword,
      newPassword,
    );

    if (!updated) {
      throw Exception('Current password is incorrect.');
    }
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    await clearSession();
  }

  @override
  Future<Session?> getCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_sessionKey);
    if (json == null) return null;
    try {
      return Session.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> saveSession(Session session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(session.toJson()));
  }

  @override
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }
}
