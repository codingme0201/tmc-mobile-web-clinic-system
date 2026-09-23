import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_api_data_source.dart';

class AuthApiRepository implements AuthRepository {
  final AuthApiDataSource _dataSource = AuthApiDataSource();
  static const String _sessionKey = 'carelink_session';

  @override
  Future<AuthResult> login(String email, String password) async {
    try {
      final result = await _dataSource.login(email, password);

      final session = Session(
        token: result.session.token,
        user: result.session.user,
        loginTime: result.session.loginTime,
      );

      await saveSession(session);
      return AuthResult(session: session, message: 'Login successful.');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final result = await _dataSource.register(
        name: name,
        email: email,
        password: password,
      );

      final session = Session(
        token: result.session.token,
        user: result.session.user,
        loginTime: result.session.loginTime,
      );

      await saveSession(session);
      return AuthResult(session: session, message: result.message ?? 'Registration successful.');
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _dataSource.forgotPassword(email);
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    } catch (e) {
      throw Exception(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  @override
  Future<void> logout() async {
    await _dataSource.logout();
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
    await prefs.setString('auth_token', session.token);
  }

  @override
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
    await prefs.remove('auth_token');
  }
}
