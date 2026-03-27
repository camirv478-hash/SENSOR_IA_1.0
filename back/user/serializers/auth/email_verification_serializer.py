from rest_framework import serializers
from django.utils import timezone
from django.db import transaction
from user.models.email_verification_model import EmailVerification


class EmailVerificationSerializer(serializers.Serializer):
    email = serializers.EmailField()               # <-- identifica al usuario
    code  = serializers.CharField(max_length=6, min_length=6)

    def validate(self, data):
        try:
            verification = EmailVerification.objects.select_related('user').get(
                user__email=data['email'],
                is_used=False,
            )
        except EmailVerification.DoesNotExist:
            raise serializers.ValidationError("No hay verificación activa para este correo.")

        if verification.is_expired():
            raise serializers.ValidationError("El código ha expirado.")

        if verification.code.strip() != data['code'].strip():
            raise serializers.ValidationError("Código incorrecto.")

        data['verification_instance'] = verification
        return data

    @transaction.atomic
    def save(self):
        verification = self.validated_data['verification_instance']
        user         = verification.user

        verification.is_used     = True
        verification.is_verified = True
        verification.verified_at = timezone.now()
        verification.save(update_fields=['is_used', 'is_verified', 'verified_at'])

        user.estado = True
        user.save(update_fields=['estado'])

        return user