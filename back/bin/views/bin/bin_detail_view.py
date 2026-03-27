from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from bin.models import Bin
from bin.serializers.bin.bin_detail_serializer import BinDetailSerializer
from bin.permissions.permissions import CanVerBin

class BinDetailView(APIView):
    permission_classes = [CanVerBin]

    def get(self, request, pk):
        try:
            bin = Bin.objects.get(pk=pk)
        except Bin.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)

        serializer = BinDetailSerializer(bin)
        return Response(serializer.data)