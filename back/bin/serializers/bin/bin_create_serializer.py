from rest_framework import serializers
from bin.models import Bin
from bin.serializers.base_serializer import BaseSerializer

class BinCreateSerializer(BaseSerializer):

    class Meta:
        model = Bin
        fields = ['id', 'color', 'location', 'status']