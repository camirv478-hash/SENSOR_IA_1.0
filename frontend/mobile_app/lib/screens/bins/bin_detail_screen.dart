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
  bool      loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final token = context.read<AuthProvider>().accessToken!;
    final res   = await BinService.getBin(widget.binId, token);

    if (res['success']) {
      setState(() {
        bin     = BinModel.fromJson(res['data']);
        loading = false;
      });
    } else {
      setState(() => loading = false);
    }
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF021E16),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.greenAccent),
        title: const Text("Detalle de caneca",
            style: TextStyle(color: Colors.white)),
        actions: [
          if (bin != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.greenAccent),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BinEditScreen(bin: bin!),
                  ),
                );
                _load();
              },
            ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.greenAccent))
          : bin == null
              ? const Center(
                  child: Text("Caneca no encontrada.",
                      style: TextStyle(color: Colors.white54)))
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: Colors.greenAccent, width: 2),
                            color: Colors.green.withOpacity(0.15),
                          ),
                          child: const Icon(Icons.delete_outline,
                              color: Colors.greenAccent, size: 40),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.greenAccent.withOpacity(0.15)),
                        ),
                        child: Column(children: [
                          _infoRow("ID",        bin!.id.toString()),
                          const Divider(color: Colors.white12),
                          _infoRow("Color",     bin!.color),
                          const Divider(color: Colors.white12),
                          _infoRow("Ubicación", bin!.location),
                          const Divider(color: Colors.white12),
                          _infoRow("Estado",
                              bin!.isActive ? "Activa" : "Inactiva"),
                          if (bin!.createdAt != null) ...[
                            const Divider(color: Colors.white12),
                            _infoRow("Creada", bin!.createdAt!),
                          ],
                        ]),
                      ),
                    ],
                  ),
                ),
    );
  }
}