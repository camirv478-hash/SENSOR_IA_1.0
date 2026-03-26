class UserModel {
  final int id;
  final String username;
  final String email;
  final String nombre;
  final String rol;
  final bool estado;
  final String? imagen;
  final String? fechaCreacion;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.nombre,
    required this.rol,
    required this.estado,
    this.imagen,
    this.fechaCreacion,
  });

  /// Desde JSON (respuesta del backend Django)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id:            json['id'],
      username:      json['username'] ?? '',
      email:         json['email'],
      nombre:        json['nombre'] ?? '',
      rol:           json['rol'] ?? 'USUARIO',
      estado:        json['estado'] ?? true,
      imagen:        json['imagen'],
      fechaCreacion: json['fecha_creacion'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id':             id,
        'username':       username,
        'email':          email,
        'nombre':         nombre,
        'rol':            rol,
        'estado':         estado,
        'imagen':         imagen,
        'fecha_creacion': fechaCreacion,
      };

  bool get esAdministrativo => rol == 'ADMINISTRATIVO';
  bool get esUsuario         => rol == 'USUARIO';
}