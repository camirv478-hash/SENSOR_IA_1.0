import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/screens/login/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nombreController;
  bool loading = false;
  bool editing = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    nombreController = TextEditingController(text: user?.nombre ?? '');
  }

  Future<void> _save() async {
    setState(() => loading = true);
    final auth    = context.read<AuthProvider>();
    final success = await auth.updateProfile(nombreController.text.trim());
    setState(() { loading = false; editing = false; });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(success
          ? 'Perfil actualizado.'
          : auth.errorMessage ?? 'Error al actualizar.'),
    ));
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      backgroundColor: const Color(0xFF021E16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Perfil",
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(editing ? Icons.close : Icons.edit,
                color: Colors.greenAccent),
            onPressed: () => setState(() => editing = !editing),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),

            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.green.withOpacity(0.2),
              child: const Icon(Icons.person,
                  color: Colors.greenAccent, size: 45),
            ),

            const SizedBox(height: 15),

            Text(user?.nombre ?? '',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(user?.email ?? '',
                style: const TextStyle(color: Colors.white54)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(user?.rol ?? '',
                  style: const TextStyle(
                      color: Colors.greenAccent, fontSize: 12)),
            ),

            const SizedBox(height: 30),

            if (editing) ...[
              TextField(
                controller: nombreController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText:  "Nombre",
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled:    true,
                  fillColor: Colors.green.withOpacity(0.1),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: loading ? null : _save,
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : const Text("Guardar",
                          style: TextStyle(color: Colors.black)),
                ),
              ),
            ],

            const Spacer(),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text("Cerrar sesión"),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}