from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny

from user.serializers.auth.password_reset_serializer import (
    PasswordResetRequestSerializer,
    PasswordResetConfirmSerializer,
)


class PasswordResetRequestView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = PasswordResetRequestSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'detail': 'Si el correo existe, recibirás un enlace.'})


class PasswordResetConfirmView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = PasswordResetConfirmSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'detail': 'Contraseña actualizada correctamente.'})