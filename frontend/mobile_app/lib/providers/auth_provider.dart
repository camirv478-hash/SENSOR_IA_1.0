import 'package:flutter/material.dart';
import 'package:mobile_app/models/user_model.dart';
import 'package:mobile_app/services/auth_service.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus  status       = AuthStatus.checking;
  UserModel?  user;
  String?     accessToken;
  String?     refreshToken;
  String?     errorMessage;

  // ── Login ──────────────────────────────────────────────
  Future<bool> login(String email, String password) async {
    errorMessage = null;
    final res = await AuthService.login(email, password);

    if (res['success']) {
      accessToken  = res['data']['access'];
      refreshToken = res['data']['refresh'];

      final meRes = await AuthService.getMe(accessToken!);
      if (meRes['success']) {
        user   = UserModel.fromJson(meRes['data']);
        status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      }
    }

    errorMessage = _parseError(res['data']);
    status       = AuthStatus.unauthenticated;
    notifyListeners();
    return false;
  }

  // ── Registro ───────────────────────────────────────────
  Future<bool> register({
    required String nombre,
    required String email,
    required String username,
    required String password,
    required String password2,
  }) async {
    errorMessage = null;
    final res = await AuthService.register(
      nombre:    nombre,
      email:     email,
      username:  username,
      password:  password,
      password2: password2,
    );

    if (!res['success']) {
      errorMessage = _parseError(res['data']);
      notifyListeners();
    }

    return res['success'];
  }

  // ── Verificar email ────────────────────────────────────
  Future<bool> verifyEmail(String email, String code) async {
    errorMessage = null;
    final res = await AuthService.verifyEmail(email: email, code: code);

    if (!res['success']) {
      errorMessage = _parseError(res['data']);
      notifyListeners();
    }

    return res['success'];
  }


  // ── Forgot Password ─────────────────────────────────────
Future<bool> forgotPassword(String email) async {
  errorMessage = null;

  final res = await AuthService.forgotPassword(email);

  if (!res['success']) {
    errorMessage = _parseError(res['data']);
    notifyListeners();
  }

  return res['success'];
}
// ── Update Profile ──────────────────────────────────────
Future<bool> updateProfile(String nombre) async {
  errorMessage = null;

  final res = await AuthService.updateProfile(
    nombre: nombre,
    accessToken: accessToken!,
  );

  if (res['success']) {
    // Opcional: actualizar usuario local
    user = UserModel.fromJson(res['data']);
    notifyListeners();
    return true;
  }

  errorMessage = _parseError(res['data']);
  notifyListeners();
  return false;
}

  // ── Logout ─────────────────────────────────────────────
  Future<void> logout() async {
    if (refreshToken != null && accessToken != null) {
      await AuthService.logout(refreshToken!, accessToken!);
    }
    _clear();
  }

  void _clear() {
    user         = null;
    accessToken  = null;
    refreshToken = null;
    status       = AuthStatus.unauthenticated;
    notifyListeners();
  }

  String _parseError(dynamic data) {
    if (data is Map) {
      final values = data.values.map((v) => v is List ? v.first : v).join(', ');
      return values;
    }
    return 'Error inesperado.';
  }
}
