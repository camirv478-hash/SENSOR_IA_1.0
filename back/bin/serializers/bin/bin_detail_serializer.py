from rest_framework import serializers
from bin.models import Bin

class BinDetailSerializer(serializers.ModelSerializer):

    class Meta:
        model = Bin
        fields = '__all__'