import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/models/bin_model.dart';
import 'package:mobile_app/providers/auth_provider.dart';
import 'package:mobile_app/services/bin_service.dart';

class BinEditScreen extends StatefulWidget {
  final BinModel bin;
  const BinEditScreen({super.key, required this.bin});

  @override
  State<BinEditScreen> createState() => _BinEditScreenState();
}

class _BinEditScreenState extends State<BinEditScreen> {
  late TextEditingController colorController;
  late TextEditingController locationController;
  late String selectedStatus;

  final _formKey = GlobalKey<FormState>();
  bool loading   = false;

  @override
  void initState() {
    super.initState();
    colorController    = TextEditingController(text: widget.bin.color);
    locationController = TextEditingController(text: widget.bin.location);
    selectedStatus     = widget.bin.status;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);
    final token = context.read<AuthProvider>().accessToken!;
    final res   = await BinService.updateBin(
      pk:       widget.bin.id,
      token:    token,
      color:    colorController.text.trim(),
      location: locationController.text.trim(),
      status:   selectedStatus,
    );
    setState(() => loading = false);

    if (!mounted) return;

    if (res['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Caneca actualizada.")));
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
        title: const Text("Editar caneca",
            style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(children: [
            _field("Color",     colorController),
            const SizedBox(height: 14),
            _field("Ubicación", locationController),
            const SizedBox(height: 14),

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
                  value:         selectedStatus,
                  isExpanded:    true,
                  dropdownColor: const Color(0xFF0A2E20),
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(value: 'active',   child: Text('Activa')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactiva')),
                  ],
                  onChanged: (v) => setState(() => selectedStatus = v!),
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
                onPressed: loading ? null : _save,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.black)
                    : const Text("Guardar cambios",
                        style: TextStyle(color: Colors.black)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  TextFormField _field(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText:  hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled:    true,
        fillColor: Colors.green.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator: (v) => v!.isEmpty ? "Campo requerido" : null,
    );
  }
}