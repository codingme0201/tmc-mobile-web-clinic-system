import 'session.dart';

class AuthResult {
  final Session session;
  final String? message;

  const AuthResult({required this.session, this.message});
}
