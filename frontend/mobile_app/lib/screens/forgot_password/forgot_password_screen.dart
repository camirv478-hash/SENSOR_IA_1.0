import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emailController = TextEditingController();
  bool loading = false;

  Future<void> _submit() async {
    if (emailController.text.trim().isEmpty) return;

    setState(() => loading = true);
    final auth    = context.read<AuthProvider>();
    final success = await auth.forgotPassword(emailController.text.trim());
    setState(() => loading = false);

    if (!mounted) return;

    // Siempre mostramos el mismo mensaje por seguridad
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Si el correo existe, recibirás un enlace."),
      ),
    );

    if (success) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF021E16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text("Recuperar contraseña",
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            const Text(
                "Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.",
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 30),
            TextField(
              controller:   emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText:   "Correo",
                hintStyle:  const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.email, color: Colors.greenAccent),
                filled:     true,
                fillColor:  Colors.green.withOpacity(0.1),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: loading ? null : _submit,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("Enviar enlace",
                        style: TextStyle(color: Colors.black)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}