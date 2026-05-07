import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

enum AuthStatus {
  checking,
  authenticated,
  unauthenticated,
  error,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _pendingEmail;
  String? _accessToken;
  String? _refreshToken;
  UserModel? _user;

  AuthStatus _status = AuthStatus.checking;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;
  String? get pendingEmail => _pendingEmail;
  UserModel? get user => _user;
  AuthStatus get status => _status;

  bool get isAuthenticated => _status == AuthStatus.authenticated;

  void _setStatus(AuthStatus status) {
    _status = status;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
  }

  void _clearMessages() {
    _errorMessage = null;
    _successMessage = null;
  }

  // REGISTER
  Future<bool> register({
    required String nombre,
    required String email,
    required String password,
    required String password2,
  }) async {
    _setLoading(true);
    _clearMessages();
    notifyListeners();

    try {
      final result = await _authService.register(
        nombre: nombre,
        email: email,
        password: password,
        password2: password2,
      );

      if (result['success']) {
        _pendingEmail = result['email'] ?? email;
        _successMessage = result['message'];
        _setLoading(false);
        notifyListeners();
        return true;
      } else {
        _errorMessage = result['message'];
        _setLoading(false);
        notifyListeners();
        return false;
      }
    } catch (_) {
      _errorMessage = 'Error de conexión';
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // VERIFY EMAIL
Future<bool> verifyEmail(String code) async {
  if (_pendingEmail == null) {
    _errorMessage = 'No hay email pendiente';
    notifyListeners();
    return false;
  }

  _setLoading(true);
  _clearMessages();
  notifyListeners();

  try {
    final result = await _authService.verifyEmail(
      _pendingEmail!,
      code,
    );

    if (result['success']) {
      _successMessage = result['message'];
      _pendingEmail = null;

      _setLoading(false);
      notifyListeners();
      return true;
    } else {
      _errorMessage = result['message'];

      _setLoading(false);
      notifyListeners();
      return false;
    }
  } catch (_) {
    _errorMessage = 'Error de conexión';

    _setLoading(false);
    notifyListeners();
    return false;
  }
}

  // LOGIN
  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearMessages();
    notifyListeners();

    try {
      final result = await _authService.login(email, password);

      if (!result['success']) {
        _errorMessage = result['message'];
        _setStatus(AuthStatus.unauthenticated);
        _setLoading(false);
        return false;
      }

      _accessToken = result['access'];
      _refreshToken = result['refresh'];

      await _saveTokens(_accessToken!, _refreshToken!);

      _user = await _authService.getProfile();

      if (_user == null) {
        _errorMessage = 'Error obteniendo usuario';
        _setStatus(AuthStatus.error);
        _setLoading(false);
        return false;
      }

      _setStatus(AuthStatus.authenticated);
      _setLoading(false);
      return true;
    } catch (_) {
      _errorMessage = 'Error de conexión';
      _setStatus(AuthStatus.error);
      _setLoading(false);
      return false;
    }
  }

  // SESSION CHECK (FIX CLAVE)
  Future<void> checkSession() async {
    await Future.delayed(Duration.zero); // 👈 EVITA EL ERROR DE BUILD

    _setStatus(AuthStatus.checking);

    await loadTokens();

    if (_accessToken == null) {
      _setStatus(AuthStatus.unauthenticated);
      return;
    }

    final user = await _authService.getProfile();

    if (user != null) {
      _user = user;
      _setStatus(AuthStatus.authenticated);
    } else {
      await logout();
      _setStatus(AuthStatus.unauthenticated);
    }
  }

  // LOGOUT
  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    _pendingEmail = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _setStatus(AuthStatus.unauthenticated);
  }

  // STORAGE
  Future<void> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
  }

  Future<void> _saveTokens(String access, String refresh) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', access);
    await prefs.setString('refresh_token', refresh);
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  void clearSuccess() {
    _successMessage = null;
    notifyListeners();
  }
}