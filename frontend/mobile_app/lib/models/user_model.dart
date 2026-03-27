class UserModel {
  final int    id;
  final String nombre;
  final String email;
  final String username;
  final String rol;
  final bool   estado;
  final String? imagen;

  const UserModel({
    required this.id,
    required this.nombre,
    required this.email,
    required this.username,
    required this.rol,
    required this.estado,
    this.imagen,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id:       json['id'],
    nombre:   json['nombre'],
    email:    json['email'],
    username: json['username'],
    rol:      json['rol'],
    estado:   json['estado'],
    imagen:   json['imagen'],
  );

  Map<String, dynamic> toJson() => {
    'id':       id,
    'nombre':   nombre,
    'email':    email,
    'username': username,
    'rol':      rol,
    'estado':   estado,
    'imagen':   imagen,
  };
}