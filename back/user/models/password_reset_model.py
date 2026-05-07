import uuid
from django.db import models
from django.conf import settings
from django.utils import timezone
from datetime import timedelta


class PasswordReset(models.Model):
    user       = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    token      = models.UUIDField(default=uuid.uuid4, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()               
    is_used    = models.BooleanField(default=False)

    @staticmethod
    def get_expiration_time(minutes=30):
        return timezone.now() + timedelta(minutes=minutes)