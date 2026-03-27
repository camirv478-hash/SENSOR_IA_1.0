import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> post({
    required String url,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final response = await http.post(
      Uri.parse(url),
      headers: _jsonHeaders(token),
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  static Future<Map<String, dynamic>> postForm({
    required String url,
    required Map<String, String> body,
    String? token,
  }) async {
    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers.addAll(_authHeaders(token));
    request.fields.addAll(body);
    final response = await http.Response.fromStream(await request.send());
    return _handle(response);
  }

  static Future<Map<String, dynamic>> get({
    required String url,
    String? token,
  }) async {
    final response = await http.get(
        Uri.parse(url), headers: _jsonHeaders(token));
    return _handle(response);
  }

  static Future<Map<String, dynamic>> patch({
    required String url,
    required Map<String, dynamic> body,
    String? token,
  }) async {
    final response = await http.patch(
      Uri.parse(url),
      headers: _jsonHeaders(token),
      body: jsonEncode(body),
    );
    return _handle(response);
  }

  static Future<Map<String, dynamic>> delete({
    required String url,
    String? token,
  }) async {
    final response = await http.delete(
        Uri.parse(url), headers: _jsonHeaders(token));
    return _handle(response, allowEmpty: true);
  }

  // ── Headers ───────────────────────────────────────────
  static Map<String, String> _jsonHeaders(String? token) => {
    'Content-Type': 'application/json',
    ..._authHeaders(token),
  };

  static Map<String, String> _authHeaders(String? token) => {
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // ── Handler ───────────────────────────────────────────
  static Map<String, dynamic> _handle(
    http.Response response, {
    bool allowEmpty = false,
  }) {
    final success = response.statusCode >= 200 && response.statusCode < 300;

    if (allowEmpty && response.body.isEmpty) {
      return {'success': success, 'statusCode': response.statusCode, 'data': {}};
    }

    final data = jsonDecode(utf8.decode(response.bodyBytes));
    return {'success': success, 'statusCode': response.statusCode, 'data': data};
  }
}