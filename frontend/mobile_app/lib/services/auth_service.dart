import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:mobile_app/services/api_service.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    return ApiService.post(
      url:  ApiConstants.login,
      body: {'email': email, 'password': password},
    );
  }

  static Future<Map<String, dynamic>> register({
    required String nombre,
    required String email,
    required String username,
    required String password,
    required String password2,
  }) async {
    return ApiService.postForm(
      url: ApiConstants.register,
      body: {
        'nombre':    nombre,
        'email':     email,
        'username':  username,
        'password':  password,
        'password2': password2,
        'rol':       'USUARIO',
      },
    );
  }

  static Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String code,
  }) async {
    return ApiService.post(
      url:  ApiConstants.verifyEmail,
      body: {'email': email, 'code': code},
    );
  }

  static Future<Map<String, dynamic>> logout(
      String refreshToken, String accessToken) async {
    return ApiService.post(
      url:   ApiConstants.logout,
      body:  {'refresh': refreshToken},
      token: accessToken,
    );
  }

  static Future<Map<String, dynamic>> getMe(String accessToken) async {
    return ApiService.get(url: ApiConstants.me, token: accessToken);
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    return ApiService.post(
      url:  ApiConstants.passwordReset,
      body: {'email': email},
    );
  }

  static Future<Map<String, dynamic>> resetPassword({
    required String token,
    required String password,
  }) async {
    return ApiService.post(
      url:  ApiConstants.passwordResetConfirm,
      body: {'token': token, 'password': password},
    );
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String accessToken,
    required String nombre,
  }) async {
    return ApiService.patch(
      url:   ApiConstants.me,
      body:  {'nombre': nombre},
      token: accessToken,
    );
  }

  static Future<Map<String, dynamic>> changeUsername({
    required String accessToken,
    required String username,
  }) async {
    return ApiService.patch(
      url:   ApiConstants.meUsername,
      body:  {'username': username},
      token: accessToken,
    );
  }
}