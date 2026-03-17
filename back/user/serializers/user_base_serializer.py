from rest_framework import serializers
from user.models.user_model import User


class UserBaseSerializer(serializers.ModelSerializer):

    class Meta:
        model  = User
        fields = (
            'id',
            'username',
            'nombre',
            'email',
            'rol',
            'estado',
            'imagen',
            'fecha_creacion',
        )
        read_only_fields = fields