from django.urls import reverse
from django.core import mail
from rest_framework import status
from rest_framework.test import APITestCase
from unittest.mock import patch
from user.models.user_model import User
from user.models.email_verification_model import EmailVerification
from user.tests.factories import UserFactory


class RegistroTests(APITestCase):

    def setUp(self):
        self.url = reverse('user-register')
        self.data_valida = {
            'nombre':    'Juan Pérez',
            'email':     'juan@test.com',
            'username':  'juanperez',
            'rol':       User.Rol.USER,
            'password':  'TestPass123!',
            'password2': 'TestPass123!',
        }

    # ── Happy path ────────────────────────────────────────────────────────────

    @patch('user.serializers.user_create_serializer.send_verification_email')
    def test_registro_exitoso(self, mock_email):
        res = self.client.post(self.url, self.data_valida)
        self.assertEqual(res.status_code, status.HTTP_201_CREATED)
        self.assertTrue(User.objects.filter(email='juan@test.com').exists())

    @patch('user.serializers.user_create_serializer.send_verification_email')
    def test_usuario_creado_inactivo(self, mock_email):
        self.client.post(self.url, self.data_valida)
        user = User.objects.get(email='juan@test.com')
        self.assertFalse(user.estado)

    @patch('user.serializers.user_create_serializer.send_verification_email')
    def test_crea_verificacion_de_email(self, mock_email):
        self.client.post(self.url, self.data_valida)
        user = User.objects.get(email='juan@test.com')
        self.assertTrue(
            EmailVerification.objects.filter(user=user, is_used=False).exists()
        )

    @patch('user.serializers.user_create_serializer.send_verification_email')
    def test_email_se_envia(self, mock_email):
        self.client.post(self.url, self.data_valida)
        mock_email.assert_called_once()

    @patch('user.serializers.user_create_serializer.send_verification_email')
    def test_email_normalizado_a_minusculas(self, mock_email):
        data = {**self.data_valida, 'email': 'JUAN@TEST.COM'}
        self.client.post(self.url, data)
        self.assertTrue(User.objects.filter(email='juan@test.com').exists())

    # ── Errores ───────────────────────────────────────────────────────────────

    @patch('user.serializers.user_create_serializer.send_verification_email')
    def test_email_duplicado(self, mock_email):
        self.client.post(self.url, self.data_valida)
        res = self.client.post(self.url, self.data_valida)
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_passwords_no_coinciden(self):
        data = {**self.data_valida, 'password2': 'OtraPass123!'}
        res  = self.client.post(self.url, data)
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_password_muy_corto(self):
        data = {**self.data_valida, 'password': '123', 'password2': '123'}
        res  = self.client.post(self.url, data)
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_password_solo_numeros(self):
        data = {**self.data_valida, 'password': '12345678', 'password2': '12345678'}
        res  = self.client.post(self.url, data)
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_email_invalido(self):
        data = {**self.data_valida, 'email': 'no_es_un_email'}
        res  = self.client.post(self.url, data)
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_campos_requeridos_faltantes(self):
        res = self.client.post(self.url, {})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class EmailVerificationTests(APITestCase):

    def setUp(self):
        self.url  = reverse('verify-email')
        self.user = UserFactory(estado=False)
        self.client.force_authenticate(user=self.user)

        self.verification = EmailVerification.objects.create(
            user       = self.user,
            code       = '123456',
            expires_at = EmailVerification.get_expiration_time(),
        )

    # ── Happy path ────────────────────────────────────────────────────────────

    def test_verificacion_exitosa(self):
        res = self.client.post(self.url, {'code': '123456'})
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_usuario_activo_tras_verificacion(self):
        self.client.post(self.url, {'code': '123456'})
        self.user.refresh_from_db()
        self.assertTrue(self.user.estado)

    def test_verificacion_marca_is_used(self):
        self.client.post(self.url, {'code': '123456'})
        self.verification.refresh_from_db()
        self.assertTrue(self.verification.is_used)

    def test_verificacion_marca_is_verified(self):
        self.client.post(self.url, {'code': '123456'})
        self.verification.refresh_from_db()
        self.assertTrue(self.verification.is_verified)

    # ── Errores ───────────────────────────────────────────────────────────────

    def test_codigo_incorrecto(self):
        res = self.client.post(self.url, {'code': '000000'})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_codigo_expirado(self):
        from django.utils import timezone
        from datetime import timedelta
        self.verification.expires_at = timezone.now() - timedelta(minutes=1)
        self.verification.save()
        res = self.client.post(self.url, {'code': '123456'})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_codigo_ya_usado(self):
        self.verification.is_used = True
        self.verification.save()
        res = self.client.post(self.url, {'code': '123456'})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_sin_autenticacion(self):
        self.client.force_authenticate(user=None)
        res = self.client.post(self.url, {'code': '123456'})
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_codigo_longitud_incorrecta(self):
        res = self.client.post(self.url, {'code': '123'})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_sin_body(self):
        res = self.client.post(self.url, {})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)