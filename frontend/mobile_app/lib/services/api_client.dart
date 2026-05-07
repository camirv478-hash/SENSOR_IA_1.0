import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  // ─────────────────────────────────────────────
  // BASE URL DINÁMICA
  // ─────────────────────────────────────────────
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000';
    } else {
      return 'http://10.0.2.2:8000';
    }
  }

  // ─────────────────────────────────────────────
  // GET
  // ─────────────────────────────────────────────
  Future<http.Response> get(String path) async {
    return _request(() async {
      final token = await _getAccessToken();

      print('🔑 TOKEN GET: $token');

      return http
          .get(
            Uri.parse('$baseUrl$path'),
            headers: _headers(token),
          )
          .timeout(const Duration(seconds: 15));
    });
  }

  // ─────────────────────────────────────────────
  // POST
  // ─────────────────────────────────────────────
  Future<http.Response> post(String path, Map<String, dynamic> body) async {
    return _request(() async {
      final token = await _getAccessToken();

      print('🔑 TOKEN POST: $token');

      return http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: _headers(token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 15));
    });
  }

  // ─────────────────────────────────────────────
  // HEADERS
  // ─────────────────────────────────────────────
  Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  // ─────────────────────────────────────────────
  // TOKENS
  // ─────────────────────────────────────────────
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    return token;
  }

  Future<String?> _getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('refresh_token');
  }

  Future<void> _saveAccessToken(String access) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
  }

  Future<void> _clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
  }

  // ─────────────────────────────────────────────
  // REFRESH TOKEN
  // ─────────────────────────────────────────────
  Future<bool> _refreshToken() async {
    final refresh = await _getRefreshToken();

    if (refresh == null) {
      print('❌ NO REFRESH TOKEN');
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/auth/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refresh}),
      );

      print('🔄 REFRESH STATUS: ${response.statusCode}');
      print('🔄 REFRESH BODY: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await _saveAccessToken(data['access']);
        return true;
      }

      // ❗ refresh inválido → limpiar sesión
      await _clearTokens();
      return false;
    } catch (e) {
      print('❌ REFRESH ERROR: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // INTERCEPTOR
  // ─────────────────────────────────────────────
  Future<http.Response> _request(
    Future<http.Response> Function() request,
  ) async {
    try {
      var response = await request();

      // 🔥 TOKEN EXPIRADO
      if (response.statusCode == 401) {
        print('⚠️ TOKEN EXPIRADO → intentando refresh');

        final refreshed = await _refreshToken();

        if (refreshed) {
          print('✅ TOKEN REFRESCADO → retry request');
          response = await request();
        } else {
          print('❌ REFRESH FALLÓ → sesión inválida');
        }
      }

      return response;
    } catch (e) {
      print('❌ REQUEST ERROR: $e');
      rethrow;
    }
  }
}