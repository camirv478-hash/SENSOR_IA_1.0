from django.contrib.auth.models import AbstractUser
from django.db import models


class User(AbstractUser):

    class Rol(models.TextChoices):
        ADMIN = 'ADMINISTRATIVO', 'Administrativo'
        USER  = 'USUARIO',        'Usuario'

    nombre             = models.CharField(max_length=150)
    email              = models.EmailField(unique=True)
    rol                = models.CharField(
                             max_length=20,
                             choices=Rol.choices,
                             default=Rol.USER,
                         )
    estado             = models.BooleanField(default=True)
    imagen             = models.ImageField(upload_to='usuarios/', blank=True, null=True)
    fecha_creacion     = models.DateTimeField(auto_now_add=True)
    fecha_modificacion = models.DateTimeField(auto_now=True)

    USERNAME_FIELD  = 'email'
    REQUIRED_FIELDS = ['username']

    
    def es_administrativo(self) -> bool:
        return self.rol == self.Rol.ADMIN

    def es_usuario(self) -> bool:
        return self.rol == self.Rol.USER

    def __str__(self):
        return f"{self.nombre} ({self.get_rol_display()})"

    class Meta:
        verbose_name        = 'Usuario'
        verbose_name_plural = 'Usuarios'

        permissions = [
            
            ("editar_usuario",     "Puede editar cualquier usuario"),
            ("desactivar_usuario", "Puede desactivar/activar usuarios"),
            ("ver_reportes",       "Puede ver y exportar reportes"),

           
            ("crear_registro",     "Puede crear sus propios registros"),

            
            ("ver_usuario",        "Puede ver el listado de usuarios"),
        ]