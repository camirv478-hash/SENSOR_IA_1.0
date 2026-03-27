from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from bin.models import Bin
from bin.permissions.permissions import CanEliminarBin

class BinDeleteView(APIView):
    permission_classes = [CanEliminarBin]

    def delete(self, request, pk):
        try:
            bin = Bin.objects.get(pk=pk)
        except Bin.DoesNotExist:
            return Response(status=status.HTTP_404_NOT_FOUND)

        bin.delete()
        return Response(status=status.HTTP_204_NO_CONTENT)