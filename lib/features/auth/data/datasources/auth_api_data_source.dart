import 'dart:convert';
import 'package:carelink_mobile/core/utils/api_client.dart';
import 'package:carelink_mobile/features/auth/domain/models/user.dart';
import 'package:carelink_mobile/features/auth/domain/models/session.dart';
import 'package:carelink_mobile/features/auth/domain/models/auth_result.dart';

class AuthApiDataSource {
  final ApiClient _apiClient = ApiClient();

  Future<AuthResult> login(String email, String password) async {
    final response = await _apiClient.post('/login', body: {
      'email': email,
      'password': password,
      'client': 'mobile',
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final userJson = data['user'];

      if (userJson['role'] != 'patient') {
        throw Exception('This mobile app is for patient users only. Doctors, nurses, and administrators must log in through the web clinic portal.');
      }

      final user = AppUser(
        id: userJson['id'].toString(),
        name: userJson['name'],
        email: userJson['email'],
        createdAt: DateTime.now(),
      );

      final session = Session(
        token: token,
        user: user,
        loginTime: DateTime.now(),
      );

      return AuthResult(
        session: session,
        message: 'Login successful',
      );
    } else {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  Future<bool> logout() async {
    final response = await _apiClient.post('/logout');
    return response.statusCode == 200;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _apiClient.post('/me/change-password', body: {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to change password');
    }
  }

  Future<AppUser?> getCurrentUser() async {
    final response = await _apiClient.get('/user');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userJson = data['user'];

      if (userJson['role'] != 'patient') {
        return null;
      }

      return AppUser(
        id: userJson['id'].toString(),
        name: userJson['name'],
        email: userJson['email'],
        createdAt: DateTime.now(),
      );
    }
    return null;
  }
}
