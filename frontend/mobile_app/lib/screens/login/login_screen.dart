import 'package:flutter/material.dart';
import 'package:mobile_app/screens/register/register_screen.dart';
import 'package:mobile_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF021E16),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 40),

                // Logo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.greenAccent, width: 2),
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: Colors.greenAccent,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 15),

                const Text(
                  "SensorIA",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                // Tarjeta bienvenida
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bienvenido de nuevo",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        "Inicia sesión para continuar",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Input correo
                TextField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _input("Correo", Icons.email),
                ),

                const SizedBox(height: 15),

                // Input contraseña
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: _input("Contraseña", Icons.lock),
                ),

                const SizedBox(height: 25),

                // 🔥 BOTÓN LOGIN FUNCIONAL
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: loading ? null : _login,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text(
                            "Iniciar sesión",
                            style: TextStyle(color: Colors.black),
                          ),
                  ),
                ),

                const SizedBox(height: 15),

                // 🔥 BOTÓN REGISTRO
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RegisterScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    "¿No tienes cuenta? Regístrate",
                    style: TextStyle(color: Colors.greenAccent),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 FUNCIÓN LOGIN
  Future<void> _login() async {
    setState(() => loading = true);

    final response = await AuthService.login(
      emailController.text,
      passwordController.text,
    );

    setState(() => loading = false);

    if (response["success"]) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Bienvenido")));
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(response["message"])));
    }
  }

  // 🎨 INPUT ESTILO
  InputDecoration _input(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      prefixIcon: Icon(icon, color: Colors.greenAccent),
      filled: true,
      fillColor: Colors.green.withOpacity(0.1),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
