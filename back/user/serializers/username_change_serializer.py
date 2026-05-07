from rest_framework import serializers

from user.models.user_model import User


class UsernameChangeSerializer(serializers.ModelSerializer):

    class Meta:
        model  = User
        fields = ('username',)

    def validate_username(self, value):
        value = value.strip().lower()
        user  = self.context['request'].user
        if User.objects.filter(username__iexact=value).exclude(id=user.id).exists():
            raise serializers.ValidationError("Este username ya está en uso.")
        return value