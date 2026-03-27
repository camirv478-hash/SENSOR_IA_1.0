import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/models/user_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/services/user_service.dart';
import 'package:mobile_app/screens/users/user_create_screen.dart';
import 'package:mobile_app/screens/users/user_detail_screen.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  List<UserModel> users   = [];
  bool            loading = true;
  String          search  = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final token = context.read<AuthProvider>().accessToken!;
    final res   = await UserService.getUsers(token);

    if (res['success']) {
      final list = (res['data'] as List)
          .map((e) => UserModel.fromJson(e))
          .toList();
      setState(() { users = list; loading = false; });
    } else {
      setState(() => loading = false);
    }
  }

  Future<void> _delete(UserModel user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A2E20),
        title: const Text("Eliminar usuario",
            style: TextStyle(color: Colors.white)),
        content: Text("¿Eliminar a ${user.nombre}?",
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar",
                  style: TextStyle(color: Colors.white54))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Eliminar",
                  style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );

    if (confirm != true) return;

    final token = context.read<AuthProvider>().accessToken!;
    final res   = await UserService.deleteUser(user.id, token);

    if (!mounted) return;
    if (res['success']) {
      setState(() => users.removeWhere((u) => u.id == user.id));
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Usuario eliminado.")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo eliminar.")));
    }
  }

  List<UserModel> get _filtered => users
      .where((u) =>
          u.nombre.toLowerCase().contains(search.toLowerCase()) ||
          u.email.toLowerCase().contains(search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF021E16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        title: const Text("Usuarios",
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.greenAccent),
            onPressed: _load,
          ),
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.greenAccent),
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const UserCreateScreen()));
              _load();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Buscador
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText:   "Buscar por nombre o correo...",
                hintStyle:  const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search,
                    color: Colors.greenAccent),
                filled:    true,
                fillColor: Colors.green.withOpacity(0.08),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => search = v),
            ),
          ),

          const SizedBox(height: 8),

          // Lista
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Colors.greenAccent))
                : _filtered.isEmpty
                    ? const Center(
                        child: Text("Sin resultados.",
                            style: TextStyle(color: Colors.white54)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: Colors.greenAccent,
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filtered.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) =>
                              _UserTile(
                                user:     _filtered[i],
                                onTap:    () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UserDetailScreen(
                                          userId: _filtered[i].id),
                                    ),
                                  );
                                  _load();
                                },
                                onDelete: () => _delete(_filtered[i]),
                              ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  final UserModel    user;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _UserTile({
    required this.user,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: Colors.greenAccent.withOpacity(0.15)),
        ),
        child: Row(children: [
          CircleAvatar(
            backgroundColor: Colors.green.withOpacity(0.2),
            child: Text(
              user.nombre.isNotEmpty
                  ? user.nombre[0].toUpperCase()
                  : '?',
              style: const TextStyle(color: Colors.greenAccent),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.nombre,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600)),
                Text(user.email,
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(user.rol,
                    style: const TextStyle(
                        color: Colors.greenAccent, fontSize: 10)),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: user.estado
                      ? Colors.green.withOpacity(0.2)
                      : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user.estado ? "Activo" : "Inactivo",
                  style: TextStyle(
                      color: user.estado
                          ? Colors.greenAccent
                          : Colors.redAccent,
                      fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Colors.redAccent, size: 20),
            onPressed: onDelete,
          ),
        ]),
      ),
    );
  }
}