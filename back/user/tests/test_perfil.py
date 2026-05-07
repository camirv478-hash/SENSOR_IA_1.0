from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from django.utils import timezone
from datetime import timedelta
from user.models.email_change_model import EmailChangeRequest
from user.tests.factories import UserFactory
from unittest.mock import patch


class UserMeTests(APITestCase):

    def setUp(self):
        self.url  = reverse('user-me')
        self.user = UserFactory(email='me@test.com', nombre='Juan')
        self.client.force_authenticate(user=self.user)

    # ── Happy path ────────────────────────────────────────────────────────────

    def test_get_perfil(self):
        res = self.client.get(self.url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data['email'], 'me@test.com')
        self.assertEqual(res.data['nombre'], 'Juan')

    def test_patch_nombre(self):
        res = self.client.patch(self.url, {'nombre': 'Pedro'})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertEqual(self.user.nombre, 'Pedro')

    def test_respuesta_contiene_campos_esperados(self):
        res = self.client.get(self.url)
        for campo in ['id', 'username', 'nombre', 'email', 'rol', 'estado', 'imagen']:
            self.assertIn(campo, res.data)

    # ── Errores ───────────────────────────────────────────────────────────────

    def test_sin_autenticacion(self):
        self.client.force_authenticate(user=None)
        res = self.client.get(self.url)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_patch_imagen_tipo_invalido(self):
        import io
        from django.core.files.uploadedfile import SimpleUploadedFile
        archivo = SimpleUploadedFile('test.txt', b'contenido', content_type='text/plain')
        res = self.client.patch(self.url, {'imagen': archivo}, format='multipart')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_patch_imagen_muy_grande(self):
        import io
        from django.core.files.uploadedfile import SimpleUploadedFile
        datos  = b'x' * (3 * 1024 * 1024)  # 3MB
        imagen = SimpleUploadedFile('foto.jpg', datos, content_type='image/jpeg')
        res    = self.client.patch(self.url, {'imagen': imagen}, format='multipart')
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class UsernameChangeTests(APITestCase):

    def setUp(self):
        self.url  = reverse('user-username')
        self.user = UserFactory(username='original')
        self.client.force_authenticate(user=self.user)

    # ── Happy path ────────────────────────────────────────────────────────────

    def test_cambio_exitoso(self):
        res = self.client.patch(self.url, {'username': 'nuevo'})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertEqual(self.user.username, 'nuevo')

    def test_username_normalizado_a_minusculas(self):
        res = self.client.patch(self.url, {'username': 'NUEVOUSERNAME'})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertEqual(self.user.username, 'nuevousername')

    # ── Errores ───────────────────────────────────────────────────────────────

    def test_username_duplicado(self):
        UserFactory(username='ocupado')
        res = self.client.patch(self.url, {'username': 'ocupado'})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_username_duplicado_case_insensitive(self):
        UserFactory(username='ocupado')
        res = self.client.patch(self.url, {'username': 'OCUPADO'})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_sin_autenticacion(self):
        self.client.force_authenticate(user=None)
        res = self.client.patch(self.url, {'username': 'nuevo'})
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_sin_body(self):
        res = self.client.patch(self.url, {})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class EmailChangeTests(APITestCase):

    def setUp(self):
        self.request_url = reverse('email-change-request')
        self.confirm_url = reverse('email-change-confirm')
        self.user        = UserFactory(email='actual@test.com')
        self.client.force_authenticate(user=self.user)

    # ── Happy path ────────────────────────────────────────────────────────────

    @patch('user.serializers.auth.email_change_serializer.send_email_change_code')
    def test_solicitud_exitosa(self, mock_email):
        res = self.client.post(self.request_url, {'new_email': 'nuevo@test.com'})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        mock_email.assert_called_once()

    @patch('user.serializers.auth.email_change_serializer.send_email_change_code')
    def test_confirmar_cambio_exitoso(self, mock_email):
        self.client.post(self.request_url, {'new_email': 'nuevo@test.com'})
        req = EmailChangeRequest.objects.get(user=self.user, is_used=False)
        res = self.client.post(self.confirm_url, {'code': req.code})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertEqual(self.user.email, 'nuevo@test.com')

    @patch('user.serializers.auth.email_change_serializer.send_email_change_code')
    def test_solicitud_previa_invalidada(self, mock_email):
        self.client.post(self.request_url, {'new_email': 'primero@test.com'})
        self.client.post(self.request_url, {'new_email': 'segundo@test.com'})
        invalidas = EmailChangeRequest.objects.filter(
            user=self.user, is_used=True
        )
        self.assertTrue(invalidas.exists())

    # ── Errores ───────────────────────────────────────────────────────────────

    @patch('user.serializers.auth.email_change_serializer.send_email_change_code')   
    def test_email_ya_en_uso(self, mock_email):
        UserFactory(email='ocupado@test.com')
        res = self.client.post(self.request_url, {'new_email': 'ocupado@test.com'})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_confirmar_sin_solicitud_activa(self):
        res = self.client.post(self.confirm_url, {'code': '123456'})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    @patch('user.serializers.auth.email_change_serializer.send_email_change_code')
    def test_confirmar_codigo_incorrecto(self, mock_email):
        self.client.post(self.request_url, {'new_email': 'nuevo@test.com'})
        res = self.client.post(self.confirm_url, {'code': '000000'})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    @patch('user.serializers.auth.email_change_serializer.send_email_change_code')    
    def test_confirmar_codigo_expirado(self, mock_email):
        self.client.post(self.request_url, {'new_email': 'nuevo@test.com'})
        req = EmailChangeRequest.objects.get(user=self.user, is_used=False)
        req.expires_at = timezone.now() - timedelta(minutes=1)
        req.save()
        res = self.client.post(self.confirm_url, {'code': req.code})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_sin_autenticacion(self):
        self.client.force_authenticate(user=None)
        res = self.client.post(self.request_url, {'new_email': 'nuevo@test.com'})
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)