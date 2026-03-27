from rest_framework import serializers

class BaseSerializer(serializers.ModelSerializer):

    def validate(self, attrs):
        # Hook global para validaciones comunes
        return super().validate(attrs)

    def create(self, validated_data):
        instance = super().create(validated_data)
        return instance

    def update(self, instance, validated_data):
        instance = super().update(instance, validated_data)
        return instance