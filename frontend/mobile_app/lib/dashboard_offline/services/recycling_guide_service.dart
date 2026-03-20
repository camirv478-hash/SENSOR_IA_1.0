import '../models/recycling_guide.dart';
import  'package:uuid/uuid.dart';

class RecyclingGuideService {
  final List<RecyclingGuide> _guides = [];
  final Uuid _uuid = const Uuid();

  // CREATE
  RecyclingGuide createGuide({
    required String title,
    required String description,
    required String category,
    String icon = '📋',
  }) {
    final guide = RecyclingGuide(
      id: _uuid.v4(),
      title: title,
      description: description,
      category: category,
      icon: icon,
    );
    _guides.add(guide);
    return guide;
  }

  // READ - Get all
  List<RecyclingGuide> getAllGuides() {
    return List.from(_guides);
  }

  // READ - Get by ID
  RecyclingGuide? getGuideById(String id) {
    try {
      return _guides.firstWhere((guide) => guide.id == id);
    } catch (e) {
      return null;
    }
  }

  // UPDATE
  RecyclingGuide? updateGuide({
    required String id,
    String? title,
    String? description,
    String? category,
    String? icon,
  }) {
    final index = _guides.indexWhere((guide) => guide.id == id);
    if (index == -1) return null;

    final updatedGuide = _guides[index].copyWith(
      title: title,
      description: description,
      category: category,
      icon: icon,
    );

    _guides[index] = updatedGuide;
    return updatedGuide;
  }

  // DELETE
  bool deleteGuide(String id) {
    final index = _guides.indexWhere((guide) => guide.id == id);
    if (index == -1) return false;
    
    _guides.removeAt(index);
    return true;
  }

  // Get by category
  List<RecyclingGuide> getGuidesByCategory(String category) {
    return _guides.where((guide) => guide.category == category).toList();
  }
}