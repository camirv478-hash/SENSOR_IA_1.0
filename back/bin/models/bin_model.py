from django.db import models

class Bin(models.Model):

    class Status(models.TextChoices):
        ACTIVE   = 'active',   'Activa'
        INACTIVE = 'inactive', 'Inactiva'

    color      = models.CharField(max_length=50)
    location   = models.CharField(max_length=255)
    status     = models.CharField(
        max_length=10,
        choices=Status.choices,
        default=Status.ACTIVE,
    )
    created_at  = models.DateTimeField(auto_now_add=True)
    modified_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.color} - {self.location}"

    class Meta:
        permissions = [
            ("ver_bin",      "Puede ver canecas"),
            ("crear_bin",    "Puede crear canecas"),
            ("editar_bin",   "Puede editar canecas"),
            ("eliminar_bin", "Puede eliminar canecas"),
        ]