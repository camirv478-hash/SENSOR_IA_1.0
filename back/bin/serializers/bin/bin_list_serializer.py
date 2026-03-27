from rest_framework import serializers
from bin.models import Bin

class BinListSerializer(serializers.ModelSerializer):

    class Meta:
        model = Bin
        fields = ['id', 'color', 'status']