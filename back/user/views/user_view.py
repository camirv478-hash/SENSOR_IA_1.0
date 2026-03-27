from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework import status

from user.filters import UserFilter
from user.models.user_model import User
from user.permissions import IsAdministrativo
from user.serializers.user_create_serializer import UserCreateSerializer
from user.serializers.user_read_serializer import UserReadSerializer
from user.serializers.user_admin_read_serializer import UserAdminReadSerializer
from user.serializers.user_profile_update_serializer import UserProfileUpdateSerializer
from user.serializers.user_admin_update_serializer import UserAdminUpdateSerializer
from user.serializers.username_change_serializer import UsernameChangeSerializer


# ── Registro ──────────────────────────────────────────────────────────────────

class UserRegisterView(APIView):
    permission_classes = [AllowAny]
    parser_classes     = [MultiPartParser, FormParser]

    def post(self, request):
        serializer = UserCreateSerializer(
            data    = request.data,
            context = {'request': request},
        )
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        return Response(
            UserReadSerializer(user).data,
            status = status.HTTP_201_CREATED,
        )


# ── Perfil propio ─────────────────────────────────────────────────────────────

class UserMeView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes     = [MultiPartParser, FormParser]

    def get(self, request):
        return Response(UserReadSerializer(request.user).data)

    def patch(self, request):
        serializer = UserProfileUpdateSerializer(
            instance = request.user,
            data     = request.data,
            partial  = True,
            context  = {'request': request},
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(UserReadSerializer(request.user).data)


class UsernameChangeView(APIView):
    permission_classes = [IsAuthenticated]

    def patch(self, request):
        serializer = UsernameChangeSerializer(
            instance = request.user,
            data     = request.data,
            context  = {'request': request},
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response({'detail': 'Username actualizado correctamente.'})


# ── Admin ─────────────────────────────────────────────────────────────────────

class UserListView(APIView):
    permission_classes = [IsAuthenticated, IsAdministrativo]

    def get(self, request):
        queryset  = User.objects.all().order_by('-fecha_creacion')
        filterset = UserFilter(request.GET, queryset=queryset)
        if filterset.is_valid():
            queryset = filterset.qs
        return Response(UserAdminReadSerializer(queryset, many=True).data)


class UserDetailView(APIView):
    permission_classes = [IsAuthenticated, IsAdministrativo]

    def _get_user(self, pk):
        try:
            return User.objects.get(pk=pk)
        except User.DoesNotExist:
            return None

    def get(self, request, pk):
        user = self._get_user(pk)
        if not user:
            return Response(
                {'detail': 'Usuario no encontrado.'},
                status = status.HTTP_404_NOT_FOUND,
            )
        return Response(UserAdminReadSerializer(user).data)

    def patch(self, request, pk):
        user = self._get_user(pk)
        if not user:
            return Response(
                {'detail': 'Usuario no encontrado.'},
                status = status.HTTP_404_NOT_FOUND,
            )
        serializer = UserAdminUpdateSerializer(
            instance = user,
            data     = request.data,
            partial  = True,
            context  = {'request': request},
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()
        return Response(UserAdminReadSerializer(user).data)

    def delete(self, request, pk):
        user = self._get_user(pk)
        if not user:
            return Response(
                {'detail': 'Usuario no encontrado.'},
                status = status.HTTP_404_NOT_FOUND,
            )
        if user == request.user:
            return Response(
                {'detail': 'No puedes eliminar tu propia cuenta.'},
                status = status.HTTP_400_BAD_REQUEST,
            )
        user.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)