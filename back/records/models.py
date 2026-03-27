from django.db import models
from django.conf import settings
from residuos.models import Residue

class RecyclingRecord(models.Model):
    user = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name='recycling_records'
    )
    residue = models.ForeignKey(
        Residue,
        on_delete=models.CASCADE,
        related_name='recycling_records'
    )
    date = models.DateTimeField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user} - {self.residue} - {self.date}"