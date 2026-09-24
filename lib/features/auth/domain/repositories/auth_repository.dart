import '../models/session.dart';

abstract class AuthRepository {
  Future<AuthResult> login(String email, String password);
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? firstName,
    String? middleName,
    String? lastName,
  });
  Future<void> forgotPassword(String email);
  Future<void> changePassword({required String currentPassword, required String newPassword});
  Future<void> logout();
  Future<Session?> getCurrentSession();
  Future<void> saveSession(Session session);
  Future<void> clearSession();
}

class AuthResult {
  final Session session;
  final String? message;

  const AuthResult({required this.session, this.message});
}
