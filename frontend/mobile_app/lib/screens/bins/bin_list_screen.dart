import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/models/bin_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/services/bin_service.dart';
import 'package:mobile_app/screens/bins/bin_create_screen.dart';
import 'package:mobile_app/screens/bins/bin_detail_screen.dart';

class BinListScreen extends StatefulWidget {
  const BinListScreen({super.key});

  @override
  State<BinListScreen> createState() => _BinListScreenState();
}

class _BinListScreenState extends State<BinListScreen> {
  List<BinModel> bins = [];
  bool loading = true;
  String search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);

    final token = context.read<AuthProvider>().accessToken!;
    final res = await BinService.getBins(token);

    if (!mounted) return;

    if (res['success']) {
      setState(() {
        bins = (res['data'] as List)
            .map((e) => BinModel.fromJson(e))
            .toList();
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  Future<void> _delete(BinModel bin) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF0A2E20),
        title: const Text("Eliminar caneca",
            style: TextStyle(color: Colors.white)),
        content: Text(
          "¿Eliminar la caneca ${bin.color} en ${bin.location}?",
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar",
                style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Eliminar",
                style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final token = context.read<AuthProvider>().accessToken!;
    final res = await BinService.deleteBin(bin.id, token);

    if (!mounted) return;

    if (res['success']) {
      setState(() => bins.removeWhere((b) => b.id == bin.id));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Caneca eliminada.")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No se pudo eliminar.")),
      );
    }
  }

  List<BinModel> get _filtered => bins.where((b) =>
      b.color.toLowerCase().contains(search.toLowerCase()) ||
      b.location.toLowerCase().contains(search.toLowerCase())).toList();

  Color _colorFromName(String name) {
    final map = {
      'rojo': Colors.red,
      'azul': Colors.blue,
      'verde': Colors.green,
      'amarillo': Colors.amber,
      'gris': Colors.grey,
      'negro': Colors.black87,
      'blanco': Colors.white,
      'naranja': Colors.orange,
    };
    return map[name.toLowerCase()] ?? Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF021E16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        title:
            const Text("Canecas", style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.greenAccent),
            onPressed: _load,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.greenAccent),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const BinCreateScreen(),
                ),
              );
              if (result == true) _load();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (v) => setState(() => search = v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Buscar...",
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: Colors.green.withOpacity(0.08),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          Expanded(
            child: loading
                ? const Center(
                    child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _filtered.length,
                    itemBuilder: (_, i) {
                      final bin = _filtered[i];
                      return ListTile(
                        title: Text(bin.color,
                            style: const TextStyle(color: Colors.white)),
                        subtitle: Text(bin.location,
                            style:
                                const TextStyle(color: Colors.white54)),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BinDetailScreen(binId: bin.id),
                            ),
                          );
                          _load();
                        },
                        trailing: IconButton(
                          icon: const Icon(Icons.delete,
                              color: Colors.redAccent),
                          onPressed: () => _delete(bin),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}