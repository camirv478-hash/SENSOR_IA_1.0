import 'package:flutter/foundation.dart';
import '../models/recycling_guide.dart';
import '../services/recycling_guide_service.dart';

class RecyclingGuideProvider with ChangeNotifier {
  final RecyclingGuideService _service = RecyclingGuideService();
  List<RecyclingGuide> _guides = [];
  bool _isLoading = false;

  List<RecyclingGuide> get guides => _guides;
  bool get isLoading => _isLoading;

  void loadGuides() {
    _guides = _service.getAllGuides();
    notifyListeners();
  }

  Future<void> addGuide({
    required String title,
    required String description,
    required String category,
    String icon = '📋',
  }) async {
    _isLoading = true;
    notifyListeners();

    final guide = _service.createGuide(
      title: title,
      description: description,
      category: category,
      icon: icon,
    );

    _guides.add(guide);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateGuide({
    required String id,
    String? title,
    String? description,
    String? category,
    String? icon,
  }) async {
    _isLoading = true;
    notifyListeners();

    final updatedGuide = _service.updateGuide(
      id: id,
      title: title,
      description: description,
      category: category,
      icon: icon,
    );

    if (updatedGuide != null) {
      final index = _guides.indexWhere((g) => g.id == id);
      if (index != -1) {
        _guides[index] = updatedGuide;
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteGuide(String id) async {
    _isLoading = true;
    notifyListeners();

    _service.deleteGuide(id);
    _guides.removeWhere((guide) => guide.id == id);
    
    _isLoading = false;
    notifyListeners();
  }

  List<RecyclingGuide> getGuidesByCategory(String category) {
    return _service.getGuidesByCategory(category);
  }
}