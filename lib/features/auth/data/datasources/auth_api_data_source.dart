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

      final role = userJson['role'];
      if (role != 'student' && role != 'patient') {
        throw Exception('This mobile app is for student users only. Doctors, nurses, and administrators must log in through the web clinic portal.');
      }

      final user = AppUser(
        id: userJson['id'].toString(),
        name: userJson['name'],
        email: userJson['email'],
        createdAt: DateTime.now(),
        isProfileComplete: userJson['isProfileComplete'] == true,
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

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? studentId,
    String? courseDept,
    String? contact,
  }) async {
    final response = await _apiClient.post('/register', body: {
      'name': name,
      'email': email,
      'password': password,
      if (studentId != null && studentId.isNotEmpty) 'student_id': studentId,
      if (courseDept != null && courseDept.isNotEmpty) 'course_dept': courseDept,
      if (contact != null && contact.isNotEmpty) 'contact': contact,
    });

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];
      final userJson = data['user'];

      final user = AppUser(
        id: userJson['id'].toString(),
        name: userJson['name'],
        email: userJson['email'],
        createdAt: DateTime.now(),
        isProfileComplete: userJson['isProfileComplete'] == true,
      );

      final session = Session(
        token: token,
        user: user,
        loginTime: DateTime.now(),
      );

      return AuthResult(
        session: session,
        message: data['message'] ?? 'Registration successful',
      );
    } else {
      final data = jsonDecode(response.body);
      if (data['errors'] != null && data['errors'] is Map) {
        final Map errors = data['errors'];
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          throw Exception(firstError.first.toString());
        }
      }
      throw Exception(data['message'] ?? 'Registration failed');
    }
  }

  Future<String> forgotPassword(String email) async {
    final response = await _apiClient.post('/forgot-password', body: {
      'email': email,
    });

    final data = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return data['message'] ?? 'Password reset instructions sent.';
    } else {
      if (data['errors'] != null && data['errors'] is Map) {
        final Map errors = data['errors'];
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          throw Exception(firstError.first.toString());
        }
      }
      throw Exception(data['message'] ?? 'Failed to request password reset.');
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

      final role = userJson['role'];
      if (role != 'student' && role != 'patient') {
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
