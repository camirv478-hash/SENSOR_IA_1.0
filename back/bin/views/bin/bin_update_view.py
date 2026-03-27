from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from bin.permissions.permissions import CanEditarBin
from bin.models import Bin
from bin.serializers.bin.bin_update_serializer import BinUpdateSerializer

class BinUpdateView(APIView):
    permission_classes = [CanEditarBin]

    def put(self, request, pk):
        try:
            bin = Bin.objects.get(pk=pk)
        except Bin.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)

        serializer = BinUpdateSerializer(bin, data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response(serializer.data)