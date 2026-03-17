from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated

from user.serializers.auth.email_change_serializer import (
    EmailChangeRequestSerializer,
    EmailChangeConfirmSerializer,
)


class EmailChangeRequestView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = EmailChangeRequestSerializer(
            data    = request.data,
            context = {'request': request},
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'detail': 'Código enviado al nuevo correo.'})


class EmailChangeConfirmView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = EmailChangeConfirmSerializer(
            data    = request.data,
            context = {'request': request},
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'detail': 'Correo actualizado correctamente.'})