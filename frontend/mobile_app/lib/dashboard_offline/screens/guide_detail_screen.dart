import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recycling_guide_provider.dart';
import '../models/recycling_guide.dart';
import 'guide_form_screen.dart';

class GuideDetailScreen extends StatelessWidget {
  final RecyclingGuide guide;

  const GuideDetailScreen({Key? key, required this.guide}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B1E),
        elevation: 0,
        title: const Text('Detalle de Guía', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FF88)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Color(0xFF00FF88)),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => GuideFormScreen(guide: guide),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _showDeleteConfirmation(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00FF88).withOpacity(0.2),
                    const Color(0xFF0D1B1E),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.5)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    guide.icon,
                    style: const TextStyle(fontSize: 80),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    guide.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00FF88).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF00FF88)),
                    ),
                    child: Text(
                      guide.category,
                      style: const TextStyle(
                        color: Color(0xFF00FF88),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Descripción
            const Text(
              'Descripción',
              style: TextStyle(
                color: Color(0xFF00FF88),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2F33),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                guide.description,
                style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Información adicional
            const Text(
              'Información',
              style: TextStyle(
                color: Color(0xFF00FF88),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1A2F33),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow('Creado', _formatDate(guide.createdAt)),
                  const Divider(color: Colors.white24, height: 24),
                  _buildInfoRow('Actualizado', _formatDate(guide.updatedAt)),
                  const Divider(color: Colors.white24, height: 24),
                  _buildInfoRow('ID', guide.id.substring(0, 8)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60)),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A2F33),
        title: const Text('Eliminar Guía', style: TextStyle(color: Colors.white)),
        content: Text(
          '¿Estás seguro de que deseas eliminar "${guide.title}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<RecyclingGuideProvider>().deleteGuide(guide.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to home
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Guía eliminada correctamente'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}