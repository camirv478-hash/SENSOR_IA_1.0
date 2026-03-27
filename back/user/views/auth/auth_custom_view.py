from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from user.serializers.auth.auth_custom_serializer import CustomTokenObtainSerializer, LogoutSerializer


class LoginView(TokenObtainPairView):
    permission_classes = [AllowAny]
    serializer_class   = CustomTokenObtainSerializer


class RefreshView(TokenRefreshView):
    permission_classes = [AllowAny]


class LogoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = LogoutSerializer(
            data    = request.data,
            context = {'request': request},
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'detail': 'Sesión cerrada correctamente.'})