from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase
from user.models.user_model import User
from user.tests.factories import UserFactory, AdminFactory


class UserListTests(APITestCase):

    def setUp(self):
        self.url   = reverse('user-list')
        self.admin = AdminFactory()
        self.user  = UserFactory()

    # ── Happy path ────────────────────────────────────────────────────────────

    def test_admin_puede_listar(self):
        self.client.force_authenticate(user=self.admin)
        res = self.client.get(self.url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertIsInstance(res.data, list)

    def test_listado_incluye_fecha_modificacion(self):
        self.client.force_authenticate(user=self.admin)
        res = self.client.get(self.url)
        self.assertIn('fecha_modificacion', res.data[0])

    # ── Errores ───────────────────────────────────────────────────────────────

    def test_usuario_normal_no_puede_listar(self):
        self.client.force_authenticate(user=self.user)
        res = self.client.get(self.url)
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

    def test_sin_autenticacion(self):
        res = self.client.get(self.url)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)


class UserDetailTests(APITestCase):

    def setUp(self):
        self.admin  = AdminFactory()
        self.user   = UserFactory()
        self.url    = reverse('user-detail', kwargs={'pk': self.user.pk})
        self.client.force_authenticate(user=self.admin)

    # ── Happy path ────────────────────────────────────────────────────────────

    def test_admin_puede_ver_detalle(self):
        res = self.client.get(self.url)
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.assertEqual(res.data['email'], self.user.email)

    def test_admin_puede_cambiar_rol(self):
        res = self.client.patch(self.url, {'rol': User.Rol.ADMIN})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertEqual(self.user.rol, User.Rol.ADMIN)

    def test_admin_puede_desactivar_usuario(self):
        res = self.client.patch(self.url, {'estado': False})
        self.assertEqual(res.status_code, status.HTTP_200_OK)
        self.user.refresh_from_db()
        self.assertFalse(self.user.estado)

    def test_admin_puede_eliminar_usuario(self):
        res = self.client.delete(self.url)
        self.assertEqual(res.status_code, status.HTTP_204_NO_CONTENT)
        self.assertFalse(User.objects.filter(pk=self.user.pk).exists())

    # ── Edge cases ────────────────────────────────────────────────────────────

    def test_admin_no_puede_eliminarse_a_si_mismo(self):
        url = reverse('user-detail', kwargs={'pk': self.admin.pk})
        res = self.client.delete(url)
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)

    def test_pk_inexistente_retorna_404(self):
        url = reverse('user-detail', kwargs={'pk': 99999})
        res = self.client.get(url)
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)

    def test_patch_pk_inexistente(self):
        url = reverse('user-detail', kwargs={'pk': 99999})
        res = self.client.patch(url, {'estado': False})
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)

    def test_delete_pk_inexistente(self):
        url = reverse('user-detail', kwargs={'pk': 99999})
        res = self.client.delete(url)
        self.assertEqual(res.status_code, status.HTTP_404_NOT_FOUND)

    # ── Errores de permisos ───────────────────────────────────────────────────

    def test_usuario_normal_no_puede_ver_detalle(self):
        otro = UserFactory()
        self.client.force_authenticate(user=otro)
        res = self.client.get(self.url)
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

    def test_usuario_normal_no_puede_editar(self):
        otro = UserFactory()
        self.client.force_authenticate(user=otro)
        res = self.client.patch(self.url, {'estado': False})
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

    def test_usuario_normal_no_puede_eliminar(self):
        otro = UserFactory()
        self.client.force_authenticate(user=otro)
        res = self.client.delete(self.url)
        self.assertEqual(res.status_code, status.HTTP_403_FORBIDDEN)

    def test_sin_autenticacion(self):
        self.client.force_authenticate(user=None)
        res = self.client.get(self.url)
        self.assertEqual(res.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_rol_invalido(self):
        res = self.client.patch(self.url, {'rol': 'ROL_INEXISTENTE'})
        self.assertEqual(res.status_code, status.HTTP_400_BAD_REQUEST)