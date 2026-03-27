import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/models/user_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/services/user_service.dart';

class UserDetailScreen extends StatefulWidget {
  final int userId;
  const UserDetailScreen({super.key, required this.userId});

  @override
  State<UserDetailScreen> createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  UserModel? user;
  bool       loading = true;
  String?    selectedRol;
  bool?      selectedEstado;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().accessToken!;
    final res   = await UserService.getUser(widget.userId, token);

    if (res['success']) {
      final u = UserModel.fromJson(res['data']);
      setState(() {
        user            = u;
        selectedRol     = u.rol;
        selectedEstado  = u.estado;
        loading         = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  Future<void> _save() async {
    final token = context.read<AuthProvider>().accessToken!;
    final res   = await UserService.updateUser(
      pk:          widget.userId,
      accessToken: token,
      data: {
        'rol':    selectedRol,
        'estado': selectedEstado,
      },
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(res['success']
          ? 'Usuario actualizado.'
          : 'Error al actualizar.'),
    ));

    if (res['success']) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF021E16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        title: const Text("Detalle de usuario",
            style: TextStyle(color: Colors.white)),
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent))
          : user == null
              ? const Center(
                  child: Text("Usuario no encontrado.",
                      style: TextStyle(color: Colors.white54)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar + info
                      Center(
                        child: Column(children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor:
                                Colors.green.withOpacity(0.2),
                            child: Text(
                              user!.nombre.isNotEmpty
                                  ? user!.nombre[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 28),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(user!.nombre,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          Text(user!.email,
                              style: const TextStyle(
                                  color: Colors.white54)),
                          Text('@${user!.username}',
                              style: const TextStyle(
                                  color: Colors.white38,
                                  fontSize: 12)),
                        ]),
                      ),

                      const SizedBox(height: 30),
                      const Divider(color: Colors.white12),
                      const SizedBox(height: 20),

                      const Text("Editar permisos",
                          style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              letterSpacing: 1.2)),

                      const SizedBox(height: 16),

                      // Rol
                      const Text("Rol",
                          style: TextStyle(
                              color: Colors.white54, fontSize: 12)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12),
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
                            onChanged: (v) =>
                                setState(() => selectedRol = v),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Estado
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.greenAccent.withOpacity(0.2)),
                        ),
                        child: SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text("Cuenta activa",
                              style: TextStyle(color: Colors.white)),
                          subtitle: Text(
                            selectedEstado! ? "Activo" : "Inactivo",
                            style: TextStyle(
                                color: selectedEstado!
                                    ? Colors.greenAccent
                                    : Colors.redAccent,
                                fontSize: 12),
                          ),
                          value:          selectedEstado!,
                          activeColor:    Colors.greenAccent,
                          onChanged: (v) =>
                              setState(() => selectedEstado = v),
                        ),
                      ),

                      const SizedBox(height: 30),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.greenAccent,
                            padding: const EdgeInsets.symmetric(
                                vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(12)),
                          ),
                          onPressed: _save,
                          child: const Text("Guardar cambios",
                              style: TextStyle(color: Colors.black)),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}