import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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

                // Nombre
                TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _input("Nombre"),
                  validator: (value) =>
                      value!.isEmpty ? "Ingrese su nombre" : null,
                ),

                const SizedBox(height: 15),

                // Email
                TextFormField(
                  controller: emailController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _input("Correo"),
                  validator: (value) {
                    if (value!.isEmpty) return "Ingrese su correo";
                    if (!value.contains("@")) return "Correo inválido";
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // Contraseña
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: _input("Contraseña"),
                  validator: (value) {
                    if (value!.length < 6) return "Mínimo 6 caracteres";
                    return null;
                  },
                ),

                const SizedBox(height: 15),

                // Confirmar contraseña
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: _input("Confirmar contraseña"),
                  validator: (value) {
                    if (value != passwordController.text) {
                      return "Las contraseñas no coinciden";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 25),

                // 🔥 BOTÓN REGISTRAR
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        print("Registro correcto");
                      }
                    },
                    child: const Text(
                      "Registrarse",
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                // 🔥 VOLVER AL LOGIN
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "¿Ya tienes cuenta? Inicia sesión",
                    style: TextStyle(color: Colors.greenAccent),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _input(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.green.withOpacity(0.1),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}