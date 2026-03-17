from datetime import timedelta
from django.utils import timezone
from django.db import models
from django.conf import settings

class EmailChangeRequest(models.Model):
    user       = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE)
    new_email  = models.EmailField()
    code       = models.CharField(max_length=6)
    created_at = models.DateTimeField(auto_now_add=True)
    expires_at = models.DateTimeField()    
    is_used    = models.BooleanField(default=False)

    @staticmethod
    def get_expiration_time(minutes=10):
        return timezone.now() + timedelta(minutes=minutes)