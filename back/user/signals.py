from django.db.models.signals import post_save
from django.dispatch import receiver
from user.models.user_model import User
from user.permissions import asignar_permisos_por_rol


@receiver(post_save, sender=User)
def sync_permisos(sender, instance, **kwargs):
    if not kwargs.get('raw'):
        asignar_permisos_por_rol(instance)