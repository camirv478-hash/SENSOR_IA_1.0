import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/services/user_service.dart';

class UserCreateScreen extends StatefulWidget {
  const UserCreateScreen({super.key});

  @override
  State<UserCreateScreen> createState() => _UserCreateScreenState();
}

class _UserCreateScreenState extends State<UserCreateScreen> {
  final _formKey              = GlobalKey<FormState>();
  final nombreController      = TextEditingController();
  final emailController       = TextEditingController();
  final usernameController    = TextEditingController();
  final passwordController    = TextEditingController();
  final password2Controller   = TextEditingController();

  String selectedRol = 'USUARIO';
  bool   loading     = false;

  Future<void> _create() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    final token = context.read<AuthProvider>().accessToken!;
    final res   = await UserService.createUser(
      accessToken: token,
      nombre:      nombreController.text.trim(),
      email:       emailController.text.trim(),
      username:    usernameController.text.trim(),
      password:    passwordController.text,
      password2:   password2Controller.text,
      rol:         selectedRol,
    );
    setState(() => loading = false);

    if (!mounted) return;
    if (res['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario creado correctamente.")));
      Navigator.pop(context);
    } else {
      final errors = res['data'] as Map;
      final msg    = errors.values
          .map((v) => v is List ? v.first.toString() : v.toString())
          .join(', ');
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF021E16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        title: const Text("Crear usuario",
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(children: [
            _field("Nombre",   nombreController),
            const SizedBox(height: 14),
            _field("Correo",   emailController,
                keyboard: TextInputType.emailAddress),
            const SizedBox(height: 14),
            _field("Username", usernameController),
            const SizedBox(height: 14),
            _field("Contraseña",         passwordController,  obscure: true),
            const SizedBox(height: 14),
            _field("Confirmar contraseña", password2Controller, obscure: true,
              validator: (v) => v != passwordController.text
                  ? "Las contraseñas no coinciden"
                  : null,
            ),
            const SizedBox(height: 14),

            // Rol
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.greenAccent.withOpacity(0.2)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value:         selectedRol,
                  isExpanded:    true,
                  dropdownColor: const Color(0xFF0A2E20),
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(
                        value: 'USUARIO',
                        child: Text('Usuario')),
                    DropdownMenuItem(
                        value: 'ADMINISTRATIVO',
                        child: Text('Administrativo')),
                  ],
                  onChanged: (v) => setState(() => selectedRol = v!),
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: loading ? null : _create,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("Crear usuario",
                        style: TextStyle(color: Colors.black)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  TextFormField _field(
    String hint,
    TextEditingController controller, {
    bool obscure                       = false,
    TextInputType keyboard             = TextInputType.text,
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
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
      validator: validator ??
          (v) => v!.isEmpty ? "Campo requerido" : null,
    );
  }
}