import secrets

from django.contrib.auth.password_validation import validate_password
from django.db import transaction
from rest_framework import serializers

from user.models.email_verification_model import EmailVerification
from user.models.user_model import User
from user.services.email_service import send_verification_email


class UserCreateSerializer(serializers.ModelSerializer):

    password = serializers.CharField(
        write_only = True,
        validators = [validate_password],
    )
    password2 = serializers.CharField(write_only=True)

    class Meta:
        model  = User
        fields = (
            'nombre',
            'email',
            'username',
            'rol',
            'password',
            'password2',
            'imagen',
        )

    def validate_email(self, value):
        value = value.lower()
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Ya existe un usuario con este email.")
        return value

    def validate(self, data):
        if data['password'] != data['password2']:
            raise serializers.ValidationError(
                {"password": "Las contraseñas no coinciden."}
            )
        return data

    @transaction.atomic
    def create(self, validated_data):
        validated_data.pop('password2')
        password = validated_data.pop('password')

        user = User(**validated_data, estado=False)  # inactivo hasta verificar email
        user.set_password(password)
        user.save()

        EmailVerification.objects.filter(user=user, is_used=False).delete()

        code = ''.join(secrets.choice("0123456789") for _ in range(6))
        EmailVerification.objects.create(
            user       = user,
            code       = code,
            expires_at = EmailVerification.get_expiration_time(),
        )

        send_verification_email(user.email, code)

        return user