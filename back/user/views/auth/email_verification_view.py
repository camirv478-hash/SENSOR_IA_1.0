from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny
from rest_framework import status
from user.serializers.auth.email_verification_serializer import EmailVerificationSerializer


class EmailVerificationView(APIView):
    permission_classes = [AllowAny]   # sin autenticación

    def post(self, request):
        serializer = EmailVerificationSerializer(data=request.data)

        if serializer.is_valid():
            user = serializer.save()
            return Response(
                {"detail": f"Cuenta de {user.email} verificada correctamente."},
                status=status.HTTP_200_OK,
            )

        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)