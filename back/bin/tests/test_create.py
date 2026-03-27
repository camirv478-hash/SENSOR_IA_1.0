from rest_framework.test import APITestCase
from django.urls import reverse
from rest_framework import status

class BinCreateTest(APITestCase):

    def test_create_bin(self):
        data = {
            "color": "Rojo",
            "location": "Zona 1",
            "status": "active"
        }

        response = self.client.post('/api/bin/create/', data)

        self.assertEqual(response.status_code, status.HTTP_201_CREATED)