from rest_framework import serializers
from bin.models import Bin
from bin.serializers.base_serializer import BaseSerializer

class BinUpdateSerializer(BaseSerializer):

    class Meta:
        model = Bin
        fields = ['color', 'location', 'status']