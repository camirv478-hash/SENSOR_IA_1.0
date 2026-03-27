from django.contrib.auth.models import Permission


PERMISOS_ADMIN = [
    # usuarios
    "ver_usuario",
    "editar_usuario",
    "desactivar_usuario",
    "ver_reportes",
    # bin
    "ver_bin",
    "crear_bin",
    "editar_bin",
    "eliminar_bin",
]

PERMISOS_USUARIO = [
    # usuarios
    "ver_usuario",
    "crear_registro",
    # bin
    "ver_bin",
]


def asignar_permisos_por_rol(user):
    lista    = PERMISOS_ADMIN if user.es_administrativo() else PERMISOS_USUARIO
    permisos = Permission.objects.filter(codename__in=lista)
    user.user_permissions.set(permisos)