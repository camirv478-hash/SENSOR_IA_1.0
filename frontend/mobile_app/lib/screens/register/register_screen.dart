import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/screens/verify_email/verify_email_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey                 = GlobalKey<FormState>();
  final nameController           = TextEditingController();
  final emailController          = TextEditingController();
  final usernameController       = TextEditingController();
  final passwordController       = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool loading = false;

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    final auth    = context.read<AuthProvider>();
    final success = await auth.register(
      nombre:    nameController.text.trim(),
      email:     emailController.text.trim(),
      username:  usernameController.text.trim(),
      password:  passwordController.text,
      password2: confirmPasswordController.text,
    );

    setState(() => loading = false);

    if (!mounted) return;

    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VerifyEmailScreen(email: emailController.text.trim()),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Error al registrar.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF021E16),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text(
                  "Crear Cuenta",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                _field("Nombre",   nameController),
                const SizedBox(height: 15),
                _field("Correo",   emailController,    keyboard: TextInputType.emailAddress),
                const SizedBox(height: 15),
                _field("Username", usernameController),
                const SizedBox(height: 15),
                _field("Contraseña",         passwordController,        obscure: true),
                const SizedBox(height: 15),
                _field("Confirmar contraseña", confirmPasswordController, obscure: true,
                  validator: (v) => v != passwordController.text ? "Las contraseñas no coinciden" : null,
                ),
                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: loading ? null : _register,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.black)
                        : const Text("Registrarse", style: TextStyle(color: Colors.black)),
                  ),
                ),

                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "¿Ya tienes cuenta? Inicia sesión",
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

  TextFormField _field(
    String hint,
    TextEditingController controller, {
    bool obscure                          = false,
    TextInputType keyboard                = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller:   controller,
      obscureText:  obscure,
      keyboardType: keyboard,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText:  hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled:    true,
        fillColor: Colors.green.withOpacity(0.1),
        border:    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator ?? (v) => v!.isEmpty ? "Campo requerido" : null,
    );
  }
}