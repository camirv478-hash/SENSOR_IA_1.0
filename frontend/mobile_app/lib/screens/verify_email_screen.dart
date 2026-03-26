import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final TextEditingController _codeController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Limpiar mensajes previos
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().clearError();
    });
  }

  void _verify() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el código de verificación')),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    
    setState(() => _isLoading = true);

    final success = await auth.verifyEmail(code);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Verificación exitosa, mostrar mensaje y volver al login
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.successMessage ?? 'Email verificado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
      
      // Limpiar y volver al login
      auth.clearSuccess();
      Navigator.popUntil(context, (route) => route.isFirst);
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Código inválido'),
          backgroundColor: Colors.redAccent,
        ),
      );
      auth.clearError();
    }
  }

  void _resendCode() async {
    // TODO: Implementar reenvío de código
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código reenviado. Revisa tu correo.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final email = auth.pendingEmail ?? 'tu correo';

    return Scaffold(
      backgroundColor: const Color(0xFF021E16),
      appBar: AppBar(
        title: const Text('Verificar Email'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.email, size: 80, color: Colors.greenAccent),
              const SizedBox(height: 20),
              const Text(
                'Verifica tu correo electrónico',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Hemos enviado un código de 6 dígitos a:',
                style: TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                email,
                style: const TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: 'Código de 6 dígitos',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: Colors.green.withOpacity(0.1),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  onPressed: _isLoading ? null : _verify,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.black,
                          ),
                        )
                      : const Text(
                          'Verificar',
                          style: TextStyle(color: Colors.black),
                        ),
                ),
              ),
              const SizedBox(height: 15),
              TextButton(
                onPressed: _resendCode,
                child: const Text(
                  'Reenviar código',
                  style: TextStyle(color: Colors.greenAccent),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}