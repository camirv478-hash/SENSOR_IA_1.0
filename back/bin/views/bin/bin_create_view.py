from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from bin.permissions.permissions import CanCrearBin
from bin.serializers.bin.bin_create_serializer import BinCreateSerializer


class BinCreateView(APIView):
    permission_classes = [CanCrearBin]


    def post(self, request):
        serializer = BinCreateSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response(serializer.data, status=status.HTTP_201_CREATED)