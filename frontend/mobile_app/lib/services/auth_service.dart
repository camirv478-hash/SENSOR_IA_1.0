class AuthService {

  static Future<Map<String, dynamic>> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email == "admin@sensoria.com" && password == "123456") {
      return {
        "success": true,
        "user": {"name": "Admin"}
      };
    } else {
      return {
        "success": false,
        "message": "Credenciales incorrectas"
      };
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    return {
      "success": true,
      "message": "Usuario registrado correctamente"
    };
  }
}