from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from user.models.user_model import User
from user.tests.factories import UserFactory, AdminFactory


class LoginTests(APITestCase):

    def setUp(self):
        self.url   = reverse('auth-login')
        self.user  = UserFactory(email='login@test.com')

    # ── Happy path ────────────────────────────────────────────────────────────

    def test_login_exitoso(self):
        res = self.client.post(self.url, {
            'email':    'login@test.com',
            'password': 'TestPass123!',
        })
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertIn('access',  res.data)
        self.assertIn('refresh', res.data)

    def test_token_contiene_claims_custom(self):
        import jwt
        res   = self.client.post(self.url, {
            'email': 'login@test.com', 'password': 'TestPass123!'
        })
        token  = res.data['access']
        payload = jwt.decode(token, options={"verify_signature": False})
        self.assertEqual(payload['email'],  'login@test.com')
        self.assertEqual(payload['rol'],    User.Rol.USER)
        self.assertIn('nombre',  payload)
        self.assertIn('estado',  payload)

    # ── Errores ───────────────────────────────────────────────────────────────

    def test_login_password_incorrecto(self):
        res = self.client.post(self.url, {
            'email': 'login@test.com', 'password': 'Wrongpass123!'
        })
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_login_email_inexistente(self):
        res = self.client.post(self.url, {
            'email': 'noexiste@test.com', 'password': 'TestPass123!'
        })
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_login_usuario_inactivo(self):
        self.user.estado = False
        self.user.save()
        res = self.client.post(self.url, {
            'email': 'login@test.com', 'password': 'TestPass123!'
        })
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_login_sin_email(self):
        res = self.client.post(self.url, {'password': 'TestPass123!'})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_login_sin_password(self):
        res = self.client.post(self.url, {'email': 'login@test.com'})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_login_body_vacio(self):
        res = self.client.post(self.url, {})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class LogoutTests(APITestCase):

    def setUp(self):
        self.user       = UserFactory(email='logout@test.com')
        self.login_url  = reverse('auth-login')
        self.logout_url = reverse('auth-logout')

    def _login(self):
        res = self.client.post(self.login_url, {
            'email': 'logout@test.com', 'password': 'TestPass123!'
        })
        return res.data['access'], res.data['refresh']

    # ── Happy path ────────────────────────────────────────────────────────────

    def test_logout_exitoso(self):
        access, refresh = self._login()
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access}')
        res = self.client.post(self.logout_url, {'refresh': refresh})
        self.assertEqual(res.status_code, status.HTTP_200_OK)

    def test_refresh_invalido_tras_logout(self):
        access, refresh = self._login()
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access}')
        self.client.post(self.logout_url, {'refresh': refresh})
        res = self.client.post(reverse('auth-refresh'), {'refresh': refresh})
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    # ── Errores ───────────────────────────────────────────────────────────────

    def test_logout_sin_autenticacion(self):
        res = self.client.post(self.logout_url, {'refresh': 'cualquier'})
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_logout_token_invalido(self):
        access, _ = self._login()
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access}')
        res = self.client.post(self.logout_url, {'refresh': 'token_invalido'})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_logout_sin_body(self):
        access, _ = self._login()
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {access}')
        res = self.client.post(self.logout_url, {})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)


class RefreshTests(APITestCase):

    def setUp(self):
        self.user       = UserFactory(email='refresh@test.com')
        self.login_url  = reverse('auth-login')
        self.refresh_url = reverse('auth-refresh')

    def _login(self):
        res = self.client.post(self.login_url, {
            'email': 'refresh@test.com', 'password': 'TestPass123!'
        })
        return res.data['access'], res.data['refresh']

    # ── Happy path ────────────────────────────────────────────────────────────

    def test_refresh_exitoso(self):
        _, refresh = self._login()
        res = self.client.post(self.refresh_url, {'refresh': refresh})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertIn('access', res.data)

    def test_refresh_rota_token(self):
        _, refresh = self._login()
        res = self.client.post(self.refresh_url, {'refresh': refresh})
        self.assertIn('refresh', res.data)
        self.assertNotEqual(res.data['refresh'], refresh)

    # ── Errores ───────────────────────────────────────────────────────────────

    def test_refresh_token_invalido(self):
        res = self.client.post(self.refresh_url, {'refresh': 'token_falso'})
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_refresh_sin_body(self):
        res = self.client.post(self.refresh_url, {})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)