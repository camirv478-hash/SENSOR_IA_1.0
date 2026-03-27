from rest_framework.views import APIView
from rest_framework.response import Response
from bin.models import Bin
from bin.serializers.bin.bin_list_serializer import BinListSerializer
from bin.permissions.permissions import CanVerBin

class BinListView(APIView):
    permission_classes = [CanVerBin]

    def get(self, request):
        bins = Bin.objects.all()
        serializer = BinListSerializer(bins, many=True)
        return Response(serializer.data)