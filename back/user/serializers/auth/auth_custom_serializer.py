from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer
from rest_framework_simplejwt.tokens import RefreshToken


class CustomTokenObtainSerializer(TokenObtainPairSerializer):
    """Login: email + password → access + refresh con claims custom."""

    @classmethod
    def get_token(cls, user):
        token = super().get_token(user)

        token['nombre'] = user.nombre
        token['email']  = user.email
        token['rol']    = user.rol
        token['estado'] = user.estado

        return token

    def validate(self, attrs):
        data = super().validate(attrs)

        # Verificó correo pero un admin lo desactivó
        if not self.user.estado and self.user.email_verifications.filter(is_verified=True).exists():
            raise serializers.ValidationError(
                "Tu cuenta está desactivada. Contacta al administrador."
            )

        # Nunca verificó el correo
        if not self.user.email_verifications.filter(is_verified=True).exists():
            raise serializers.ValidationError(
                "Debes verificar tu correo antes de iniciar sesión."
            )

        return data

class LogoutSerializer(serializers.Serializer):
    """Recibe el refresh token y lo añade a la blacklist."""

    refresh = serializers.CharField()

    def validate(self, data):
        try:
            token = RefreshToken(data['refresh'])
            token.verify()
        except Exception:
            raise serializers.ValidationError("Token inválido o expirado.")

        data['token_instance'] = token
        return data

    def save(self):
        self.validated_data['token_instance'].blacklist()
