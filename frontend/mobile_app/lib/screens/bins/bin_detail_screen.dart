import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/models/bin_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/services/bin_service.dart';
import 'package:mobile_app/screens/bins/bin_edit_screen.dart';

class BinDetailScreen extends StatefulWidget {
  final int binId;

  const BinDetailScreen({super.key, required this.binId});

  @override
  State<BinDetailScreen> createState() => _BinDetailScreenState();
}

class _BinDetailScreenState extends State<BinDetailScreen> {
  BinModel? bin;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().accessToken!;
    final res = await BinService.getBin(widget.binId, token);

    if (!mounted) return;

    if (res['success']) {
      setState(() {
        bin = BinModel.fromJson(res['data']);
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  Widget _row(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(k, style: const TextStyle(color: Colors.white54)),
            Text(v, style: const TextStyle(color: Colors.white)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF021E16),
      appBar: AppBar(
        title:
            const Text("Detalle", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        actions: [
          if (bin != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.greenAccent),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BinEditScreen(bin: bin!),
                  ),
                );
                if (result == true) _load();
              },
            )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : bin == null
              ? const Center(child: Text("No encontrada"))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _row("ID", bin!.id.toString()),
                      _row("Color", bin!.color),
                      _row("Ubicación", bin!.location),
                      _row("Estado",
                          bin!.isActive ? "Activa" : "Inactiva"),
                      _row("Creada", bin!.createdAtFormatted),
                    ],
                  ),
                ),
    );
  }
}