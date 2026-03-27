from user.serializers.user_base_serializer import UserBaseSerializer


class UserAdminReadSerializer(UserBaseSerializer):
    """Lectura extendida para el admin — incluye fecha de modificación."""

    class Meta(UserBaseSerializer.Meta):
        fields           = UserBaseSerializer.Meta.fields + ('fecha_modificacion',)
        read_only_fields = fields