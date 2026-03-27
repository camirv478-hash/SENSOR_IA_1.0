import secrets

from django.db import transaction
from django.utils import timezone
from rest_framework import serializers

from user.models.email_change_model import EmailChangeRequest
from user.models.user_model import User
from user.services.email_service import send_email_change_code


class EmailChangeRequestSerializer(serializers.Serializer):

    new_email = serializers.EmailField()

    def validate_new_email(self, value):
        value = value.lower()
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError("Este correo ya está en uso.")
        return value

    def save(self):
        user = self.context['request'].user
        code = ''.join(secrets.choice("0123456789") for _ in range(6))

        EmailChangeRequest.objects.filter(user=user, is_used=False).update(is_used=True)

        EmailChangeRequest.objects.create(
            user       = user,
            new_email  = self.validated_data['new_email'],
            code       = code,
            expires_at = EmailChangeRequest.get_expiration_time(),
        )

        send_email_change_code(user.email, code)


class EmailChangeConfirmSerializer(serializers.Serializer):

    code = serializers.CharField(max_length=6, min_length=6)

    def validate(self, data):
        user = self.context['request'].user

        try:
            req = EmailChangeRequest.objects.filter(
                user    = user,
                is_used = False,
            ).latest('created_at')
        except EmailChangeRequest.DoesNotExist:
            raise serializers.ValidationError("No hay solicitud activa.")

        if req.expires_at < timezone.now():
            raise serializers.ValidationError("El código ha expirado.")

        if req.code.strip() != data['code'].strip():
            raise serializers.ValidationError("Código incorrecto.")

        data['request_instance'] = req
        return data

    @transaction.atomic
    def save(self):
        req  = self.validated_data['request_instance']
        user = req.user

        user.email = req.new_email.lower()
        user.save(update_fields=['email'])

        req.is_used = True
        req.save(update_fields=['is_used'])

        return user