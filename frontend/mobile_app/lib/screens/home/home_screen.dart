import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../login/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: const Color(0xFF021E16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "SensorIA",
          style: TextStyle(color: Colors.greenAccent),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (!context.mounted) return;
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Tarjeta de perfil
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.15),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.greenAccent.withOpacity(0.2),
                    child: user?.imagen != null
                        ? ClipOval(
                            child: Image.network(
                              user!.imagen!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Icon(Icons.person,
                            color: Colors.greenAccent, size: 30),
                  ),
                  const SizedBox(width: 15),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.nombre ?? 'Usuario',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        // Badge de rol
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: user?.esAdministrativo == true
                                ? Colors.orangeAccent.withOpacity(0.2)
                                : Colors.greenAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            user?.esAdministrativo == true
                                ? 'Administrativo'
                                : 'Usuario',
                            style: TextStyle(
                              color: user?.esAdministrativo == true
                                  ? Colors.orangeAccent
                                  : Colors.greenAccent,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Placeholder del contenido principal
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.sensors,
                      size: 60,
                      color: Colors.greenAccent.withOpacity(0.5),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      "Panel principal",
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Aquí irán tus módulos de SensorIA",
                      style: TextStyle(color: Colors.white38),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}