from django.db import models
from bin.models import Bin
class Residue(models.Model):
    name = models.CharField(max_length=100)
    type = models.CharField(max_length=100)
    bin = models.ForeignKey(
        Bin,
        on_delete=models.CASCADE,
        related_name='residues'
    )
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.name