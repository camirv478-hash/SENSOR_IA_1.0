from rest_framework import serializers

from user.models.user_model import User


class UserProfileUpdateSerializer(serializers.ModelSerializer):

    class Meta:
        model  = User
        fields = ('nombre', 'imagen')

    def validate_imagen(self, value):
        if value:
            allowed = ['image/jpeg', 'image/png', 'image/webp']
            if value.content_type not in allowed:
                raise serializers.ValidationError(
                    "Solo se permiten imágenes JPG, PNG o WEBP."
                )
            if value.size > 2 * 1024 * 1024:
                raise serializers.ValidationError(
                    "La imagen no puede superar 2MB."
                )
        return value