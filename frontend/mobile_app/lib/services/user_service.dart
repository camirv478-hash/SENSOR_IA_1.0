import 'package:mobile_app/core/constants/api_constants.dart';
import 'package:mobile_app/services/api_service.dart';

class UserService {
  static Future<Map<String, dynamic>> getUsers(String accessToken) async {
    return ApiService.get(url: ApiConstants.users, token: accessToken);
  }

  static Future<Map<String, dynamic>> getUser(
      int pk, String accessToken) async {
    return ApiService.get(
        url: ApiConstants.userDetail(pk), token: accessToken);
  }

  static Future<Map<String, dynamic>> createUser({
    required String accessToken,
    required String nombre,
    required String email,
    required String username,
    required String password,
    required String password2,
    required String rol,
  }) async {
    return ApiService.postForm(
      url:   ApiConstants.users,
      token: accessToken,
      body: {
        'nombre':    nombre,
        'email':     email,
        'username':  username,
        'password':  password,
        'password2': password2,
        'rol':       rol,
      },
    );
  }

  static Future<Map<String, dynamic>> updateUser({
    required int    pk,
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    return ApiService.patch(
      url:   ApiConstants.userDetail(pk),
      body:  data,
      token: accessToken,
    );
  }

  static Future<Map<String, dynamic>> deleteUser(
      int pk, String accessToken) async {
    return ApiService.delete(
        url: ApiConstants.userDetail(pk), token: accessToken);
  }
}