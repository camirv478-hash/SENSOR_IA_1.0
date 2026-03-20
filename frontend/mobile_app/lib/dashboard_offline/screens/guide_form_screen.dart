import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recycling_guide_provider.dart';
import '../models/recycling_guide.dart';

class GuideFormScreen extends StatefulWidget {
  final RecyclingGuide? guide;

  const GuideFormScreen({Key? key, this.guide}) : super(key: key);

  @override
  State<GuideFormScreen> createState() => _GuideFormScreenState();
}

class _GuideFormScreenState extends State<GuideFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _categoryController;
  late String _selectedIcon;
  bool _isEditing = false;

  final List<String> _icons = ['📋', '♻️', '🥛', '📄', '', '', '💡', '🌱'];

  @override
  void initState() {
    super.initState();
    _isEditing = widget.guide != null;
    _titleController = TextEditingController(text: widget.guide?.title ?? '');
    _descriptionController = TextEditingController(text: widget.guide?.description ?? '');
    _categoryController = TextEditingController(text: widget.guide?.category ?? '');
    _selectedIcon = widget.guide?.icon ?? '📋';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B1E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1B1E),
        elevation: 0,
        title: Text(
          _isEditing ? 'Editar Guía' : 'Nueva Guía',
          style: const TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FF88)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de Icono
              const Text(
                'Selecciona un ícono',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _icons.map((icon) {
                  final isSelected = _selectedIcon == icon;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = icon),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? const Color(0xFF00FF88).withOpacity(0.3)
                            : const Color(0xFF1A2F33),
                        border: Border.all(
                          color: isSelected 
                              ? const Color(0xFF00FF88)
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(icon, style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Campo Título
              const Text(
                'Título',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ej: Guía de Vidrio',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1A2F33),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00FF88), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Campo Categoría
              const Text(
                'Categoría',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _categoryController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ej: Reciclaje Doméstico',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1A2F33),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00FF88), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una categoría';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Campo Descripción
              const Text(
                'Descripción',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: Colors.white),
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Describe la guía de reciclaje...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1A2F33),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF00FF88), width: 2),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa una descripción';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 32),
              
              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _saveGuide,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00FF88),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isEditing ? 'Actualizar Guía' : 'Crear Guía',
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveGuide() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<RecyclingGuideProvider>();
      
      if (_isEditing && widget.guide != null) {
        provider.updateGuide(
          id: widget.guide!.id,
          title: _titleController.text,
          description: _descriptionController.text,
          category: _categoryController.text,
          icon: _selectedIcon,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Guía actualizada correctamente'),
            backgroundColor: Color(0xFF00FF88),
          ),
        );
      } else {
        provider.addGuide(
          title: _titleController.text,
          description: _descriptionController.text,
          category: _categoryController.text,
          icon: _selectedIcon,
        );
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Guía creada correctamente'),
            backgroundColor: Color(0xFF00FF88),
          ),
        );
      }
      
      Navigator.pop(context);
    }
  }
}