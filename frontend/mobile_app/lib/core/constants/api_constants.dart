class ApiConstants {
  // ── Cambia según donde corras Flutter ──────────────────
  
  // Emulador Android  → usa esta
  // static const String _base = 'http://10.0.2.2:8000/user';

  // Chrome / Linux desktop → usa esta
  static const String _base = 'http://127.0.0.1:8000';

  static const String login   = '$_base/user/auth/login/';
  static const String logout  = '$_base/user/auth/logout/';
  static const String refresh = '$_base/user/auth/refresh/';

  static const String register    = '$_base/user/register/';
  static const String verifyEmail = '$_base/user/verify-email/';

  static const String me         = '$_base/user/me/';
  static const String meUsername = '$_base/user/me/username/';
  static const String emailChange  = '$_base/user/me/email/change/';
  static const String emailConfirm = '$_base/user/me/email/confirm/';

  static const String passwordReset        = '$_base/user/password/reset/';
  static const String passwordResetConfirm = '$_base/user/password/reset/confirm/';

  static const String users = '$_base/user/';
  static String userDetail(int pk) => '$_base/user/$pk/';


  //bin
  static const String bins = '$_base/bin/';
  static String binDetail(int pk)  => '$_base/bin/$pk/';
  static String binUpdate(int pk)  => '$_base/bin/$pk/update/';
  static String binDelete(int pk)  => '$_base/bin/$pk/delete/';
  static const String binCreate    = '$_base/bin/create/';
}