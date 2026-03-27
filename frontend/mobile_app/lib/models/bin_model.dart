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
      color: json['color'] as String,
      location: json['location'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  bool get isActive => status == 'active';
}