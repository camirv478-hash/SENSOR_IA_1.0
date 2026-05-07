import uuid

from django.contrib.auth.password_validation import validate_password
from django.db import transaction
from django.utils import timezone
from rest_framework import serializers
from rest_framework.exceptions import ValidationError

from user.models.password_reset_model import PasswordReset
from user.models.user_model import User
from user.services.email_service import send_password_reset_email


class PasswordResetRequestSerializer(serializers.Serializer):

    email = serializers.EmailField()

    def save(self):
        email = self.validated_data['email'].lower()

        try:
            user = User.objects.get(email__iexact=email)
        except User.DoesNotExist:
            return  # no revelar si el correo existe

        PasswordReset.objects.filter(user=user, is_used=False).update(is_used=True)

        token = uuid.uuid4()

        PasswordReset.objects.create(
            user       = user,
            token      = token,
            expires_at = PasswordReset.get_expiration_time(),
        )

        send_password_reset_email(user.email, token)


class PasswordResetConfirmSerializer(serializers.Serializer):

    token    = serializers.UUIDField()
    password = serializers.CharField(
        write_only = True,
        validators = [validate_password],
    )

    def validate(self, data):
        try:
            reset = PasswordReset.objects.get(
                token   = data['token'],
                is_used = False,
            )
        except PasswordReset.DoesNotExist:
            raise ValidationError("Token inválido o ya utilizado.")

        if reset.expires_at < timezone.now():
            raise ValidationError("Token expirado.")

        data['reset_instance'] = reset
        return data

    @transaction.atomic
    def save(self):
        reset = self.validated_data['reset_instance']
        user  = reset.user

        user.set_password(self.validated_data['password'])
        user.save(update_fields=['password'])

        reset.is_used = True
        reset.save(update_fields=['is_used'])

        return user