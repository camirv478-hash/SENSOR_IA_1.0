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
  List<BinModel> bins    = [];
  bool           loading = true;
  String         search  = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final token = context.read<AuthProvider>().accessToken!;
    final res   = await BinService.getBins(token);

    if (res['success']) {
      setState(() {
        bins    = (res['data'] as List)
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
            "¿Eliminar la caneca ${bin.color} en ${bin.location ?? 'sin ubicación'}?",
            style: const TextStyle(color: Colors.white70)),
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
    final res   = await BinService.deleteBin(bin.id, token);

    if (!mounted) return;

    if (res['success']) {
      setState(() => bins.removeWhere((b) => b.id == bin.id));
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Caneca eliminada.")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo eliminar.")));
    }
  }

  List<BinModel> get _filtered => bins.where((b) =>
      b.color.toLowerCase().contains(search.toLowerCase()) ||
      (b.location ?? '').toLowerCase().contains(search.toLowerCase())).toList();

  Color _colorFromName(String name) {
    final map = {
      'rojo': Colors.red,       'red': Colors.red,
      'azul': Colors.blue,      'blue': Colors.blue,
      'verde': Colors.green,    'green': Colors.green,
      'amarillo': Colors.amber, 'yellow': Colors.amber,
      'gris': Colors.grey,      'gray': Colors.grey,
      'negro': Colors.black87,  'black': Colors.black87,
      'blanco': Colors.white,   'white': Colors.white,
      'naranja': Colors.orange, 'orange': Colors.orange,
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
        title: const Text("Canecas",
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.greenAccent),
            onPressed: _load,
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.greenAccent),
            onPressed: () async {
              await Navigator.push(context,
                  MaterialPageRoute(
                      builder: (_) => const BinCreateScreen()));
              _load();
            },
          ),
        ],
      ),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: TextField(
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText:   "Buscar por color o ubicación...",
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

        Expanded(
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(
                      color: Colors.greenAccent))
              : _filtered.isEmpty
                  ? const Center(
                      child: Text("Sin canecas registradas.",
                          style: TextStyle(color: Colors.white54)))
                  : RefreshIndicator(
                      onRefresh: _load,
                      color: Colors.greenAccent,
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: 8),
                        itemBuilder: (_, i) {
                          final bin = _filtered[i];
                          return GestureDetector(
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
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.greenAccent
                                        .withOpacity(0.15)),
                              ),
                              child: Row(children: [
                                Container(
                                  width: 40, height: 40,
                                  decoration: BoxDecoration(
                                    color: _colorFromName(bin.color)
                                        .withOpacity(0.3),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: _colorFromName(bin.color),
                                        width: 2),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(bin.color,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight:
                                                  FontWeight.w600)),
                                      Text(
                                        bin.location ?? 'Sin ubicación',
                                        style: const TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: bin.isActive
                                            ? Colors.green.withOpacity(0.2)
                                            : Colors.red.withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        bin.isActive
                                            ? "Activa"
                                            : "Inactiva",
                                        style: TextStyle(
                                            color: bin.isActive
                                                ? Colors.greenAccent
                                                : Colors.redAccent,
                                            fontSize: 10),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.redAccent,
                                          size: 20),
                                      onPressed: () => _delete(bin),
                                    ),
                                  ],
                                ),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
        ),
      ]),
    );
  }
}