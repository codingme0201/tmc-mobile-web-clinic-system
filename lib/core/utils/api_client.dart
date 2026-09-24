import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform, SocketException;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static const Duration requestTimeout = Duration(seconds: 12);
  static String? _configuredBaseUrl;

  static void setBaseUrl(String url) {
    _configuredBaseUrl = url;
  }

  static Future<void> saveBaseUrl(String url) async {
    _configuredBaseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', url);
  }

  static String get defaultBaseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    if (_configuredBaseUrl != null && _configuredBaseUrl!.isNotEmpty) {
      return _configuredBaseUrl!;
    }
    if (kIsWeb) {
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : '127.0.0.1';
      return 'http://$host:8000/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://192.168.8.56:8000/api';
      }
    } catch (_) {}
    return 'http://127.0.0.1:8000/api';
  }

  Future<String> getBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('api_base_url');
    if (saved != null && saved.isNotEmpty) {
      if (!kIsWeb) {
        try {
          if (Platform.isAndroid && (saved.contains('10.0.2.2') || saved.contains('127.0.0.1') || saved.contains('localhost'))) {
            return defaultBaseUrl;
          }
        } catch (_) {}
      }
      return saved;
    }
    if (_configuredBaseUrl != null && _configuredBaseUrl!.isNotEmpty) {
      return _configuredBaseUrl!;
    }
    return defaultBaseUrl;
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final directToken = prefs.getString('auth_token');
    if (directToken != null && directToken.isNotEmpty) {
      return directToken;
    }
    final sessionJson = prefs.getString('carelink_session');
    if (sessionJson != null) {
      try {
        final decoded = jsonDecode(sessionJson);
        if (decoded is Map && decoded['token'] != null) {
          final token = decoded['token'].toString();
          await prefs.setString('auth_token', token);
          return token;
        }
      } catch (_) {}
    }
    return null;
  }

  Map<String, String> _buildHeaders(String? token, {bool isJson = false}) {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (isJson) {
      headers['Content-Type'] = 'application/json';
    }
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<http.Response> get(String endpoint, {Map<String, String>? queries}) async {
    try {
      final baseUrl = await getBaseUrl();
      final token = await getToken();
      final parsed = Uri.parse('$baseUrl$endpoint');
      final uri = queries != null && queries.isNotEmpty
          ? parsed.replace(queryParameters: {
              ...parsed.queryParameters,
              ...queries,
            })
          : parsed;

      return await http.get(
        uri,
        headers: _buildHeaders(token),
      ).timeout(requestTimeout);
    } on TimeoutException {
      throw Exception('Connection timed out. Please check your network and server connection.');
    } on SocketException {
      throw Exception('Cannot connect to clinic server. Please ensure you are connected to the clinic Wi-Fi.');
    }
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final baseUrl = await getBaseUrl();
      final token = await getToken();

      return await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(token, isJson: true),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(requestTimeout);
    } on TimeoutException {
      throw Exception('Connection timed out. Please check your network and server connection.');
    } on SocketException {
      throw Exception('Cannot connect to clinic server. Please ensure you are connected to the clinic Wi-Fi.');
    }
  }

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final baseUrl = await getBaseUrl();
      final token = await getToken();

      return await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(token, isJson: true),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(requestTimeout);
    } on TimeoutException {
      throw Exception('Connection timed out. Please check your network and server connection.');
    } on SocketException {
      throw Exception('Cannot connect to clinic server. Please ensure you are connected to the clinic Wi-Fi.');
    }
  }

  Future<http.Response> patch(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final baseUrl = await getBaseUrl();
      final token = await getToken();

      return await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(token, isJson: true),
        body: body != null ? jsonEncode(body) : null,
      ).timeout(requestTimeout);
    } on TimeoutException {
      throw Exception('Connection timed out. Please check your network and server connection.');
    } on SocketException {
      throw Exception('Cannot connect to clinic server. Please ensure you are connected to the clinic Wi-Fi.');
    }
  }

  Future<http.Response> delete(String endpoint) async {
    try {
      final baseUrl = await getBaseUrl();
      final token = await getToken();

      return await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _buildHeaders(token),
      ).timeout(requestTimeout);
    } on TimeoutException {
      throw Exception('Connection timed out. Please check your network and server connection.');
    } on SocketException {
      throw Exception('Cannot connect to clinic server. Please ensure you are connected to the clinic Wi-Fi.');
    }
  }
}
