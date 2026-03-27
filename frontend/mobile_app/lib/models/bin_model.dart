import 'package:intl/intl.dart';

class BinModel {
  final int id;
  final String color;
  final String location;
  final String status;
  final DateTime createdAt;

  const BinModel({
    required this.id,
    required this.color,
    required this.location,
    required this.status,
    required this.createdAt,
  });

  factory BinModel.fromJson(Map<String, dynamic> json) {
    return BinModel(
      id: json['id'] as int,

      // 🔥 DEFENSIVO (evita null crash)
      color: json['color']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      status: json['status']?.toString() ?? 'inactive',

      // 🔥 DEFENSIVO para fechas
      createdAt:
          DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isActive => status == 'active';

  String get createdAtFormatted {
    final local = createdAt.toLocal();
    return DateFormat('dd/MM/yyyy HH:mm').format(local);
  }
}