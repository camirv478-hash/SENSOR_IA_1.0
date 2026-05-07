# users/models/email_verification.py

from django.db import models
from django.utils import timezone
from datetime import timedelta
from user.models.user_model import User
from django.conf import settings


class EmailVerification(models.Model):
    user       = models.ForeignKey(
                     settings.AUTH_USER_MODEL, 
                     on_delete=models.CASCADE,
                     related_name='email_verifications'
                 )
    code        = models.CharField(max_length=6)
    created_at  = models.DateTimeField(auto_now_add=True)
    expires_at  = models.DateTimeField()
    is_used     = models.BooleanField(default=False)  
    is_verified = models.BooleanField(default=False)   
    verified_at = models.DateTimeField(null=True, blank=True) 

    def is_expired(self):
        return timezone.now() > self.expires_at

    @staticmethod
    def get_expiration_time(minutes=10):
        return timezone.now() + timedelta(minutes=minutes)
