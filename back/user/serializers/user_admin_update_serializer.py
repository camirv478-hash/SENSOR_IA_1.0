from rest_framework import serializers

from user.models.user_model import User


class UserAdminUpdateSerializer(serializers.ModelSerializer):
    """Permite al admin cambiar rol y estado de cualquier usuario."""

    class Meta:
        model  = User
        fields = ('rol', 'estado')