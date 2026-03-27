from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status

from bin.permissions.permissions import CanEditarBin
from bin.models import Bin
from bin.serializers.bin.bin_update_serializer import BinUpdateSerializer


class BinUpdateView(APIView):
    permission_classes = [CanEditarBin]

    def put(self, request, pk):
        return self._update(request, pk, partial=False)

    def patch(self, request, pk):
        return self._update(request, pk, partial=True)

    def _update(self, request, pk, partial):
        try:
            bin = Bin.objects.get(pk=pk)
        except Bin.DoesNotExist:
            return Response(
                {"detail": "Caneca no encontrada."},
                status=status.HTTP_404_NOT_FOUND
            )

        serializer = BinUpdateSerializer(
            bin,
            data=request.data,
            partial=partial  # 🔥 CLAVE
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response(serializer.data, status=status.HTTP_200_OK)