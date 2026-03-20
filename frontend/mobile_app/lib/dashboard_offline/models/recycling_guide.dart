class RecyclingGuide {
  final String id;
  final String title;
  final String description;
  final String category;
  final String icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  RecyclingGuide({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.icon = '📋',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  RecyclingGuide copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RecyclingGuide(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'icon': icon,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory RecyclingGuide.fromMap(Map<String, dynamic> map) {
    return RecyclingGuide(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      category: map['category'],
      icon: map['icon'] ?? '📋',
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }
}