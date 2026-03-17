from django.urls import path

from user.views.auth.auth_custom_view import LoginView, LogoutView, RefreshView
from user.views.auth.email_change_view import EmailChangeRequestView, EmailChangeConfirmView
from user.views.auth.email_verification_view import EmailVerificationView
from user.views.auth.password_reset_view import PasswordResetRequestView, PasswordResetConfirmView
from user.views.user_view import (
    UserRegisterView,
    UserMeView,
    UsernameChangeView,
    UserListView,
    UserDetailView,
)

urlpatterns = [

    # ── Auth ──────────────────────────────────────────────
    path('auth/login/',   LoginView.as_view(),   name='auth-login'),
    path('auth/logout/',  LogoutView.as_view(),  name='auth-logout'),
    path('auth/refresh/', RefreshView.as_view(), name='auth-refresh'),

    # ── Registro ──────────────────────────────────────────
    path('register/', UserRegisterView.as_view(), name='user-register'),

    # ── Verificación de email ─────────────────────────────
    path('verify-email/', EmailVerificationView.as_view(), name='verify-email'),

    # ── Perfil propio ─────────────────────────────────────
    path('me/',                  UserMeView.as_view(),        name='user-me'),
    path('me/username/',         UsernameChangeView.as_view(), name='user-username'),
    path('me/email/change/',     EmailChangeRequestView.as_view(),  name='email-change-request'),
    path('me/email/confirm/',    EmailChangeConfirmView.as_view(),  name='email-change-confirm'),

    # ── Recuperación de contraseña ────────────────────────
    path('password/reset/',         PasswordResetRequestView.as_view(), name='password-reset-request'),
    path('password/reset/confirm/', PasswordResetConfirmView.as_view(), name='password-reset-confirm'),

    # ── Admin ─────────────────────────────────────────────
    path('',        UserListView.as_view(),         name='user-list'),
    path('<int:pk>/', UserDetailView.as_view(),     name='user-detail'),
]